# 用户角色与画像

为了帮助您更好地了解不同类型的用户如何使用WeCube来完成他们的日常工作，我们在这里列举了一些典型的WeCube用户角色，并且进一步基于每一类用户典型的工作内容和使用场景来介绍他们在WeCube中会经常使用到的功能特性。

这些用户角色仅仅是我们在设计产品时给出的参考建议，为了帮助您更好的理解产品的功能划分。在您的组织中，这些用户角色可能会分散在不同的团队、部门甚至不同的业务或行政实体之中；当然，也可能会出现同一个团队成员肩负多个不同角色的情况。


### WeCube平台管理员

WeCube平台管理员负责完成WeCube平台和插件的安装与配置，同时也负责用户和权限体系的管理。通常来讲，WeCube平台管理员会经常使用以下功能特性：

- **系统** / **[系统参数](manual-system-settings.md)**

    WeCube平台管理员可以使用 **[系统参数](manual-system-settings.md)** 功能来调整WeCube平台和插件的各类配置参数。

- **系统** / **[资源管理](manual-resource-management.md)**

    WeCube平台管理员可以使用 **[资源管理](manual-resource-management.md)** 功能来调整和配置WeCube平台上为插件正常运行而准备的资源环境。

- **系统** / **[权限管理](manual-permission-management.md)**

    WeCube平台管理员可以使用 **[权限管理](manual-permission-management.md)** 功能来管理用户和用户角色，并基于用户角色对功能访问进行授权。

- **协同** / **[插件注册](manual-plugin.md)**

    WeCube平台管理员可以使用 **[插件注册](manual-plugin.md)** 功能来注册和配置新的插件并管理现有插件的服务配置信息和运行环境等。


### CMDB系统管理员

CMDB系统管理员负责CMDB模型和基础数据的管理与维护。通常来讲，CMDB系统管理员会经常使用以下功能特性：

- **系统** / **[CMDB模型管理](manual-cmdb-model.md)**

    CMDB系统管理员可以使用 **[CMDB模型管理](manual-cmdb-model.md)** 功能来管理和维护包括数据类型、数据属性、数据关系、模型层次、模型视角等在内的CMDB模型要素。

- **系统** / **[CMDB基础数据管理](manual-cmdb-enumerations.md)**

    CMDB系统管理员可以使用 **[CMDB基础数据管理](manual-cmdb-enumerations.md)** 功能来维护作为CMDB系统基础数据的枚举数据类型。

- **系统** / **[CMDB数据权限管理](manual-cmdb-data-permission.md)**

    CMDB系统管理员可以使用 **[CMDB数据权限管理](manual-cmdb-data-permission.md)** 功能来针对CMDB模型数据类型及数据记录的增、删、改、查、执行等操作进行基于用户角色的授权控制。

- **系统** / **[CMDB日志查询](manual-cmdb-logging.md)**

    CMDB系统管理员可以使用 **[CMDB日志查询](manual-cmdb-logging.md)** 功能来检索所有针对CMDB模型和数据的操作审核日志内容。


### 监控系统管理员

监控系统管理员负责监控对象分组、监控指标、告警规则等的管理与维护。通常来讲，监控系统管理员会经常使用以下功能特性：

- **监测** / **指标配置**

    监控系统管理员可以使用 **指标配置** 功能来管理和调整监控对象的指标定义。

- **监测** / **告警配置**

    监控系统管理员可以使用 **告警配置** 功能来管理监控对象的分组，并且可以对监控对象和分组配置基于阈值或关键字的告警规则。


### 企业架构师 - IT基础设施架构设计

企业架构师负责企业范围内IT基础设施整体架构的设计，包括物理机房、网络空间以及适用于业务流程和应用系统的资源类型定义和资源分组划分原则等；因此，企业架构师会使用以下功能特性：

- **设计** / **[资源视图 - 规划设计](manual-cmdb-view-resource-planning.md)**

    负责IT基础设施架构设计的企业架构师可以使用 **[资源视图 - 规划设计](manual-cmdb-view-resource-planning.md)** 功能来管理企业IT数据中心的规划设计蓝图，以便在建设新的数据中心时，能够以标准的规划设计蓝图为模板快速实现。


### 基础设施架构师与管理员 - 网络资源

专注于网络资源的基础设施管理员负责规划和管理数据中心的网络空间区域、网络设备资源、IP地址空间并分配IP地址资源等；因此，他们会使用以下功能特性：

- **设计** / **[资源视图 - 资源管理](manual-cmdb-view-resource-management.md)**

    基础设施管理员可以使用 **[资源视图 - 资源管理](manual-cmdb-view-resource-management.md)** 功能来聚焦查看和维护数据中心内的网络空间区域、网段划分、IP地址分配、路由规则、安全规则等网络资源相关信息。

### 基础设施架构师与管理员 - 主机资源（计算和存储）

专注于主机相关资源的基础设施管理员负责在已规划好的网络区域内维护各种计算和存储资源，如虚拟机资源实例、容器集群、数据库资源实例、分布式缓存资源实例、负载均衡资源实例、分布式存储资源等；因此，他们会使用以下功能特性：

