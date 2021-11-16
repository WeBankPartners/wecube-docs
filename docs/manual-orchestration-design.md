# 任务编排设计

## 功能菜单

WeCube界面导航包含任务、设计、执行、监测、智慧、调整、协同、系统共八个主菜单。

访问 “协同 > 任务编排” 菜单
![orchestration_menu](images/orchestration-configuration/orchestration_menu.png)

进入 “任务编排管理” 页面
![orchestration_main](images/orchestration-configuration/orchestration_main.png)

点击 “编排名称” 下拉选择框， 可以新增编排或者查看已经配置好的编排列表
![orchestration_search](images/orchestration-configuration/orchestration_search.png)

在编排下拉列表选中一个已经编排, 显示编排详细信息
![orchestration_search_result](images/orchestration-configuration/orchestration_search_result.png)

## 编排元素

在编排编辑页面中，除了显示当前选择编排节点和流程信息外， 还显示了编排可以使用的节点元素，见下图红框部分

![orchestration_config_item](images/orchestration-configuration/orchestration_config_item.png)

自上而下编排元素依次为：
	- 启动手动工具
	- 启动Lasso工具
	- 启动创建/删除空间工具
	- 启动全局连接工具
	- 创建StratEvent
	- 创建EndEvent

各元素详细说明是使用方式详见文档[camunda产品模型官网](https://camunda.com/products/modeler/)

## 新增编排

下面以 “删除MYSQL” 为例， 演示如何新增一个编排。

1. 新建编排

    点击右上方的"创建"按钮， 开始新建编排，弹出新建编排的权限配置页面，如下图所示：
    ![orchestration_new_auth_1](images/orchestration-configuration/orchestration_new_auth_1.png)

    页面上半部分的 “属主角色” 决定哪些角色的用户可以编辑、查看和使用该编排。角色清单是当前用户所拥有的角色。

    页面下半部分的 “使用角色” 决定哪些角色的用户可以查看和使用该编排， 但是无编排的编辑权限。

    配置完成后， 点击 “确定” 保存，权限配置页面关闭
    ![orchestration_new_auth_2](images/orchestration-configuration/orchestration_new_auth_2.png)

1. 编排编辑页面

    权限配置页面关闭后， 回到编排编辑页面
    ![orchestration_new_step_1](images/orchestration-configuration/orchestration_new_step_1.png)

      1. 标签：对编排的分类，可用于编排列表查询
      2. 冲突检测：当此编排所关联的节点数据与其他编排关联的节点数据存在交集有冲突时，(1)如果其他编排有勾选"冲突检测"，那么无论此编排是否勾选
         "冲突检测"，都无法执行；(2)如果其他编排都没有勾选"冲突检测"，那么此编排未勾选"冲突检测"，则可以执行；否则此编排不能执行

1. 选择编排对象类型

    在 “编排对象类型” 下拉框中选择编排关联的对象类型， 对象类型来源于各插件提供的数据模型。

    ![orchestration_new_step_2](images/orchestration-configuration/orchestration_new_step_2.png)

    本示例所演示的“删除MYSQL” 属于wecmdb的 “rdb_resource 资源实例类型。

1. 编排名称和版本

    在编排编辑页面右侧， 输入编排名称和版本名称，如下图：

    ![orchestration_new_step_3](images/orchestration-configuration/orchestration_new_step_3.png)

1. 配置编排流程节点

    - 在编排元素面板中，点击选中 “创建StratEvent”， 拖到画布空白处，如下图， 在开始节点右侧的小图标中选择 “可折叠子流程”

    ![orchestration_new_step_4](images/orchestration-configuration/orchestration_new_step_4.png)

    - 新增一个任务节点， 在右侧 “名称”输入框中输入节点名称，点击工具按钮，当前Task类型只支持“可折叠子流程”。

    ![orchestration_new_step_4_1](images/orchestration-configuration/orchestration_new_step_4_1.png)

    - 点击当前任务节点，在下面显示的菜单中进行插件配置

    ![orchestration_new_step_5](images/orchestration-configuration/orchestration_new_step_5.png)
     
    1. 插件类型：(1) 自动节点-该节点能够自动执行完成；(2) 人工节点-该节点需人工介入处理环节；(3) 数据写入节点-该节点会将数据写入定义的数据模型
    2. 动态绑定：当选择 "Y" 时，若"绑定节点"为空，执行到该任务节点时，则重新计算该节点需要绑定的数据；若"绑定节点"不为空，执行到该任务节点时，则使用选择的绑定节点所绑定的数据
    3. 高危检测：针对要执行的插件参数及模型实例，进行目标对象范围界定，若符合则使用其规则进行脚本内容的检测
    4. 定位规则：筛选节点插件
    5. 上下文参数：从该节点的上游节点中，选择此节点的根任务节点，并选择根任务节点的入参或出参，作为当前节点插件接口的入参
    6. 静态参数：配置当前节点插件接口入参中的静态参数

    - 在弹出页面中的 “插件” 下拉框中选择已注册的插件功能

    ![orchestration_new_step_6](images/orchestration-configuration/orchestration_new_step_6.png)

    - “确认” 保存

    ![orchestration_new_step_7](images/orchestration-configuration/orchestration_new_step_7.png)

    - 回到主编辑页面， 点击当前节点， 可以继续 “追加Task”

    ![orchestration_new_step_8](images/orchestration-configuration/orchestration_new_step_8.png)

    - 按同样的方式增加后续节点直到所有流程节点配置完成。注意插件节点中， 如果要使用前置节点的输出作为入参， 可以在插件配置中进行参数配置， 如下图

    ![orchestration_new_step_9](images/orchestration-configuration/orchestration_new_step_9.png)

    - 流程节点配置完成后， 最后新增一个结束节点 “创建EndEvent”

    ![orchestration_new_step_10](images/orchestration-configuration/orchestration_new_step_10.png)

    - 点击 “保存编排”，然后点击"发布"

    ![orchestration_new_step_11](images/orchestration-configuration/orchestration_new_step_11.png)

至此，已经新建了一个完整的编排。能在 “编排名称” 下拉列表中看到刚刚创建的编排。

![orchestration_new_step_12](images/orchestration-configuration/orchestration_new_step_12.png)


## 修改/删除编排

1. 删除编排

    在 “编排名称” 下拉列表中，点击删除按钮， 确认后可以删除编排。

    ![orchestration_del_1](images/orchestration-configuration/orchestration_del_1.png)

1. 修改编排权限信息

    在 “编排名称” 下拉列表中，点击编辑按钮

    ![orchestration_upd_1](images/orchestration-configuration/orchestration_upd_1.png)

    弹出权限修改页面

    ![orchestration_upd_2](images/orchestration-configuration/orchestration_upd_2.png)

    可以修改属主和使用权限。

1. 修改编排的详细信息

    在 “编排名称” 下拉列表中， 选择编排，

    ![orchestration_upd_3](images/orchestration-configuration/orchestration_upd_3.png)

    显示编排详细信息，可以进行编辑。

    ![orchestration_upd_4](images/orchestration-configuration/orchestration_upd_4.png)


## 编排导出

选择一个编排， 点击 “导出” 按钮，即可完成编排导出。

![orchestration_export](images/orchestration-configuration/orchestration_export.png)

## 编排导入

在任务编排主页面，点击 “导入” 按钮， 在弹出框中选择要导入的编排文件， 点击 “打开”

![orchestration_import_1](images/orchestration-configuration/orchestration_import_1.png)

即可完成编排导入，如下图

![orchestration_import_2](images/orchestration-configuration/orchestration_import_2.png)
