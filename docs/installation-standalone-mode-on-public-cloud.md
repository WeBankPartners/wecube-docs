# 在公有云上以单机模式安装WeCube

在这里，我们将为您说明如何使用 [Terraform :fa-external-link:](https://www.terraform.io/){: target=\_blank} 在公有云上购买和创建资源、配置网络并在其之上安装以单机模式运行的WeCube。

## 安装Terraform

您需要 [下载最新稳定版本的Terraform :fa-external-link:](https://www.terraform.io/downloads.html){: target=\_blank}，将下载包中的terraform可执行文件解压并存放到环境变量`PATH`所包含的路径中。当然，您也可以把terraform可执行文件的存放目录直接添加到环境变量`PATH`之中。

!!! note "我们在此提供Terraform官方网站上0.12.24版本的下载链接，您可以根据情况选择下载。"
	[适用于macOS AMD64处理器的版本 :fa-external-link:](https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_darwin_amd64.zip){: target=\_blank}

	[适用于Linux AMD64处理器的版本 :fa-external-link:](https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip){: target=\_blank}

	[适用于Windows AMD64处理器的版本 :fa-external-link:](https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_windows_amd64.zip){: target=\_blank}

安装完毕后，请使用以下命令行指令进行验证：

``` bash
terraform version

```

## 安装WeCube

### 准备好您的公有云用户账号并确认安装的目标地域和可用区

在安装WeCube的过程中，Terraform会在公有云上创建并购买必要的网络、计算和存储资源，因此需要您确认以下事项：

1. 您需要有一个可用的公有云用户账号，账号信息通常是以用于进行API调用的 **访问密钥（Access Key）** 的形式提供给Terraform使用的。
1. 您需要决定在公有云的哪个 **地域（Region）** 和其中的哪个 **可用区（Availability Zone）** 来创建资源并安装WeCube。

!!! question "在哪里可以找到这些信息？"
    === "腾讯云"
        1. 关于 **访问密钥**

            通常，您可以在 [腾讯云控制台的这个页面 :fa-external-link:](https://console.cloud.tencent.com/cam/capi){: target=\_blank} 找到您的访问密钥信息。

            您需要关注的是页面中显示的 **SecretId** 和 **SecretKey**。

        1. 关于 **地域** 与 **可用区**

            通常，您可以在 [腾讯云文档中心站点的这个页面 :fa-external-link:](https://cloud.tencent.com/document/product/213/6091){: target=\_blank} 找到地域与可用区的信息。

    === "阿里云"
        1. 关于 **访问密钥**

            通常，您可以在 [阿里云控制台的这个页面 :fa-external-link:](https://usercenter.console.aliyun.com/#/manage/ak){: target=\_blank} 找到您的访问密钥信息。

            您需要关注的是页面中显示的 **AccessKey ID** 和 ** AccessKey Secret**。

        1. 关于 **地域** 与 **可用区**

            通常，您可以在 [阿里云帮助文档站点的这个页面 :fa-external-link:](https://help.aliyun.com/document_detail/188196.html){: target=\_blank} 找到地域与可用区的信息。

    === "AWS"
        1. 关于 **访问密钥**

            通常，您可以在 [AWS控制面板的这个页面 :fa-external-link:](https://console.aws.amazon.com/iam/home#/security_credentials){: target=\_blank} 找到您的访问密钥信息。

            您需要关注的是页面中显示的 **访问密钥(访问密钥 ID 和秘密访问密钥)**。

        1. 关于 **地域** 与 **可用区**

            通常，您可以在 [AWS文档站点的这个页面 :fa-external-link:](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html){: target=\_blank} 找到地域与可用区的信息。

!!! warning "如有可能，请不要使用任何可以操作您敏感环境（如生产、预生产等）的访问密钥，以免产生安全风险。"

### 下载WeCube安装脚本

请从 [此GitHub站点 :fa-external-link:](https://github.com/WeBankPartners/delivery-by-terraform/archive/master.zip){: target=\_blank} 或者 使用 [此Gitee镜像站点 :fa-external-link:](https://gitee.com/WeBankPartners/delivery-by-terraform/repository/archive/master.zip){: target=\_blank} 下载WeCube安装脚本包，将其存放到安装有Ansible的执行机器的本地磁盘并对安装包进行解压缩。

### 调整安装配置项

WeCube的安装配置项如下表所示，您可以通过编辑安装执行目录下的文件 `variables.tf` 来更改这些配置值。

| 配置项名称 | 默认值 | 用途说明 |
| - | - | - |
| cloud_provider | *TencentCloud* | WeCube安装使用的云平台提供商，默认为腾讯云 `TencentCloud` |
| secret_id | | WeCube安装使用的云平台用户账号访问密钥Id，根据您所使用的云平台提供商，它可能会有其它名称 |
| secret_key | | WeCube安装使用的云平台用户账号访问密钥Secret，根据您所使用的云平台提供商，它可能会有其它名称 |
| region | | WeCube安装的目标地域 |
| availability_zones | | WeCube安装的目标可用区，在单机模式下，您只需指定1个可用区; 在集群模式下，您需要指定2个可用区 |
| wecube_release_version | *latest* | WeCube安装的目标版本，默认为最新发布版本 `latest`，可指定为某个特定版本，如 `v2.9.0` |
| wecube_settings | *standard* | WeCube安装后的插件配置方案，默认为 标准安装配置 `standard`，可指定为 上手指引配置 `bootcamp` 或 空配置 `empty` |
| wecube_home | */data/wecube* | WeCube的安装目录 |
| wecube_user | *wecube* | WeCube运行使用的用户 |
| initial_password | *Wecube@123456* | 安装目标主机的root账号密码，同时用于MySQL数据库root账号的初始密码 |
| use_mirror_in_mainland_china | *true* | 是否在安装过程中使用位于中国大陆的镜像站点进行加速：true - 是；其它值 - 否 |

请根据您的需要更改这些安装配置项，如果您没有为所有必需的配置项提供值，在启动安装时Terraform将会提醒您补充这些配置项对应的输入变量。

!!! note "关于Terraform的输入变量"

    事实上，您也可以选择诸如 定义单独的变量输入文件 或 使用环境变量 等其它方式来为Terraform提供WeCube安装配置项对应的输入变量，如果有需要，可以参阅 [此站点 :fa-external-link:](https://www.terraform.io/docs/language/values/variables.html){: target=\_blank}。

### 执行WeCube安装脚本

!!! info "提示"
    请注意，WeCube的安装过程需要在公有云上创建按量付费使用的云资源。因此，根据云平台的要求，您的账号中可能需要有一定的余额才能正常进行安装过程。

请在命令行中访问WeCube安装脚本包解压后生成的目录。

在上述目录中，请执行以下命令行指令来下载和安装Terraform与公有云平台进行交互时所需要的组件。

``` bash
terraform init

```

请继续执行以下命令行指令来开始WeCube的安装。

``` bash
terraform apply

```

安装过程启动后，Terraform会输出将要创建的资源信息并等待您的确认，请在命令行输入`yes`以允许Terraform开始创建云资源并安装WeCube，如下所示：

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

!!! info "Terraform的状态文件"

    在安装执行过程中，Terraform会在安装执行目录生成文件`terraform.tfstate`，其中记录了它在云平台上创建的资源状态。您需要保留此文件，以便稍后在需要的时候使用它来销毁这些创建的云资源。

安装过程完成后，Terraform将输出如下内容：

```
Outputs:

wecube_website = http://<公网IP地址>:19090
```

请依据提示，使用默认的用户名 `umadmin` 和密码 `umadmin` 来访问安装好的WeCube。

### 卸载WeCube并销毁安装时创建的云资源

如果您想要卸载已经安装的WeCube，您可以按照以下步骤使用Terraform来销毁之前创建的云资源。

请在命令行中访问WeCube安装脚本包解压后生成的目录，执行以下命令行指令来销毁在云上创建的资源：

``` bash
terraform destroy

```

## 进一步了解

关于WeCube安装目录结构的详细信息，请参见文档“[WeCube安装目录结构](installation-directory-structure.md)”。
