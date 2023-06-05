# K8s 部署 Kong 服务

![image-20200319105924013](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200319105924013.png)

本篇只涉及 Kong 服务在 K8s 集群的部署操作，不涉及概念知识。

## 提前准备

- K8s 集群，本文使用的是 AWS EKS 集群服务
- 一台可以连接 K8s 集群的服务器，已经安装 kubectl 和 docker 等基础应用，之后称之为操作机器
- Postgres 数据库，作为 Kong 服务的后端数据库

## 初始化数据库

使用 Postgres 作为 Kong 服务的后端数据库，我们需要提前做数据库的初始化，准备 Kong 服务需要的数据表等。这里使用 K8s-Job 来实现数据库的初始化工作。

**kong-migrations-job.yaml**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: kong-migrations
  namespace: kong
spec:
  template:
    metadata:
      name: kong-migrations
    spec:
      containers:
        - command:
            - /bin/sh
            - -c
            - kong migrations bootstrap
          env:
            - name: KONG_PG_PASSWORD
              value: "kong"
            - name: KONG_PG_HOST
              value: "postgres/postgres"
            - name: KONG_PG_PORT
              value: "5432"
          image: kong:1.4
          name: kong-migrations
      initContainers:
        - command:
            - /bin/sh
            - -c
            - until nc -zv $KONG_PG_HOST $KONG_PG_PORT -w1; do echo 'waiting for db';
              sleep 1; done
          env:
            - name: KONG_PG_HOST
              value: "localhost:5432"
            - name: KONG_PG_PORT
              value: "5432"
          image: busybox
          name: wait-for-postgres
      restartPolicy: OnFailure
```

> 使用的是 kong 的镜像，这个镜像运行起来的容器里执行 `kong migrations bootstrap` 命令来完成 kong 数据库的初始化操作。
>
> `initContainers` 容器的作用是保证 `ping postgres` 的网络可以连通，如果无法连通，不会执行初始化。

在操作机器上使用以下命令开始 kong 数据库的初始化：

```shell
kubectl apply -f kong-migrations-job.yaml 
```

如果 kong 数据库初始化成功，你可以在数据库中看到新出现的表

![image-20200319113114554](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200319113114554.png)

## K8s资源文件

**kong-configmap.yaml**

```
apiVersion: v1
data:
  servers.conf: |
    # Prometheus metrics server
    server {
        server_name kong_prometheus_exporter;
        listen 0.0.0.0:9542; # can be any other port as well
        access_log off;

        location /metrics {
            default_type text/plain;
            content_by_lua_block {
                 local prometheus = require "kong.plugins.prometheus.exporter"
                 prometheus:collect()
            }
        }

        location /nginx_status {
            internal;
            stub_status;
        }
    }
    # Health check server
    server {
        server_name kong_health_check;
        listen 0.0.0.0:9001; # can be any other port as well

        access_log off;
        location /health {
          return 200;
        }
    }
kind: ConfigMap
metadata:
  name: kong-server-blocks
  namespace: kong
```

> 使用 nginx 对外暴露 kong 指标数据的接口，通过这个接口，prometheus 可以抓取到 kong 服务指标数据。

