# 应用架构视图

在应用架构视图页面中，您可以维护和管理业务应用系统的逻辑架构和服务调用的设计方案。

在选择了一个已有业务应用系统设计方案后，您可以在页面上看到该系统设计方案中包含的逻辑架构图、服务调用图以及构成设计方案的CI数据对象，点击变更进行数据的修改，修改完毕后可以进行统一定版操作。

## 逻辑架构图视角

在逻辑架构图视角中，您可以看到页面左侧将以图形方式展现出业务应用系统的逻辑功能组件（如系统、子系统、单元、服务等）及它们之间的关系，如下图所示：

[![逻辑架构图](images/cmdb-view-application-architecture/logical-diagram.png)](images/cmdb-view-application-architecture/logical-diagram.png){: target="\_image"}

您可以在图上点击某个图形元素将其选中，这样页面右侧将会显示选中图形对应的CI数据对象信息，您可以对数据对象进行编辑以及添加作为图形子节点的关联CI数据对象。


## 服务调用图视角

在服务调用图视角中，您可以在页面上看到业务应用系统各组件（部署单元）间的服务调用关系。

[![服务调用图](images/cmdb-view-application-architecture/service-invocation-diagram.png)](images/cmdb-view-application-architecture/service-invocation-diagram.png){: target="\_image" style="display: block; width: 61.8%; margin: 0 auto;"}



## CI数据对象视角

在页面上方的面板标签中，除了图视角的标签之外，其它每个标签都对应图中包含的一种CI数据类型，如下图所示：：

[![CI数据类型标签](images/cmdb-view-application-architecture/pannel-tabs.png)](images/cmdb-view-application-architecture/pannel-tabs.png){: target="\_image"}

通过切换这些标签页，您可以对相应的CI数据对象进行查看、编辑、删除和导出等操作，也可以使用表格组件上方的过滤搜索进行有针对性的查询。

[![CI数据对象表格](images/cmdb-view-application-architecture/data-tables.png)](images/cmdb-view-application-architecture/data-tables.png){: target="\_image"}
