# 上手指引：了解可用的插件

现在，我们已经完成了WeCube的安装，可以准备开始使用WeCube来搭建云上的数据中心了。但在此之前，我们想先花一些时间来介绍您的WeCube平台上现有可用的插件。这些插件为WeCube提供了重要的功能扩展，我们相信了解这些插件对于您之后的操作会有很大的帮助，并且您也需要对其中一些插件进行简单的配置以使其正常工作。

## 浏览可用插件

请通过WeCube菜单项“**协同**” - “**插件注册**”进入插件管理页面，您可以在页面左侧找到当前在WeCube平台上已经注册可用的插件包列表：

- [WeCMDB配置管理插件 - `wecmdb`](plugin-wecmdb.md)

    用于管理数据中心和业务应用系统的设计和配置项信息，插件内部包含了一个可运行的WeCMDB版本；

- [腾讯云资源管理插件 - `qcloud`](plugin-qcloud.md)

    用于调用腾讯云API完成云资源的创建和删除等操作；

- [SaltStack运维自动化插件 - `saltstack`](plugin-saltstack.md)

    用于完成资源准备和应用部署等场景中涉及的自动化操作，插件内部包含了一个可运行的Saltstack版本；

- [物料管理插件 - `artifacts`](plugin-artifacts.md)

    用于管理业务应用系统的部署物料包；

- [监控管理插件 - `wecube-monitor`](plugin-open-monitor.md)

    用于实现对IT资源和业务应用的监控采集、规则配置和报警通知，插件内部包含了一个可运行的Prometheus版本；

- [服务管理插件 - `service-mgmt`](plugin-service-management.md)

    用于IT服务配置、服务请求和任务处理的工作台。


!!! note "**插件包**、**插件服务** 和 **服务方法**"

    WeCube插件是以 **插件包** 的形式进行封装并交付的，一个 **插件包** 中通常包含了由某个开发者提供的一组相关的 **插件服务**；**插件** 和 **插件包** 的说法基本上可以互换使用。比如，我们随WeCube平台一同提供了 `WeCMDB` 插件（包）、`Saltstack` 插件（包）、`Qcloud` 插件（包）等。

    每个 **插件服务** 通常对应着一种可被管理的IT资源，一个 **插件服务** 通常又会提供多个 **服务方法** 来实现对这个IT资源的不同操作。比如，在 `Qcloud` 插件（包）中，我们提供了对应私有网络资源的 `vpc` 插件服务和对应云服务器资源的 `vm` 插件服务。

    每个 **服务方法** 实际上对应着针对某种IT资源的一项特定操作，多个 **服务方法** 共同组成了 **插件服务** 针对这种IT资源提供的功能扩展。比如，之前提到的 `vpc` 插件服务实际上提供了 `create` 和 `terminate` 这两个服务方法分别来实现私有网络资源的创建和销毁。


## 为Qcloud插件配置腾讯云用户账号信息

为了使WeCube能够（通过Qcloud插件）连接到腾讯云进行云上数据中心资源的管理，请通过WeCube菜单项 “**系统**” - “**系统参数**” 进入系统参数管理页面。

- 请查找名称为“`QCLOUD_UID`”的系统参数，更改属性“**值**”为`您的用户账号Id`。
    
    *通常，您可以在腾讯云控制台中的 [这个页面](https://console.cloud.tencent.com/developer){: target=_blank} 找到您的用户账号信息。*

- 请查找名称为“`QCLOUD_API_SECRET`”的系统参数，更改属性“**值**”为您分配给WeCube使用的API密钥信息:

    ```
    SecretID=<WeCube的API密钥的SecretId>;SecretKey=<WeCube的API密钥的SecretKey>
    ```

    *通常，您可以在腾讯云控制台中的 [这个页面](https://console.cloud.tencent.com/cam/capi){: target=_blank} 找到您的API密钥信息。*

    !!! warning "请留意并谨慎评估您使用的API密钥所属的用户账号的权限设定，以免在后续使用和操作WeCube时为您现有的云上资产带来安全风险。"

## 进一步了解

关于插件使用的详细信息，请参见用户手册“[注册和配置插件](manual-plugin.md)”。