- **设计** / **[资源视图 - 资源管理](manual-cmdb-view-resource-management.md)**

    基础设施管理员可以使用 **[资源视图 - 资源管理](manual-cmdb-view-resource-management.md)** 功能来聚焦查看和维护数据中心内的各种计算和存储资源相关信息。

- **监测** / **对象视图**

    基础设施管理员可以使用 **对象视图** 功能来关注特定资源实例的监控指标数据。


### 应用系统架构师

应用系统架构师负责设计业务应用系统的逻辑架构，并定义应用系统被部署到运行环境之中后体现形成的物理架构。通常来讲，应用系统架构师会经常使用以下功能特性：

- **设计** / **[应用视图 - 架构设计](manual-cmdb-view-application-architecture.md)**

    应用系统架构师可以使用 **[应用视图 - 架构设计](manual-cmdb-view-application-architecture.md)** 功能来维护和管理应用系统的逻辑架构，描述应用系统的组成构件以及系统组件之间的关系等。

- **设计** / **[应用视图 - 部署管理](manual-cmdb-view-deployment-management.md)**

    应用系统架构师可以使用 **[应用视图 - 部署管理](manual-cmdb-view-deployment-management.md)** 功能来维护和管理在将应用系统部署到运行环境的视角时所形成的物理架构，描述应用系统各组件在部署时应当映射到运行环境中的资源集合以及具体的资源数量需求等。


### 应用开发团队

应用开发团队为应用系统各组件提供功能实现所需的构建物料包，并根据各系统组件的具体需要定义自动化部署流程。通常来讲，应用开发团队会经常使用以下功能特性：

- **执行** / **[应用物料管理](manual-application-artifacts.md)**

    应用开发团队可以使用 **[应用物料管理](manual-application-artifacts.md)** 功能来为应用系统组件提供构建物料包，并为这些物料包配置在部署时需要进行替换使用的差异化配置变量。

- **设计** / **[应用视图 - 部署管理](manual-cmdb-view-deployment-management.md)**

    应用开发团队可以使用 **[应用视图 - 部署管理](manual-cmdb-view-deployment-management.md)** 功能来为在具体运行环境中的应用系统组件实例指定部署时应当使用的构建物料包。

- **协同** / **[任务编排设计](manual-orchestration-configuration.md)**

    应用开发团队可以使用 **[任务编排设计](manual-orchestration-configuration.md)** 功能来维护和检视整个应用系统的部署流程，通过在流程中配置包含插件调用的自动化步骤、嵌入审批或人工节点来设计满足组织要求的部署流程。

- **执行** / **[任务编排执行](manual-orchestration-execution.md)**

    应用开发团队可以使用 **[任务编排执行](manual-orchestration-execution.md)** 功能来调度执行已经设计好的任务编排，从而完成应用系统在开发和测试环境的部署。


### 验收/预生产环境应用运维

验收环境或预生产环境应当作为上线前业务或用户部门验证应用系统功能最终环节的运行环境，应用运维应当保证环境的部署过程尽可能接近生产环境；因此，这些环境的应用运维会使用以下功能特性：

- **设计** / **[应用视图 - 部署管理](manual-cmdb-view-deployment-management.md)**

    应用运维可以使用 **[应用视图 - 部署管理](manual-cmdb-view-deployment-management.md)** 功能来为在相应运行环境中的应用系统组件实例指定部署时应当使用的构建物料包。

- **协同** / **[任务编排设计](manual-orchestration-configuration.md)**

    应用运维可以使用 **[任务编排设计](manual-orchestration-configuration.md)** 功能来维护和检视整个应用系统的部署流程，通过在流程中配置包含插件调用的自动化步骤、嵌入审批或人工节点来设计满足组织要求的部署流程。

- **执行** / **[任务编排执行](manual-orchestration-execution.md)**

    应用运维可以使用 **[任务编排执行](manual-orchestration-execution.md)** 功能来调度执行已经设计好的任务编排，从而完成应用系统在验收环境或预生产环境的部署。


### 生产环境应用运维

生产环境应用运维应当永远仅使用已经通过功能验证的应用构建物料包和已经在预生产环境中验证过的部署流程来对生产环境进行部署操作；因此，生产环境的应用运维会使用以下功能特性：

- **设计** / **[应用视图 - 部署管理](manual-cmdb-view-deployment-management.md)**

    生产环境应用运维可以使用 **[应用视图 - 部署管理](manual-cmdb-view-deployment-management.md)** 功能来为在生产环境中运行应用系统组件实例指定已经经过验证的在部署时应当使用的构建物料包。

- **协同** / **[任务编排设计](manual-orchestration-configuration.md)**

    生产环境应用运维可以使用 **[任务编排设计](manual-orchestration-configuration.md)** 功能来维护和检视整个应用系统的部署流程，通过在流程中配置包含插件调用的自动化步骤、嵌入审批或人工节点来设计满足组织要求的部署流程。

- **执行** / **[任务编排执行](manual-orchestration-execution.md)**

    生产环境应用运维可以使用 **[任务编排执行](manual-orchestration-execution.md)** 功能来调度执行已经设计好的任务编排，从而完成应用系统在生产环境的部署。
