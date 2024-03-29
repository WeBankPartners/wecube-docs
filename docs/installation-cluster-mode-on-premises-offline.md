# 在私有资源上手工集群模式安装WeCube

在这里，我们将为您说明如何在您自己的机器资源上手工安装以集群模式运行的WeCube。

本文旨在帮助用户理解WeCube软件的完整安装过程，并在离线环境中手工完成配置。

## 先决条件

### 硬件资源

在原有的WeCube单机部署中，我们默认内置了MySQL服务，S3服务，而在集群模式下，我们建议您使用您所在的组织/公司提供高可用服务(负载均衡 * 2 + MySQL * 3 + S3服务 * 1)

| 资源    | 数量  | 建议配置                       | 用途                                                                                                         |
|-------|-----|----------------------------|------------------------------------------------------------------------------------------------------------|
| 主机    | 2   | 2核 8G 100G硬盘              | WeCube平台软件运行(100用户规模)                                                                                       |
| 主机    | 2   | 4核 16G 100G硬盘              | WeCube插件运行(除Monitor插件其他插件)                                                                                            |
| 主机    | 2   | 8核 32G 500G硬盘              | WeCube插件运行(Monitor插件独占,1000主机规模)                                                                                              |
| MySQL服务 | 1   | 2核 4G 50G硬盘                | MySQL集群 - Auth Server数据库                                                                                   |
| MySQL服务 | 1   | 4核 8G 100G硬盘                | MySQL集群 - WeCube数据库                                                                                        |
| MySQL服务 | 1   | 4核 8G 100G硬盘(请根据实际业务量进行调整)  | MySQL集群 - 插件数据库                                                                                            |
| MySQL服务 | 1   | 4核 8G 500G硬盘(请根据实际业务量进行调整) | MySQL集群 - Monitor插件归档数据库                                                                                  |
| S3    | 2   | 2核 4G 200G硬盘(请根据实际业务量进行调整) | S3集群                                                                                                       |
| LB    | 1   |                            | WeCube-Gateway负载均衡(负载{{host_wecube1_ip}}:19110,{{host_wecube2_ip}}:19110)，健康检查地址：/platform/v1/health-check |
| LB    | 1   |                            | WeCube-Portal负载均衡（负载{{host_wecube1_ip}}:19090,{{host_wecube2_ip}}:19090）                                   |

> 若您的组织/公司内部未提供以上服务，或参照互联网文章进行安装部署，本文不再赘述，文中提供一个单节点作为演示说明用途，请勿应用于生产环境中。



### 系统和软件资源

#### CentOS 7

以下安装配置脚本基于CentOS操作系统，推荐使用CentOS 7.2+。

#### Docker

WeCube的运行依赖于Docker，在安装WeCube之前，需要在您的环境(每台服务器)上正确部署和配置docker和docker-compose软件，最新的docker软件可以从docker-ce源中获取，epel源中有版本稍旧的docker-compose但足够本次安装使用，这需要您所在的组织/公司提供这些软件的源。

