# 注册和配置插件

点击菜单“协同 > 插件注册”打开插件注册页面。

![plugin_menu](images/plugin/plugin_menu.png)

## 上传插件包

1. 点击插件注册页面左上角的“上传插件包”按钮，在弹出框选择插件包上传。

    注：同名同版本的插件包不允许重复上传。

    ![plugin_upload_new](images/plugin/plugin_upload_new.png)

1. 上传成功的插件包在插件包列表中显示。

    ![plugin_list](images/plugin/plugin_list.png)

## 插件配置查看

点击插件列表左侧的箭头展开插件功能按钮，点击“插件配置”按钮进行配置查看，页面的右侧展示插件的配置信息。

![plugin_config_new](images/plugin/plugin_config_new.png)

### 依赖分析

1. “依赖分析”展示本插件包与其他插件包之间的依赖关系图。

    ![plugin_config_relation](images/plugin/plugin_config_relation.png)

### 菜单注入

1. "菜单注入"展示本插件在WeCube主菜单下注入的子菜单列表。

    ![plugin_regist_menu](images/plugin/plugin_regist_menu.png)

### 数据模型

1. "数据模型"展示本插件在WeCube系统中已应用的数据模型。

    ![plugin_model](images/plugin/plugin_model.png)

### 系统参数

1. “系统参数”展示本插件在WeCube系统注册的系统参数列表。

    ![plugin_system_params](images/plugin/plugin_system_params.png)

### 权限设定

1. "权限设定"展示本插件配置的角色操作菜单的权限。

    ![plugin_permission](images/plugin/plugin_permission.png)

### 运行资源

1. “运行资源”展示"本插件运行容器、数据库和对象存储的配置信息。

    ![plugin_resources](images/plugin/plugin_resources.png)

## 插件配置确认

1. 在插件配置的“确认”页面点击“确认注册插件包”按钮进行插件配置的注册确认。

    注：如果插件提供UI界面，确认插件后需刷新页面加载插件注册的菜单。

    ![plugin_confirm](images/plugin/plugin_confirm.png)

## 运行管理

点击插件包的“运行管理”按钮打开运行管理页面。

![plugin_run_manage](images/plugin/plugin_run_manage.png)

### 运行容器

注：插件运行所需的资源需要在“系统 > 资源管理”页面提前录入，如容器主机、数据库主机、S3服务器等。

![resources_management](images/plugin/resources_management.png)

1. 在运行管理的服务器下拉框选择插件运行的服务器。

1. 点击“端口预览”按钮查看服务器上可用的端口。

1. 点击“创建”按钮在服务器上运行插件。

    ![plugin_run](images/plugin/plugin_run.png)

1. 插件运行成功后在页面显示”运行节点“的信息，点击“销毁”按钮可销毁插件运行。

    ![plugin_destroy_new](images/plugin/plugin_destroy_new.png)

### 数据库

1. 在输入框输入数据库查询语句。

1. 点击“执行”按钮。

1. 在搜索结果查看返回的数据。

    > 内置SQL注入拦截，并且仅允许select查询语句的执行，请放心使用
    
    ![plugin_db](images/plugin/plugin_db.png)

### 对象存储

1. 查看对象存储信息。

    ![plugin_object](images/plugin/plugin_object.png)

## 数据模型的同步与应用

### 同步数据模型

1. 在插件配置的“数据模型”页面，点击“同步数据模型”按钮可以将插件包最新的数据模型以数据模型关系图展示，每次同步后版本号递增。

    注：以CMDB插件为例，“同步数据模型”功能需在CMDB插件已确认并运行后才可以操作。

    ![plugin_model_sync](images/plugin/plugin_model_sync.png)



## 服务注册

点击插件包的“服务注册”按钮打开服务注册管理页面。页面展示本插件的服务接口列表。一个插件服务可配置多个注册服务列表以供各种场景灵活使用。

![plugin_services_manage](images/plugin/plugin_services_manage.png)

### 新增注册列表

1. 点击插件的服务右侧的加号按钮进行添加。

    ![plugin_services](images/plugin/plugin_services.png)

1. 配置插件服务的授权角色，点击确定。

    ![plugin_service_add](images/plugin/plugin_service_auth.png)

1. 输入注册名称，选择目标对象类型。目标对象类型下拉列表包含WeCube系统已注册并运行插件对象，如任务管理插件的任务、CMDB插件的CI类型等。如果目标对象类型不指定则作用于WeCube系统的所有插件对象。

    ![plugin_service_config](images/plugin/plugin_service_config.png)

1. 配置插件接口的属性。属性类型分为4种类型context、entity、system variable和constant。

    ![plugin_service_param_type](images/plugin/plugin_service_param_config.png)

    ![plugin_service_param_type](images/plugin/plugin_service_param_type.png)

    1）配置插件接口的属性类型为context，在任务编排配置时该接口的属性参数可以从编排的其他任务的输入或输出参数获取。

    2）配置插件接口的属性类型为entity，可在属性配置框输入由根目标对象类型为起点关联的CI属性。输入"\~"弹出根目标对象被引用的其他CI类型列表，输入“."可弹出本对象的CI属性列表进行配置。

    3）配置插件接口的属性类型为"system variable"，可在属性配置列表选择已在WeCube系统注册的系统参数。

    4）配置插件接口的属性类型为“constant”，在任务编排配置时该接口的属性参数可以通过文本输入框输入常量值。

    配置完成后点击确定关闭配置框。

1. 点击“保存”按钮保存插件服务列表的配置信息。

![plugin_service_save](images/plugin/plugin_service_save.png)

6. 点击“注册”按钮注册插件服务列表。

![plugin_service_regist](images/plugin/plugin_service_regist.png)



### 注销注册列表

1. 点击插件的服务，在页面右侧选择已注册的列表，点击“注销”按钮注销服务。

![plugin_service_decom](images/plugin/plugin_service_decom.png)


### 批量注册/注销列表

点击“批量注册”快速注册/注销插件服务列表。

![plugin_service_regist_multi](images/plugin/plugin_service_regist_multi.png)

![plugin_service_regist_multi_confirm](images/plugin/plugin_service_regist_multi_comfirm.png)



## 停用插件包

1. 打开插件包的运行管理页面，点击“销毁”按钮停用插件运行节点。

![plugin_destroy_new](images/plugin/plugin_destroy_new.png)

1. 在插件注册页面的插件包右侧点击删除按钮，在确认弹出框点击“确定”按钮。

    ![plugin_package_stop](images/plugin/plugin_package_stop.png)

注：如果该插件包已注册了UI界面子菜单，需刷新页面更新WeCube系统已删除的子菜单。

1. 勾选“显示停用插件包”，可查看所有的插件包列表，包括已停用的。

![plugin_packages_all](images/plugin/plugin_packages_all.png)
