# 使用grafana监控5xx服务

## 1. Grafana信息

grafana服务：https://devops.example.com/grafana

如果要注册账号请联系devops组。

## 2. Grafana监控预览

grafana已经配置了对service.hompartners.com域名下的service访问状态返回5xx的监控，可以查看对应的grafana面板https://devops.example.com/grafana/d/Q_zv-HrWz/cst-service-status?orgId=1

该监控面板中可以查看如userapi、emailapi等服务是否正常，当面板的网格视图中出现红点，说明访问对应的服务返回了5xx状态，即服务端异常。开发人员等可以根据该视图及时发现服务异常情况。

![image-20200408143204239](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200408143204239.png)

## 3. Grafana添加监控5xx服务

如果项继续添加Grafana面板来监控更多的服务，请参照以下教程。

**Step 1 复制模板视图**

选中并进入xxx service http_status_5xx template面板，按操作如下复制xxx.xxx.com http_status_5xx视图

（可通过该链接访问：https://devops.example.com/grafana/d/XNnusprWz/xxx-service-http_status_5xx-template?orgId=1）

![](C:\Users\dp\AppData\Roaming\marktext\images\2020-04-08-17-51-09-image.png)

**Step 2 创建新面板**

按如下操作创建新面板并粘贴视图。

![image-20200409085221003](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200409085221003.png)

随后会在页面呈现一个视图，这时可以先编辑面板信息，并新命名，选择面板分类，并保存面板信息。

![image-20200409090813067](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200409090813067.png)

![image-20200409090859182](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200409090859182.png)

**Step 3 定制xxx.xxx.com http_status_5xx视图**

保存完成之后，点击左上角的回退箭头图标：<--，回到视图页面，按如下操作编辑视图。

![image-20200409091220054](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200409091220054.png)

修改查询sql语句，域名修改为要监控的域名或服务名，比如你想监控`www.example.com`域名下所有服务，那么你可以定制sql如下：

```sql
SELECT "service_code" FROM "service_status" WHERE ("health_code" = 500 AND "domain_name" = 'www.example.com') AND $timeFilter GROUP BY "service_name"
```

，当然你可能只想监控某个域名下的其中一个服务，如你想监控`www.example.com`域名下`operationplatgform`服务，那么你可以定制sql如下：

```sql
SELECT "service_code" FROM "service_status" WHERE ("health_code" = 500 AND "domain_name" = 'www.example.com' AND "service_name" = 'operationplatgform') 
```

另外这里的health_code做了格式化，分为200和500，我们默认监控对我们有用的500状态

![image-20200409091426037](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200409091426037.png)

修改视图名称，如果有CloudWatch日志连接的需要，可以定制Panel links。

![image-20200409091803026](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200409091803026.png)

视图修改完成后，右上角保存面板。

**Step 4 定制xxx service info视图**

按照上述操作，将xxx.service.info视图复制，然后粘贴在新的面板中。

![](C:\Users\dp\AppData\Roaming\marktext\images\2020-04-14-15-37-05-image.png)

并且编辑粘贴的视图，修改query。

## 4. Grafana添加服务信息

**Step 1 复制模板视图**

选中并进入xxx service http_status_5xx template面板，按操作如下复制xxx service ingo视图

（可通过该链接访问：[https://devops.example.com/grafana/d/XNnusprWz/xxx-service-http_status_5xx-template?orgId=1）](https://devops.example.com/grafana/d/XNnusprWz/xxx-service-http_status_5xx-template?orgId=1%EF%BC%89)

之后在视图页面，可以通过伸缩视图页面，使展示更合理；通过调整时间段查看想要观察的时间段内的数据。

![image-20200409092119827](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200409092119827.png)

如果在定制过程中存在问题，也可以联系DevOps组。