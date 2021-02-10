# 在私有资源上以集群模式安装WeCube

在这里，我们将为您说明如何在您自己的机器资源上安装以集群模式运行的WeCube。


## 先决条件

### 硬件资源

我们建议您按照下表中的规格需求为WeCube在集群模式下的正常运行准备资源：

| 分组名称 | 用途 | 数量 | 规格 |
| - | - | - | - |
| platform_server | WeCube平台应用服务器 | 2 | CPU：2核<br /> 内存：8GB<br /> 存储：50GB<br />系统：CentOS 7.2+ |
| platform_db_server | WeCube平台数据库服务器| 1 | CPU：4核<br /> 内存：8GB<br /> 存储：100GB<br />系统：CentOS 7.2+ |
| platform_s3_server | WeCube对象存储服务器| 1 | CPU：2核<br /> 内存：4GB<br /> 存储：100GB<br />系统：CentOS 7.2+ |
| plugin_hosting_server | WeCube插件应用服务器 | 2 | CPU：4核<br /> 内存：16GB<br /> 存储：50GB<br />系统：CentOS 7.2+ |
| plugin_db_server | WeCube插件数据库服务器| 1 | CPU：4核<br /> 内存：8GB<br /> 存储：100GB<br />系统：CentOS 7.2+ |
| lb_server | WeCube负载均衡服务器| 2 | CPU：1核<br /> 内存：1GB<br /> 存储：20GB<br />系统：CentOS 7.2+ |


### 系统和软件资源

#### CentOS 7

WeCube的运行仅仅依赖于Docker，但是安装脚本是基于CentOS制作的。所以，请在安装了 **CentOS 7（7.2或以上版本）** 的Linux服务器上来安装WeCube。

#### Docker

如果您希望使用我们提供的缺省设置的Docker安装版本，**您可以跳过此节的内容**，在WeCube的安装过程将会检查并根据需要自动安装Docker。

