# 升级WeCube平台

### 安装方式

在升级之前，您需要确认当前WeCube平台是使用哪种方式进行安装部署，目前我们提供了3种形式的安装

1. 通过get-wecube.sh脚本在私有化环境安装
2. 通过Terraform在公有云环境安装
3. 手动离线部署

### 升级方式

#### 说明

安装方式1 & 2 均为标准安装目录，首先您需要找到安装主机上的/data/wecube/installer/wecube-platform文件夹

> 安装方式3 时yml文件理应由您手动编写，请找到yml文件并参照安装方式1 & 2的步骤进行参数更新，再进行更新部署即可

升级WeCube平台时，我们主要使用到文件夹中的2个文件

```
wecube-platform.docker-compose.env
docker-compose.yml
```

当WeCube新版本没有新增或修改环境变量时，只需要修改env文件再进行更新部署即可

当WeCube新版本有新增或修改环境变量时，需要先修改yml文件，并更新env文件，再进行更新部署

#### yml文件更新

请按照[WeCube版本环境变量变化记录](#anchor-history)进行yml文件的更新

#### env文件更新

```bash
[root@centos wecube-platform]# cat wecube-platform.docker-compose.env|grep v2.8.1
WECUBE_IMAGE_VERSION=v2.8.1
PORTAL_IMAGE_VERSION=v2.8.1
GATEWAY_IMAGE_VERSION=v2.8.1
AUTH_SERVER_IMAGE_VERSION=v2.8.1
```

将内容替换为要更新的版本号，比如：v2.9.1，您可以使用sed快速替换

```bash
sed -i "s/IMAGE_VERSION=v2.8.1/IMAGE_VERSION=v2.9.1/g" wecube-platform.docker-compose.env
```

更新容器

```bash
docker-compose -f docker-compose.yml --env-file=wecube-platform.docker-compose.env up -d
```



### WeCube版本环境变量变化记录

<span id = "anchor-history"></span>

| 版本   | docker服务    | 参数               | 类型 | 说明                                                         |
| ------ | ------------- | ------------------ | ---- | ------------------------------------------------------------ |
| v2.9.0 | platform-core | GATEWAY_HOST_PORTS | 新增 | GATEWAY_HOST_PORTS=IP1:19110,IP2:19110,IPn:19110，以逗号隔开的IP:PORT信息，用于控制集群双活版本的路由同步 |

