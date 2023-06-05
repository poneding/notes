# Prometheus-监控Kong完整操作

本篇记录使用Prometheus收集Kong暴露的/metrics接口，收集指标数据，从而实现对Kong的监控。

## 先决条件

- Prometheus部署完成；
- Kong（Kong 服务，端口8000）部署完成；
- Kong 的Admin Api（端口8001）部署完成
- Konga（Kong的WebUI，端口1337）部署完成。

## Kong添加Prometheus插件

- 登录进入Konga；
- 点击右边菜单栏”PLUGINS“，进入Plugins管理，点击“Analytics & Monitoring”，选择添加Promethus插件

![image-20200228160808152](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200228160808152.png)

## Kong添加metrics接口

我们知道Prometheus主要通过读取 `http://host/metrics`接口, 来收集相关服务的性能数据，但是Kong的metrics接口服务默认是没有开启的，所以需要先为Kong添加/metrics。

- 登录进入Konga；
- 点击右边菜单栏”SERVICES“，进入Services管理，点击“ADD NEW SERVICE”

![image-20200228154041421](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200228154041421.png)

- 添加页面输入“Name”和“Url”参数即可，例如“Name”=“prometheusService”，“Url”=“http://localhost:8001/metrics”

![image-20200228154621208](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200228154621208.png)

- 添加完Prometheus Service之后，Service列表选中并点击进入prometheusService，选择”Routes“菜单，点击“ADD ROUTE”

![image-20200228154825910](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200228154825910.png)

- 添加页面输入“Paths”参数即可，例如“Paths”=[“/metrics”]（Path必须以“/”为首）

![image-20200228162440174](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200228162440174.png)

- 这时候访问“http://localhost:8000/metrics”，看到页面如下显示，说明已经成功的添加了metrics接口

![image-20200228162530307](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200228162530307.png)

## Prometheus添加Kong指标收集

修改Prometheus配置文件，prometheus.yml

scrape_configs配置项下添加如下配置

```yaml
  - job_name: 'kong'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:8000']
```

配置完之后重启Prometheus，访问“http://localhost:9090/graph”

可以看到一已经生成了很多kong的指标项，如http访问，nginx当前访问量等指标

![image-20200228163048474](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200228163048474.png)

