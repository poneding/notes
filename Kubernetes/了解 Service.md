# 了解 Service

![202306051105607](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202306051105607.png)

## Service 介绍

按照官方文档的说法，在 K8s 中，Service 是将运行在集群中的一组 Pod 的应用公开为网络服务的抽象方法，是 K8s 的核心概念之一，Service 的主要作用是使客户端发现 Pod 并与之通信。

简单理解起来就是，由 Service 提供统一的入口地址，然后将请求负载分发到后端 Pod 的容器应用。

![image-20200622171939308](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200622171939308.png)

### 为什么有 Service

集群中部署了 Pod，应用是成功的部署起来了，但是只是至此的话，Pod 提供服务访问存在以下一些问题。

- Pod 是短暂的，可能会被销毁或重新调度，这使得 Pod 的 IP 是随时变动和更新的；
- 部署多个 Pod 的伸缩问题，流量分配问题；
- 集群外部客户端无法直接访问 Pod。

这时候就需要 Service，Pod 作为 Service 的后端提供服务。所以我们可以想象，Service 需要完成的事情：

- 服务发现，通过 Pod 的 lable 查找目标 Pod，将查找的 Pod 的注册到自己的后端列表，Pod 的 IP 信息发生更改，后端列表也同步更新；
- 负载均衡，请求到达 Service 之后，将请求均衡转发的后端列表；
- 服务暴露：对外提供统一的请求地址。

## 创建 Service

在创建 Sercvice 之前我们首先创建 service 代理的 Pod，nginx-pod.yaml：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
```

先给到一个简单的 Service 定义实例 nginx-service.yaml：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: nginx
  type: LoadBalancer
```

> spec.ports.port 是 Service 对外提供服务的端口，spec.ports.targetPort 是转发到 Pod 内的访问端口；
>
> 通过 spec.selector 发现同一命名空间下带有 app=nginx 的 label 的 Pod 作为后端。

创建命令：

```shell
kubectl apply -f nginx-service.yaml
```

Service作为Pod的负载均衡器，使用 `service.spec.selector` 字段去匹配Pod，上面示例中，nginx Service将通过 `app: nginx` 的 label 查找 Pod 作为后端。

创建 Service 之后，查看 Service 的后端：

```shell
kubectl get svc -o wide
kubectl describe svc nginx
```

在创建 Sercvice 之前，我已经创建了一个带有 `app: nginx` label 的 Pod，所以可以看到 Service 的 EndPoints 中已经有了一个后端（10.244.1.25）了，Endpoint 也是一种 K8s 资源，可以使用 `kubectl get ep` 命令查看。

![image-20200622173727494](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200622173727494.png)

除了以上使用 yaml 定义 Service 之外，还可以使用以下命令创建 Service：

```bash
# 暴露 Pod
kubectl expose pod nginx --name=nginx --port=80 --target-port=80 --protocol=TCP --type=NodePort
# 或者 Deployment 管理的 Pod
kubectl expose deploy nginx --name=nginx --port=80 --target-port=80 --protocol=TCP --type=LoadBalancer
```

## Service 类型

通过 `Service.spec.type` 定义，最常用的三种：ClusterIP（默认），NodePort、LoadBalancer。

### CLusterIP

指定 type 为 ClusterIP 时，它将被分配一个集群内部的 IP，在集群内部通过访问它来访问后端 Pod，这种 Service 一般只供集群内部访问。

### NodePort

指定 type 为 NodePort 时，会在所有节点分配一个端口（默认从 30000-32767 ）作为 service 的入口，访问方式：`<protocol>://<node-ip>:<port>`，使用 NodePort 类型时，也会默认分配一个 ClusterIP，除非使用 `ClusterIP: None` 免除分配。

**特点：**

- 所有节点都是同一个端口；
- 端口是有限的，30000-32767 范围内分配，也可以使用 `service.spec.ports.nodePort` 指定端口，但指定的端口必须在范围内且尚未被占用；
- 外部访问需要使用到 Node 的 IP。

### LoadBalancer

随机分配一个 LoadBalancer 作为 Service 的入口，一般需要云提供商的支持。请求到达 LoadBalancer 地址后，均衡负载到后端 Pod，使用 LoadBalancer 类型时，也会默认分配一个 ClusterIP，并且也会分配一个 NodePort 端口，实际上来说，LoadBalancer 是基于 NodePort 实现的。

**特点**：

- 外部网络可以通过 LoadBalancer 的地址和端口访问到集群内 Service 服务。

### ExternalName

创建一个新的 Service 代理到已经存在另外一个 Service，允许跨命名空间。如下，在命令空间 `ns-b` 下创建 service 转发访问到 `ns-a` 下的 service。

```yaml
kind: Service
apiVersion: v1
metadata:
  name: nginx
  namespace: ns-b
spec:
  selector:
    app: nginx
  type: ExternalName
  externalName: nginx.ns-a.svc.cluster.local
  ports:
    - name: http
      port: 80
      targetPort: 80
```

> 如果只是用来创建一个 Service，使用意义不是很大，因为本来就可以直接通过 `nginx.ns-a.svc.cluster.local` 跨命名空间访问，但是在结合 Ingress 时有一定的使用意义，因为 ingress 无法跨命名空间转发 Service。

## 访问 Service

- 通过 ClusterIP 访问，限集群内部访问；
- 通过 Service Name 访问：如果在同一命名空间，可以直接使用服务名称 `<service-name>` 访问，如果不在同一命名空间，使用服务名称和命名空间名称 `<service-name>.<namespace-name>` 或 `<service-name>.<namespace-name>.svc.cluster.local` 访问，集群外可访问；
- 通过节点端口（NodePort）访问，集群外可访问；
- 通过 ExternalIP（一般是 LoadBalancer 的地址）访问，集群外可访问。