??? note "如果您使用CentOS，也可以考虑使用这里提供的命令行指令来进行Docker的安装与配置，请展开来查看。"
    我们还是**建议**您从 [Docker官方网站 :fa-external-link:](https://docs.docker.com/engine/install/){: target=\_blank} 获取最新的安装和配置的指引。

    ``` bash
    # 移除已安装的旧版本Docker
    yum remove docker \
              docker-client \
              docker-client-latest \
              docker-common \
              docker-latest \
              docker-latest-logrotate \
              docker-logrotate \
              docker-engine

    # 安装Docker
    yum install -y yum-utils device-mapper-persistent-data lvm2
    # yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    # yum-config-manager --add-repo https://mirrors.cloud.tencent.com/docker-ce/linux/centos/docker-ce.repo
    yum makecache fast
    yum install -y docker-ce docker-ce-cli containerd.io

    # 安装Docker Compose
    yum install -y docker-compose

    # 安装基础工具
    yum install -y unzip

    # 配置Docker Engine以监听远程API请求
    mkdir -p /etc/systemd/system/docker.service.d
    cat <<EOF >/etc/systemd/system/docker.service.d/docker-wecube-override.conf
    [Service]
    ExecStart=
    ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H fd:// --containerd=/run/containerd/containerd.sock
    EOF

    # 启动Docker服务
    systemctl daemon-reload
    systemctl enable docker.service
    systemctl start docker.service

    # 启用IP转发并配置桥接来解决Docker容器对外部网络的通信问题
    cat <<EOF >/etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf
    net.ipv4.ip_forward = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    EOF
    sysctl -p /etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf

    ####
    ```



安装并配置完成后，您可以使用以下命令行指令来确认Docker的运行情况：

``` bash
docker version
docker-compose version
curl http://127.0.0.1:2375/version

```

### 离线镜像准备

首先，需要确认要安装的WeCube版本，版本号通常定义为vX.Y.Z，如v2.9.0，具体版本号可以从官方Release中找到

[GitHub Release](https://github.com/WeBankPartners/wecube-platform/releases)

[Gitee Release](https://gitee.com/WeBankPartners/wecube-platform/releases)

并且可以从Release中找到插件包的下载地址，可以下载备用

```bash
WECUBE_VERSION=v2.9.1
# pull images
docker pull ccr.ccs.tencentyun.com/webankpartners/minio
docker pull ccr.ccs.tencentyun.com/webankpartners/mysql:5.6
docker pull ccr.ccs.tencentyun.com/webankpartners/platform-core:$WECUBE_VERSION
docker pull ccr.ccs.tencentyun.com/webankpartners/wecube-portal:$WECUBE_VERSION
docker pull ccr.ccs.tencentyun.com/webankpartners/platform-gateway:$WECUBE_VERSION
docker pull ccr.ccs.tencentyun.com/webankpartners/platform-auth-server:$WECUBE_VERSION

# save images
docker save -o webankpartners-minio.tar ccr.ccs.tencentyun.com/webankpartners/minio
docker save -o webankpartners-mysql.tar ccr.ccs.tencentyun.com/webankpartners/mysql:5.6
docker save -o webankpartners-platform-core.tar ccr.ccs.tencentyun.com/webankpartners/platform-core:$WECUBE_VERSION
docker save -o webankpartners-wecube-portal.tar ccr.ccs.tencentyun.com/webankpartners/wecube-portal:$WECUBE_VERSION
docker save -o webankpartners-platform-gateway.tar ccr.ccs.tencentyun.com/webankpartners/platform-gateway:$WECUBE_VERSION
docker save -o webankpartners-platform-auth-server.tar ccr.ccs.tencentyun.com/webankpartners/platform-auth-server:$WECUBE_VERSION
```



## 开始安装WeCube安装

### 部署图

![deploy](images/installation/wecube-deploy-cluster.png)

### 环境变量整理

**请按需修正一下环境变量值**

```bash
WECUBE_VERSION=v2.9.1
# wecube mysql服务信息
mysql_wecube_host='10.0.0.10'
mysql_wecube_port='3306'
mysql_wecube_username='root'
mysql_wecube_password='WeCube@1234'
# auth server mysql服务信息
mysql_auth_host='10.0.0.11'
mysql_auth_port='3306'
mysql_auth_username='root'
mysql_auth_password='WeCube@1234'
# s3服务信息
s3_host='10.0.1.10'
s3_port='3306'
s3_access='access_key'
s3_secret='secret_key'
# wecube主机节点一IP信息
host_wecube1_ip='10.0.2.10'
# wecube主机节点二IP信息
host_wecube2_ip='10.0.2.11'
# wecube主机节点一 & 二 ssh 认证信息
host_wecube_username='root'
host_wecube_password='WeCube@1234'
```



### MySQL服务(仅演示用途)：

在本地准备以下db的yaml文件

1-wecube-db.yml

```yaml
version: "2"
services:
  mysql-wecube:
    image: ccr.ccs.tencentyun.com/webankpartners/mysql:5.6
    restart: always
    command:
      [
        "--character-set-server=utf8mb4",
        "--collation-server=utf8mb4_unicode_ci",
        "--default-time-zone=+8:00",
        "--max_allowed_packet=4M",
        "--lower_case_table_names=1",
      ]
    volumes:
      - /etc/localtime:/etc/localtime
      - /data/installer/wecube/database/platform-core:/docker-entrypoint-initdb.d
      - /data/mysql-wecube/data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=WeCube@1234
      - MYSQL_DATABASE=wecube
    ports:
      - 3307:3306

  mysql-auth-server:
    image: ccr.ccs.tencentyun.com/webankpartners/mysql:5.6
    restart: always
    command:
      [
        "--character-set-server=utf8mb4",
        "--collation-server=utf8mb4_unicode_ci",
        "--default-time-zone=+8:00",
        "--max_allowed_packet=4M",
        "--lower_case_table_names=1",
      ]
    volumes:
      - /etc/localtime:/etc/localtime
      - /data/installer/wecube/database/auth-server:/docker-entrypoint-initdb.d
      - /data/mysql-auth-server/data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=WeCube@1234
      - MYSQL_DATABASE=auth_server
    ports:
      - 3308:3306

```

启动db服务

docker-compose -f 1-wecube-db.yml up -d 

### S3服务(仅演示用途)：

```yaml
version: '2'
services:
  wecube-minio:
    image: ccr.ccs.tencentyun.com/webankpartners/minio
    restart: always
    command: [
        'server',
        'data'
    ]
    ports:
      - 9000:9000
    volumes:
      - /data/wecube-minio/data:/data    
      - /data/wecube-minio/config:/root
      - /etc/localtime:/etc/localtime
    environment:
      - MINIO_ACCESS_KEY=access_key
      - MINIO_SECRET_KEY=secret_key
```

启动minio服务

docker-compose -f 2-wecube-minio.yml up -d 

### 主机：WeCube节点一

#### 准备yaml内容

在本地准备以下2个yaml文件

3-wecube-auth-server.yml

```yaml
version: '2'
services:
  auth-server:
    image: ccr.ccs.tencentyun.com/webankpartners/platform-auth-server:{{wecube_version}}
    restart: always
    volumes:
      - /data/log/auth_server:/data/auth_server/log
      - /etc/localtime:/etc/localtime
    ports:
      - 19120:8080
    environment:
      - TZ=Asia/Shanghai
      - MYSQL_SERVER_ADDR={{mysql_auth_host}}
      - MYSQL_SERVER_PORT={{mysql_auth_port}}
      - MYSQL_SERVER_DATABASE_NAME=auth_server
      - MYSQL_USER_NAME={{mysql_auth_username}}
      - MYSQL_USER_PASSWORD={{mysql_auth_password}}
      - AUTH_CUSTOM_PARAM=
      - AUTH_SERVER_LOG_PATH=/data/auth_server/log
      - USER_ACCESS_TOKEN=20
      - USER_REFRESH_TOKEN=30
```
程序支持MYSQL_USER_PASSWORD使用rsa1024加解密，可以对上面的yaml添加如下配置:    

- volumes里增加 {{DOCKER_API_CERTS_PATH}}:/certs 其中DOCKER_API_CERTS_PATH为本地存放公私钥的目录，里面存放私钥文件wecube_rsa_private(文件名可任意，与下面AUTH_CUSTOM_PARAM里的值一样即可)

- environment里AUTH_CUSTOM_PARAM的值改为 --platform.auth.server.config.property-rsa-key=/certs/wecube_rsa_private

- environment里MYSQL_USER_PASSWORD的值写为公钥加密后的加密值，这样程序就会拿私钥去解该密码

4-wecube.yml

```yaml
version: '2'
services:
  platform-core:
    image: ccr.ccs.tencentyun.com/webankpartners/platform-core:{{wecube_version}}
    restart: always
    volumes:
      - /data/log/wecube:/data/wecube/log
      - /etc/localtime:/etc/localtime
    ports:
      - 19100:8080
      - 19101:8081
    environment:
      - TZ=Asia/Shanghai
      - MYSQL_SERVER_ADDR={{mysql_wecube_host}}
      - MYSQL_SERVER_PORT={{mysql_wecube_port}}
      - MYSQL_SERVER_DATABASE_NAME=wecube
      - MYSQL_USER_NAME={{mysql_wecube_username}}
      - MYSQL_USER_PASSWORD={{mysql_wecube_password}}
      - WECUBE_PLUGIN_HOSTS=
      - WECUBE_PLUGIN_HOST_PORT=
      - WECUBE_PLUGIN_HOST_USER=
      - WECUBE_PLUGIN_HOST_PWD=
      - S3_ENDPOINT=http://{{s3_host}}:{{s3_port}}
      - S3_ACCESS_KEY={{s3_access}}
      - S3_SECRET_KEY={{s3_secret}}
      - STATIC_RESOURCE_SERVER_IP={{host_wecube1_ip}},{{host_wecube2_ip}}
      - STATIC_RESOURCE_SERVER_USER={{host_wecube_username}}
      - STATIC_RESOURCE_SERVER_PASSWORD={{host_wecube_password}}
      - STATIC_RESOURCE_SERVER_PORT=22
      - STATIC_RESOURCE_SERVER_PATH=/data/wecube-portal/data/ui-resources
      - GATEWAY_URL={{host_wecube1_ip}}:19110
      - GATEWAY_HOST={{host_wecube1_ip}}
      - GATEWAY_PORT=19110
      - GATEWAY_HOST_PORTS={{host_wecube1_ip}}:19110,{{host_wecube2_ip}}:19110
      - JWT_SSO_AUTH_URI=http://{{host_wecube1_ip}}:19120/auth/v1/api/login
      - JWT_SSO_TOKEN_URI=http://{{host_wecube1_ip}}:19120/auth/v1/api/token
      - WECUBE_PLUGIN_DEPLOY_PATH=/opt
      - WECUBE_SERVER_JMX_PORT=19101
      - WECUBE_BUCKET=wecube-plugin-package-bucket
      - WECUBE_CORE_HOST={{host_wecube1_ip}}
      - WECUBE_CUSTOM_PARAM=
      - APP_LOG_PATH=/data/wecube/log

  platform-gateway:
    image: ccr.ccs.tencentyun.com/webankpartners/platform-gateway:{{wecube_version}}
    restart: always
    depends_on:
      - platform-core
    volumes:
      - /data/log/wecube-gateway:/data/wecube-gateway/log
      - /etc/localtime:/etc/localtime
    ports:
      - 19110:8080
    environment:
      - TZ=Asia/Shanghai
      - GATEWAY_ROUTE_CONFIG_SERVER=http://{{host_wecube1_ip}}:19100
      - GATEWAY_ROUTE_CONFIG_URI=/platform/v1/route-items
      - GATEWAY_ROUTE_ACCESS_KEY=eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJXRUNVQkUtQ09SRSIsImlhdCI6MTU3MDY5MDMwMCwidHlwZSI6ImFjY2Vzc1Rva2VuIiwiY2xpZW50VHlwZSI6IlNVQl9TWVNURU0iLCJleHAiOjE2MDIzMTI3MDAsImF1dGhvcml0eSI6IltTVUJfU1lTVEVNXSJ9.Mq8g_ZoPIQ_mB59zEq0KVtwGn_uPqL8qn6sP7WzEiJxoXQQIcVe7mYsG-E2jxCShEQL7PsMNLM47MYuY7R5nBg
      - WECUBE_CORE_HOST={{host_wecube1_ip}}
      - AUTH_SERVER_HOST={{host_wecube1_ip}}
      - WECUBE_GATEWAY_LOG_PATH=/var/log/wecube-gateway

  wecube-portal:
    image: ccr.ccs.tencentyun.com/webankpartners/wecube-portal:{{wecube_version}}
    restart: always
    depends_on:
      - platform-gateway
      - platform-core
    volumes:
      - /data/log/wecube-portal:/var/log/nginx
      - /data/wecube-portal/data/ui-resources:/root/app/ui-resources
      - /etc/localtime:/etc/localtime
    ports:
      - 19090:8080
    environment:
      - GATEWAY_HOST={{host_wecube1_ip}}
      - GATEWAY_PORT=19110
      - PUBLIC_DOMAIN={{host_wecube1_ip}}:19090
      - TZ=Asia/Shanghai
    command: /bin/bash -c "envsubst < /etc/nginx/conf.d/nginx.tpl > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"
```
程序支持MYSQL_USER_PASSWORD使用rsa1024加解密，可以对上面的yaml添加如下配置:      

- volumes里增加 {{DOCKER_API_CERTS_PATH}}:/certs 其中DOCKER_API_CERTS_PATH为本地存放公私钥的目录，里面存放私钥文件wecube_rsa_private(文件名可任意，与下面AUTH_CUSTOM_PARAM里的值一样即可)

- environment里AUTH_CUSTOM_PARAM的值改为 --wecube.core.config.property-rsa-key=/certs/wecube_rsa_private

- environment里MYSQL_USER_PASSWORD的值写为公钥加密后的加密值，这样程序就会拿私钥去解该密码


#### 修正yaml内容的值

```bash
# 请修改以下变量为正确值
# 粘贴以上整理的环境变量


sed -i "s/{{wecube_version}}/$WECUBE_VERSION/g" 3-wecube-auth-server.yml
sed -i "s/{{mysql_auth_host}}/$mysql_auth_host/g" 3-wecube-auth-server.yml
sed -i "s/{{mysql_auth_port}}/$mysql_auth_port/g" 3-wecube-auth-server.yml
sed -i "s/{{mysql_auth_username}}/$mysql_auth_username/g" 3-wecube-auth-server.yml
sed -i "s/{{mysql_auth_password}}/$mysql_auth_password/g" 3-wecube-auth-server.yml


sed -i "s/{{wecube_version}}/$WECUBE_VERSION/g" 4-wecube.yml
sed -i "s/{{mysql_wecube_host}}/$mysql_wecube_host/g" 4-wecube.yml
sed -i "s/{{mysql_wecube_port}}/$mysql_wecube_port/g" 4-wecube.yml
sed -i "s/{{mysql_wecube_username}}/$mysql_wecube_username/g" 4-wecube.yml
sed -i "s/{{mysql_wecube_password}}/$mysql_wecube_password/g" 4-wecube.yml
sed -i "s/{{s3_host}}/$s3_host/g" 4-wecube.yml
sed -i "s/{{s3_port}}/$s3_port/g" 4-wecube.yml
sed -i "s/{{s3_access}}/$s3_access/g" 4-wecube.yml
sed -i "s/{{s3_secret}}/$s3_secret/g" 4-wecube.yml
sed -i "s/{{host_wecube1_ip}}/$host_wecube1_ip/g" 4-wecube.yml
sed -i "s/{{host_wecube2_ip}}/$host_wecube2_ip/g" 4-wecube.yml
sed -i "s/{{host_wecube_username}}/$host_wecube_username/g" 4-wecube.yml
sed -i "s/{{host_wecube_password}}/$host_wecube_password/g" 4-wecube.yml
sed -i "s/{{wecube_version}}/$WECUBE_VERSION/g" 4-wecube.yml
sed -i "s/{{wecube_version}}/$WECUBE_VERSION/g" 4-wecube.yml
```



#### 启动docker容器

- 启动auth-server服务

  docker-compose -f 3-wecube-auth-server.yml up -d

- 启动core/gateway/portal服务

  docker-compose -f 4-wecube.yml up -d

  

  至此，已经可以打开系统页面进行正常访问，但还无法正常使用插件功能

  **WeCube主页：http://{主机节点一IP}:19090   默认账户密码：admin/admin**

#### 更改系统变量值

修改正确的值，以正确启动插件

Web页面：系统-系统参数

| key                               | value                              |
| --------------------------------- | ---------------------------------- |
| system\_\_global\_\_GATEWAY_URL   | http://\{\{lb_gateway_ip}}:19090   |
| system\_\_global\_\_S3_SERVER_URL | http://\{\{s3_host}}:\{\{s3_port}} |
| system\_\_global\_\_S3_ACCESS_KEY | \{\{s3_access}}                    |
| system\_\_global\_\_S3_SECRET_KEY | \{\{s3_secret}}                    |

### 主机：WeCube节点二

#### 准备yaml内容

在本地准备以下2个yaml文件

3-wecube-auth-server.yml

```yaml
version: '2'
services:
  auth-server:
    image: ccr.ccs.tencentyun.com/webankpartners/platform-auth-server:{{wecube_version}}
    restart: always
    volumes:
      - /data/log/auth_server:/data/auth_server/log
      - /etc/localtime:/etc/localtime
    ports:
      - 19120:8080
    environment:
      - TZ=Asia/Shanghai
      - MYSQL_SERVER_ADDR={{mysql_auth_host}}
      - MYSQL_SERVER_PORT={{mysql_auth_port}}
      - MYSQL_SERVER_DATABASE_NAME=auth_server
      - MYSQL_USER_NAME={{mysql_auth_username}}
      - MYSQL_USER_PASSWORD={{mysql_auth_password}}
      - AUTH_CUSTOM_PARAM=
      - AUTH_SERVER_LOG_PATH=/data/auth_server/log
      - USER_ACCESS_TOKEN=20
      - USER_REFRESH_TOKEN=30
```

4-wecube.yml

```yaml
version: '2'
services:
  platform-core:
    image: ccr.ccs.tencentyun.com/webankpartners/platform-core:{{wecube_version}}
    restart: always
    volumes:
      - /data/log/wecube:/data/wecube/log
      - /etc/localtime:/etc/localtime
    ports:
      - 19100:8080
      - 19101:8081
    environment:
      - TZ=Asia/Shanghai
      - MYSQL_SERVER_ADDR={{mysql_wecube_host}}
      - MYSQL_SERVER_PORT={{mysql_wecube_port}}
      - MYSQL_SERVER_DATABASE_NAME=wecube
      - MYSQL_USER_NAME={{mysql_wecube_username}}
      - MYSQL_USER_PASSWORD={{mysql_wecube_password}}
      - WECUBE_PLUGIN_HOSTS=
      - WECUBE_PLUGIN_HOST_PORT=
      - WECUBE_PLUGIN_HOST_USER=
      - WECUBE_PLUGIN_HOST_PWD=
      - S3_ENDPOINT=http://{{s3_host}}:{{s3_port}}
      - S3_ACCESS_KEY={{s3_access}}
      - S3_SECRET_KEY={{s3_secret}}
      - STATIC_RESOURCE_SERVER_IP={{host_wecube1_ip}},{{host_wecube2_ip}}
      - STATIC_RESOURCE_SERVER_USER={{host_wecube_username}}
      - STATIC_RESOURCE_SERVER_PASSWORD={{host_wecube_password}}
      - STATIC_RESOURCE_SERVER_PORT=22
      - STATIC_RESOURCE_SERVER_PATH=/data/wecube-portal/data/ui-resources
      - GATEWAY_URL={{host_wecube2_ip}}:19110
      - GATEWAY_HOST={{host_wecube2_ip}}
      - GATEWAY_PORT=19110
      - GATEWAY_HOST_PORTS={{host_wecube1_ip}}:19110,{{host_wecube2_ip}}:19110
      - JWT_SSO_AUTH_URI=http://{{host_wecube2_ip}}:19120/auth/v1/api/login
      - JWT_SSO_TOKEN_URI=http://{{host_wecube2_ip}}:19120/auth/v1/api/token
      - WECUBE_PLUGIN_DEPLOY_PATH=/opt
      - WECUBE_SERVER_JMX_PORT=19101
      - WECUBE_BUCKET=wecube-plugin-package-bucket
      - WECUBE_CORE_HOST={{host_wecube2_ip}}
      - WECUBE_CUSTOM_PARAM=
      - APP_LOG_PATH=/data/wecube/log

  platform-gateway:
    image: ccr.ccs.tencentyun.com/webankpartners/platform-gateway:{{wecube_version}}
    restart: always
    depends_on:
      - platform-core
    volumes:
      - /data/log/wecube-gateway:/data/wecube-gateway/log
      - /etc/localtime:/etc/localtime
    ports:
      - 19110:8080
    environment:
      - TZ=Asia/Shanghai
      - GATEWAY_ROUTE_CONFIG_SERVER=http://{{host_wecube2_ip}}:19100
      - GATEWAY_ROUTE_CONFIG_URI=/platform/v1/route-items
      - GATEWAY_ROUTE_ACCESS_KEY=eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJXRUNVQkUtQ09SRSIsImlhdCI6MTU3MDY5MDMwMCwidHlwZSI6ImFjY2Vzc1Rva2VuIiwiY2xpZW50VHlwZSI6IlNVQl9TWVNURU0iLCJleHAiOjE2MDIzMTI3MDAsImF1dGhvcml0eSI6IltTVUJfU1lTVEVNXSJ9.Mq8g_ZoPIQ_mB59zEq0KVtwGn_uPqL8qn6sP7WzEiJxoXQQIcVe7mYsG-E2jxCShEQL7PsMNLM47MYuY7R5nBg
      - WECUBE_CORE_HOST={{host_wecube2_ip}}
      - AUTH_SERVER_HOST={{host_wecube2_ip}}
      - WECUBE_GATEWAY_LOG_PATH=/var/log/wecube-gateway

  wecube-portal:
    image: ccr.ccs.tencentyun.com/webankpartners/wecube-portal:{{wecube_version}}
    restart: always
    depends_on:
      - platform-gateway
      - platform-core
    volumes:
      - /data/log/wecube-portal:/var/log/nginx
      - /data/wecube-portal/data/ui-resources:/root/app/ui-resources
      - /etc/localtime:/etc/localtime
    ports:
      - 19090:8080
    environment:
      - GATEWAY_HOST={{host_wecube2_ip}}
      - GATEWAY_PORT=19110
      - PUBLIC_DOMAIN={{host_wecube2_ip}}:19090
      - TZ=Asia/Shanghai
    command: /bin/bash -c "envsubst < /etc/nginx/conf.d/nginx.tpl > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"
```



#### 修正yaml内容的值

```bash
# 请修改以下变量为正确值
# 粘贴以上整理的环境变量


sed -i "s/{{wecube_version}}/$WECUBE_VERSION/g" 3-wecube-auth-server.yml
sed -i "s/{{mysql_auth_host}}/$mysql_auth_host/g" 3-wecube-auth-server.yml
sed -i "s/{{mysql_auth_port}}/$mysql_auth_port/g" 3-wecube-auth-server.yml
sed -i "s/{{mysql_auth_username}}/$mysql_auth_username/g" 3-wecube-auth-server.yml
sed -i "s/{{mysql_auth_password}}/$mysql_auth_password/g" 3-wecube-auth-server.yml


sed -i "s/{{wecube_version}}/$WECUBE_VERSION/g" 4-wecube.yml
sed -i "s/{{mysql_wecube_host}}/$mysql_wecube_host/g" 4-wecube.yml
sed -i "s/{{mysql_wecube_port}}/$mysql_wecube_port/g" 4-wecube.yml
sed -i "s/{{mysql_wecube_username}}/$mysql_wecube_username/g" 4-wecube.yml
sed -i "s/{{mysql_wecube_password}}/$mysql_wecube_password/g" 4-wecube.yml
sed -i "s/{{s3_host}}/$s3_host/g" 4-wecube.yml
sed -i "s/{{s3_port}}/$s3_port/g" 4-wecube.yml
sed -i "s/{{s3_access}}/$s3_access/g" 4-wecube.yml
sed -i "s/{{s3_secret}}/$s3_secret/g" 4-wecube.yml
sed -i "s/{{host_wecube1_ip}}/$host_wecube1_ip/g" 4-wecube.yml
sed -i "s/{{host_wecube2_ip}}/$host_wecube2_ip/g" 4-wecube.yml
sed -i "s/{{host_wecube_username}}/$host_wecube_username/g" 4-wecube.yml
sed -i "s/{{host_wecube_password}}/$host_wecube_password/g" 4-wecube.yml
sed -i "s/{{wecube_version}}/$WECUBE_VERSION/g" 4-wecube.yml
sed -i "s/{{wecube_version}}/$WECUBE_VERSION/g" 4-wecube.yml
```



#### 启动docker容器

- 启动auth-server服务

  docker-compose -f 3-wecube-auth-server.yml up -d

- 启动core/gateway/portal服务

  docker-compose -f 4-wecube.yml up -d


### 主机：Plugin节点一

完成先决条件中的Docker环境准备即可

### 主机：Plugin节点二

完成先决条件中的Docker环境准备即可

### LB服务(仅演示用途)

简单配置只需要使用nginx配置upstream即可，配置完负载均衡，需要把系统参数的GATEWAY_URL改成gateway的负载均衡地址

```
# gateway upstream
upstream gateway {
  server {{host_wecube1_ip}}:19110;
  server {{host_wecube2_ip}}:19110;
}

server {
  server_name _;
  listen 19110;
  location / {
    proxy_pass http://gateway;
    proxy_set_header Host $host;
    proxy_set_header User-Agent $http_user_agent;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
```

```
# portal upstream
upstream portal {
  server {{host_wecube1_ip}}:19090;
  server {{host_wecube2_ip}}:19090;
}

server {
  server_name _;
  listen 80;
  location / {
    proxy_pass http://portal;
    proxy_set_header Host $host;
    proxy_set_header User-Agent $http_user_agent;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
```



### 添加系统资源

需要正确添加mysql数据库，S3服务，docker主机服务到WeCube系统资源中，插件才能从资源中申请到实例，插件所需的实例写在插件包的register.xml文件中，但您无需担心，只要添加了资源，系统会自动进行实例分配。

Web页面：系统-资源管理

1. 添加mysql：{{mysql_plugin_host}}:{{mysql_plugin_port}}  {{mysql_auth_username}}/{{mysql_auth_password}}
2. 添加s3：{{s3_host}}:{{s3_port}} {{s3_access}}/{{s3_secret}}
3. 添加host：{{host_plugin1_ip}}:22 root/你的主机密码
4. 添加host：{{host_plugin2_ip}}:22 root/你的主机密码

### 安装插件包

首次使用插件请先登录S3服务(http://{主机IP}:9000)，创建bucket：wecube-plugin-package-bucket

插件包下载地址：https://github.com/WeBankPartners/wecube-platform/releases

下载的插件包可在 协同-插件注册 页面手动上传，上传完毕后确认注册，并手动运行

> 请留意！！
>
> 插件包仅包含运行所需软件，不一定包含正常体验所需的预置数据
>
> 比如CMDB插件包，上传运行后，其模型为空，流程编排中cmdb注册的插件接口服务也为空，旨在提供给需要自定义模型的用户，并根据自定义模型配置对应的插件接口服务。
>
> 若希望快速体验WeCube服务，可在Release中下载 **插件配置最佳实践** - [标准安装配置](https://github.com/WeBankPartners/wecube-platform/releases)
>
> 最佳实践的标准安装配置包含了**插件预置数据** & **插件预置数据对应的服务接口定义**
>
> **插件预置数据** 通常为sql，直接导入到对应的插件数据库中即可
>
> **插件预置数据对应的服务接口定义** 通常为xml，在插件管理页面中进行配置导入

到这里，您已经完成了WeCube的安装部署，请尽情体验吧。

## 卸载WeCube

如果您想要卸载已经安装的WeCube，或者想要使用不同的版本或插件配置方案来安装WeCube，请执行以下命令行指令来清除WeCube的运行组件和安装目录（默认为 `/data/wecube`，请根据您的实际情况对命令行指令进行调整）：

```bash
docker rm -f $(docker ps -a -q -f name=wecube -f name=open-monitor -f name=service-mgmt) && sudo rm -rfI /data/wecube
```


## 进一步了解

关于WeCube安装目录结构的详细信息，请参见文档“[WeCube安装目录结构](installation-directory-structure.md)”。
