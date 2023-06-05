# 使用Grafana监控service

> 监控live上的应用服务,如果服务http状态为5xx,则反应到grafana图表中,DevOps和开发人员都能及时从图表中获取信息,及时确认和排查问题.

## Service Http状态数据来源

使用程序定时轮询获取aws elb的日志数据,将日志数据以时序形式存储在influxdb,目前数据结构如下:

tag keys:

| #   | TagKeyName   | Remark                           |
| --- | ------------ | -------------------------------- |
| 1   | domain_name  |                                  |
| 2   | service_name | 默认取pathbase,如果pathbase为空,取domain |

field keys:

| #   | FieldKeyName    | Remark                                  |
| --- | --------------- | --------------------------------------- |
| 1   | domain_name     |                                         |
| 2   | elb_status_code | 数字类型,200;500                            |
| 3   | health_code     | 数字类型,200;500                            |
| 4   | request_url     | 请求路径                                    |
| 5   | service_code    | 一个域名下的多个service,按序从1自增,作为grafana图表的y轴数据 |

## 创建Dashboard

![](C:\Users\dp\AppData\Roaming\marktext\images\2020-04-15-08-53-02-image.png)

=> Add Query

目前数据源已经配置完成，选择Influxdb_Elb_Logs作为QUuery DataSource，并且开始配置query

![](C:\Users\dp\AppData\Roaming\marktext\images\2020-04-15-08-57-46-image.png)

![](C:\Users\dp\AppData\Roaming\marktext\images\2020-04-15-09-01-55-image.png)

查询语句可以参考：

```sql
SELECT mean("service_code") FROM "service_status" WHERE ("domain_name" = 'service.example.com' AND "health_code" = 500) AND $timeFilter GROUP BY time($__interval), "service_name"
```

根据自身需求修改query即可。
