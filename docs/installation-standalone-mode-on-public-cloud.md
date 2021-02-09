# 在公有云上以单机模式安装WeCube

在这里，我们将为您说明如何使用 [Terraform :fa-external-link:](https://www.terraform.io/){: target=\_blank} 在公有云上购买和创建资源、配置网络并在其之上安装以单机模式运行的WeCube。

## 安装Terraform

您需要 [下载最新稳定版本的Terraform :fa-external-link:](https://www.terraform.io/downloads.html){: target=\_blank}，将下载包中的terraform可执行文件解压并存放到环境变量`PATH`所包含的路径中。当然，您也可以把terraform可执行文件的存放目录直接添加到环境变量`PATH`之中。

!!! note "我们在此提供Terraform官方网站上0.12.24版本的下载链接，您可以根据情况选择下载。"
	[适用于macOS AMD64处理器的版本 :fa-external-link:](https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_darwin_amd64.zip)

	[适用于Linux AMD64处理器的版本 :fa-external-link:](https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip)

	[适用于Windows AMD64处理器的版本 :fa-external-link:](https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_windows_amd64.zip)

安装完毕后，请使用以下命令行指令进行验证：

``` bash
terraform version
```

## 安装WeCube

### 准备好您的公有云用户账号并确认安装的目标地域

在安装WeCube的过程中，Terraform会在公有云上创建并购买必要的网络、计算和存储资源，因此需要您确认以下事项：

- 您需要有一个可用的公有云用户账号，账号信息通常是以用于进行API调用的访问密钥的形式提供给Terraform使用的。
- 您需要决定在公有云的哪个地域（Region）来创建资源并安装WeCube。

您可以在环境变量中配置这些信息，Terraform将会在安装过程中自动读取您的配置。如果您没有在环境变量中进行配置，那么Terraform将在安装过程中向您询问这些信息。

!!! note "请根据您选择的公有云平台进行相应配置："
    === "腾讯云"
        | 环境变量名称 | 描述 |
        | - | - |
        | TENCENTCLOUD_SECRET_ID | 腾讯云API密钥的SecretId \* |
        | TENCENTCLOUD_SECRET_KEY | 腾讯云API密钥的SecretKey \* |
        | TENCENTCLOUD_REGION | 安装目标地域，默认为`ap-guangzhou`    |

        \* 通常，您可以在腾讯云控制台中的 [这个页面 :fa-external-link:](https://console.cloud.tencent.com/cam/capi){: target=\_blank} 找到您的API密钥信息。

    === "阿里云"
        | 环境变量名称 | 描述 |
        | - | - |
        | ALICLOUD_ACCESS_KEY | 阿里云AcccessKeyId \* |
        | ALICLOUD_SECRET_KEY | 阿里云AccessKeySecret \* |
        | ALICLOUD_REGION | 安装目标地域，例如`cn-hangzhou`, `cn-beijing` |

        \* 通常，您可以在阿里云控制台中的 [这个页面 :fa-external-link:](https://usercenter.console.aliyun.com/#/manage/ak){: target=\_blank} 找到您的AccessKey信息。

!!! warning "如有可能，请不要使用任何可以操作您敏感环境（如生产、预生产等）的API访问密钥，以免产生安全风险。"

### 下载WeCube安装脚本

请下载此处提供的 [WeCube安装脚本包](https://github.com/WeBankPartners/delivery-by-terraform/archive/master.zip) ，然后将其中唯一的目录`delivery-by-terraform-master`解压并存放到您选择的某个位置。

### 执行WeCube安装脚本

!!! info "提示"
    请注意，WeCube的安装过程需要在公有云上创建按量付费使用的云资源。因此，根据云平台的要求，您的账号中可能需要有一定的余额才能正常进行安装过程。

请在命令行中访问WeCube安装脚本包解压后的目录 `delivery-by-terraform-master`。

在上述目录中，请执行以下命令行指令来下载和安装Terraform与公有云平台进行交互时所需要的组件。

``` bash
terraform init

```

请继续执行以下命令行指令来使用默认的安装配置项开始WeCube的安装。您也可以对安装配置项进行自定义，详见下方说明。

``` bash
terraform apply

```

WeCube的安装配置项如下表所示，您可以通过编辑安装执行目录下的文件`variables.tf`来更改配置值。

| 配置项名称 | 默认值 | 用途说明 |
| - | - | - |
| install_target_host | *127.0.0.1* | WeCube安装的目标主机名称或IP地址<br/>（**请勿使用此默认值**，详见下方说明。） |
| wecube_release_version | *latest* | WeCube安装的目标版本，默认为最新发布版本 `latest`，可指定为某个特定版本，如 `v2.9.0` |
| wecube_settings | *bootcamp* | WeCube安装后的插件配置方案，默认为 上手指引配置 `bootcamp`，可指定为 标准安装配置 `standard` 或 空配置 `empty` |
| wecube_home | */data/wecube* | WeCube的安装目录 |
| initial_password | *Wecube@123456* | 安装目标主机的root账号密码，同时用于MySQL数据库root账号的初始密码 |
| use_mirror_in_mainland_china | *true* | 是否在安装过程中使用位于中国大陆的镜像站点进行加速：true - 是；其它值 - 否 |

!!! warning "请注意"

    由于当前版本的WeCube设计，**请勿使用**默认的本地回环地址127.0.0.1作为安装目标主机的IP地址。大部分情况下，您应当使用为主机分配的内网IP地址作为部署配置项`install_target_host`的输入值。

安装过程启动后，Terraform会输出将要创建的资源信息并等待您的确认，请在命令行输入`yes`以允许Terraform开始创建云资源并安装WeCube，如下所示：

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

!!! info "Terraform的状态文件"
    在安装执行过程中，Terraform会在安装执行目录生成文件`terraform.tfstate`，其中记录了它在云平台上创建的资源状态。建议您保留此文件，以便稍后在需要的时候使用它来销毁这些创建的云资源。

安装过程完成后，Terraform将输出如下内容：

```
Outputs:

wecube_website = http://<公网IP地址>:19090
```

请依据提示，使用默认的用户名 `umadmin` 和密码 `umadmin` 来访问安装好的WeCube。

### 销毁安装时创建的云资源

如果您不再需要在公有云上安装好的WeCube，您可以按照以下步骤使用Terraform来销毁之前创建的云资源。

请在命令行中访问WeCube安装脚本包解压后的目录 `delivery-by-terraform-master`。

在上述目录中，执行以下命令行指令来销毁在云上创建的资源：

``` bash
terraform destroy

```

## 进一步了解

关于WeCube安装目录结构的详细信息，请参见文档“[WeCube安装目录结构](installation-directory-structure.md)”。
