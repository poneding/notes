# K8s 部署 konga

![](https://pding.oss-cn-hangzhou.aliyuncs.com/images/konga-logo.png)

本篇只涉及 konga 的部署操作，不涉及概念知识。

## 提前准备

- K8s 集群，本文使用的是 AWS EKS 集群服务
- 一台可以连接 K8s 集群的服务器，已经安装 kubectl 和 docker 等基础应用，之后称之为操作机器
- Postgres数据库

**！注意**：该数据库使用 9.5 版本，其他最新版本的数据库在初始化 konga 数据库时会报如下错：

```tex
error: Failed to prepare database: error: column r.consrc does not exist
```

这是部署 konga 踩过的坑之一。

- 确保 K8s 集群中已经创建了 nginx-ingress，nginx-ingress 用于根据定制的 Rule（如后文 kong-ingress 的配置）将流量转发至 K8s 集群的 Service 中去。

创建 nginx-ingress 指令（可参照 https://kubernetes.github.io/ingress-nginx/deploy/）步骤如下：

Step 1. 执行以下强制命令

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml
```

Step 2. 针对我们使用的 AWS 服务，并且根据你想配置的 ELB 类型选择层（L4或L7），执行以下命令

​	# Layer 4: use TCP as the listener protocol for ports 80 and 443.

​	# Layer 7: use HTTP as the listener protocol for port 80 and terminate TLS in the ELB

```shell
# FOR Layer 4
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/provider/aws/service-l4.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/provider/aws/patch-configmap-l4.yaml

# FOR Layer 7
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/provider/aws/service-l7.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/provider/aws/patch-configmap-l7.yaml
```

## 初始化数据库

在操作机器上执行如下指令

```shell
docker run --rm pantsel/konga:latest -c prepare -a {{adapter}} -u {{connection-uri}}
```

> adapter：数据库类型，可选，'mongo','postgres','sqlserver'  or 'mysql'
>
> connection-uri：数据库的连接字符串

使用 postgres 数据库作为 konga 的存储，指令大概长这个样子：

```shell
docker run --rm pantsel/konga:latest -c prepare -a postgres -u postgresql://<user>:<password>@<host>:<port>/<database>
```

运行指令，输出如下，可以说明数据库初始化成功。

```shell
debug: Preparing database...
Using postgres DB Adapter.
Database exists. Continue...
debug: Hook:api_health_checks:process() called
debug: Hook:health_checks:process() called
debug: Hook:start-scheduled-snapshots:process() called
debug: Hook:upstream_health_checks:process() called
debug: Hook:user_events_hook:process() called
debug: Seeding User...
debug: User seed planted
debug: Seeding Kongnode...
debug: Kongnode seed planted
debug: Seeding Emailtransport...
debug: Emailtransport seed planted
debug: Database migrations completed!
```

可以连接postgres发现你的数据库中多出了下面这些表

![image-20200316134405073](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200316134405073.png)

## K8s 资源文件

**kanga-namespace.yaml**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: konga
```

**konga-deployment.yaml**

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: konga
  namespace: konga
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: konga
        app: konga
    spec:
      containers:
        - env:
            - name: "DB_ADAPTER"
              value: "postgres"
            - name: "DB_HOST"
              value: "postgres/postgres"
            - name: "DB_PORT"
              value: "5432"
            - name: "DB_USER"
              value: konga
            - name: "DB_PASSWORD"
              value: konga
			- name: "DB_DATABASE"
              value: konga
            - name: "DB_PG_SCHEMA"
              value: "public"
          # - name: BASE_URL
          #   value: /konga/
          name: konga
          image: pantsel/konga
          ports:
            - containerPort: 1337
```

>该文件需要设置 postgres 的数据库配置，需要自行替换；
>
>可以注意到 yaml 文件中的 BASE_URL 环境变量被我注释掉了，这个参数的作用本来是设置成我们可以通过http://www.example.com/konga/来访问konga程序的，但是镜像的作者目前还没有处理好相关的路由问题。所以目前还只能通过http://konga.example.com使用。

**konga-service.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: konga
  namespace: konga
spec:
  ports:
    - name: tcp
      port: 1337
      targetPort: 1337
      protocol: TCP
  selector:
    app: konga
```

**kong-ingress.yaml**

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: konga-ingress
  namespace: konga
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
    - hosts:
        - konga.example.com
      secretName: tls-secret
  rules:
    - host: konga.example.com
      http:
        paths:
          - path: /
            backend:
              serviceName: konga
              servicePort: 1337
```

> 这里host(s)需要替换成真正的域名。

## 创建Konga

先创建konga命令空间

```shell
kubectl apply -f konga-namespace.yaml
```

再创建其他资源即可

```shell
kubectl apply -f konga-deployment.yaml
kubectl apply -f konga-service.yaml
kubectl apply -f konga-ingress.yaml
```

## 验证konga

在以上创建命令执行后大概1-2分钟，浏览器访问 http://konga.example.com，出现konga注册页面说明已经部署成功。

![image-20200316171055384](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200316171055384.png)

![image-20200316124621295](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200316124621295.png)