如果您希望在服务器上自行安装和设置Docker，请参阅 [此链接指向的章节内容](installation-standalone-mode-on-premises.md#docker)。

#### Ansible

为了方便您对私有资源进行规划，我们使用了 [Ansible :fa-external-link:](https://docs.ansible.com/core.html) 的资产清单（Inventory）、服务器分组以及角色等功能来帮助进行WeCube的安装。所以，您需要使用一台安装了 **最新稳定版本的Ansible** 的机器来执行WeCube的安装，请参阅 [此链接所指向的站点 :fa-external-link:](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html){: target=\_blank} 来获取安装信息和指引。

您也可以考虑使用准备好的私有资源中的一台服务器来执行WeCube的安装，我们建议您使用即将作为WeCube负载均衡服务器的 `lb_server` 中的一台。您可以使用以下命令行指令在CentOS 7上安装Ansible：

```bash
sudo yum install -y epel-release
sudo yum install -y ansible

```

安装完成后，您可以使用以下命令行指令来确认Ansible的运行情况：

``` bash
ansible --version

```

如果以上指令的版本信息输出一切正常，那么恭喜，我们现在就可以开始配置并安装WeCube了。


## 安装WeCube

### 获取安装脚本

请从 [此GitHub站点 :fa-external-link:](https://github.com/WeBankPartners/delivery-by-terraform/archive/master.zip){: target=\_blank} 或者 使用 [此Gitee镜像站点 :fa-external-link:](https://gitee.com/WeBankPartners/delivery-by-terraform/repository/archive/master.zip){: target=\_blank} 下载WeCube安装脚本包，将其存放到安装有Ansible的执行机器的本地磁盘并对安装包进行解压缩。


### 规划资源

进入WeCube安装包解压后生成的目录，打开其中的 `ansible-playbooks` 子目录下的 `hosts` 文件。请依照 [硬件资源](#_2) 中的规格需求对您的私有机器资源进行规划，并将分配好用途的各服务器的私有IP地址填入到 `hosts` 文件中与其分组名称对应的章节部分中，如下所示：

```ini
[platform_server]
192.168.100.103
192.168.100.104

[platform_db_server]
192.168.100.105

[platform_s3_server]
192.168.100.106

[plugin_hosting_server]
192.168.100.107
192.168.100.108

[plugin_db_server]
192.168.100.109

[lb_server]
192.168.100.101 lb_vip=192.168.100.100 lb_vip_mask=20 lb_interface=eth0 lb_state=MASTER lb_priority=150 lb_peer=192.168.100.102
192.168.100.102 lb_vip=192.168.100.100 lb_vip_mask=20 lb_interface=eth0 lb_state=BACKUP lb_priority=100 lb_peer=192.168.100.101

[config_server]
192.168.100.101

```

!!! info "对分组 lb_server 中额外配置属性的说明"

    `lb_server` 分组中包含2台负载均衡服务器，除了服务器的私有IP地址之外，您还需要对负载均衡服务器进行额外配置，如下所示：

    | 配置属性 | 示例配置值 | 用途说明 |
    | - | - | - |
    | lb_vip | 192.168.100.100 | 负载均衡集群的虚拟IP地址 |
    | lb_vip_mask | 20 | 负载均衡集群的虚拟IP地址的网络掩码 |
    | lb_interface | eth0 | 负载均衡集群虚拟IP地址被指定的网络接口设备名称 |
    | lb_state | MASTER | 负载均衡服务器上的keepalived VRRP实例的初始状态，可指定为 `MASTER` 或 `BACKUP` |
    | lb_priority | 150 | 负载均衡服务器上的keepalived VRRP实例的初始优先级，可指定为 `0` 到 `255` 中的任意整数 |
    | lb-peer | 192.168.100.102 | 负载均衡服务器上的keepalived VRRP实例的状态同步目标IP地址，即另一台负载均衡服务器的私有IP地址 |

!!! info "对分组 config_server 的说明"

    `config_server` 分组中需要指定一台服务器来执行WeCube组件安装完成后的系统配置过程，建议您指定 `lb_server` 分组中的负载均衡服务器中的其中任意一台。


### 调整安装配置项

当您完成对私有资源的规划之后，请进入WeCube安装包解压后生成的目录，打开其中的 `ansible-playbooks/group_vars` 子目录下的 `all` 文件，并根据需要调整其中的安装配置项。

| 配置项名称 | 默认值 | 用途说明 |
| - | - | - |
| wecube_release_version | *latest* | WeCube安装的目标版本，默认为最新发布版本 `latest`，可指定为某个特定版本，如 `v2.9.0` |
| wecube_settings | *standard* | WeCube安装后的插件配置方案，默认为 标准安装配置 `standard`，可指定为 上手指引配置 `bootcamp` 或 空配置 `empty` |
| wecube_home | */data/wecube* | WeCube的安装目录 |
| wecube_user | *wecube* | WeCube运行使用的用户 |
| initial_password | *Wecube@123456* | 安装目标主机的root账号密码，同时用于MySQL数据库root账号的初始密码 |
| use_mirror_in_mainland_china | *true* | 是否在安装过程中使用位于中国大陆的镜像站点进行加速：true - 是；其它值 - 否 |


### 执行安装WeCube脚本

请进入WeCube安装包解压后生成的目录中的 `ansible-playbook` 子目录，并使用以下命令行指令开始执行WeCube的安装：

```bash
ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -i hosts wecube.yml

```

!!! notes "Ansible到目标服务器的SSH连接配置"

    当您使用以上命令行指令时，Ansible将会使用当前登录用户通过SSH连接到目标服务器。您可以根据需要，改变Ansible连接到目标服务器的方式：

    - 如果您希望连接时使用其它用户（如 `deployer`），请为 `ansible-playbook` 指定 `-u deployer` 选项，例如

        ```bash
        ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -u deployer -i hosts wecube.yml

        ```

    - 如果您希望连接时使用其它用户（如 `deployer`）并需要手动输入用户密码，请为 `ansible-playbook` 指定 `-u deployer` 和 `-k` 选项，例如

        ```bash
        ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -u deployer -k -i hosts wecube.yml

        ```

    - 如果您希望连接时使用非对称密钥对进行身份验证，请为 `ansible-playbook` 指定 `--private-key PRIVATE_KEY_FILE` 或 `--key-file PRIVATE_KEY_FILE` 选项，例如

        ```bash
        ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook --private-key ~/.ssh/id_rsa -i hosts wecube.yml

        ```

    - 您可以进一步参阅 [此站点](https://docs.ansible.com/ansible/latest/user_guide/connection_details.html) 或通过执行命令行指令 `ansible --help` 来获取关于设置Ansible如何连接到目标服务器的详细信息。


安装脚本执行完成后，请使用默认的用户名 `umadmin` 和密码 `umadmin` 通过 **负载均衡集群的虚拟IP地址** 及 **端口19090** 来访问安装好的WeCube，例如：[http://192.168.100.100:19090](http://192.168.100.100:19090)。


## 卸载和重新安装WeCube

如果您想要卸载已经安装的WeCube，或者想要使用不同的版本或插件配置方案来安装WeCube，请进入WeCube安装包解压后生成的目录中的 `ansible-playbook` 子目录，执行以下命令行指令来清除WeCube的运行组件和安装目录：

```bash
ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -i hosts uninstall.yml

```


## 进一步了解

关于WeCube安装目录结构的详细信息，请参见文档“[WeCube安装目录结构](installation-directory-structure.md)”。
