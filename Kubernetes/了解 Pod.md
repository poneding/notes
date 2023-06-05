# Kubernetes 0-1 了解 Pod

![202306051105607](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202306051105607.png)

## Pod 介绍

Pod，是 K8s 对象模型中的最小单元，Pod 里面包含着一组容器（单个容器或多个紧密耦合的容器），这时候 Pod 可以理解为一个机器，而 Pod 里面的容器则理解为该机器里面的进程。

Pod 的容器运行时由容器引擎提供，默认的容器引擎是 `Docker`；并且 K8s 管理的是 Pod，而不是容器。

一个 Pod 内部的容器共享：

- 存储：一个 Pod 可以指定一组共享存储卷。
- 网络：每个 Pod 分配一个唯一 IP（集群内 IP），共享网络命名空间，包括 IP 地址和网络端口。Pod 内的容器可以使用 localhost 互相通信，集群内 Pod 与 Pod通信可以使用 Pod 分配的 IP，但是由于 Pod 的 IP 是随机分配的，这种互通信的方式不太适合使用。

尽管一个 Pod 内可以包含多个 Pod，但我们在部署应用容器时的**最佳实践**是一个 Pod 里面只包含一个应用容器作为主容器，其他容器为主容器服务，称之为辅助容器。例如主容器崩溃了，会有一个辅助容器去重启主容器。辅助容器可以有也可以没有，因为 Pod 里面容器的生命周期可以被 Pod 的生命周期取代，而 Pod 的生命周期可以通过 Pod 管理器来管理维护。

将我们应用服务隔离单独部署在 Pod 的好处可以罗列以下：

- Pod 可以分别的调度到各个 K8s 节点，充分利用了节点的计算资源；
- 方便我们单独为某个应用服务做扩缩操作。

## Pod 创建

在K8s集群中一般不会直接单独创建 Pod，而是通过 Pod 管理器。如果单独创建 Pod，Pod的进程被结束的话，Pod 就永远被删除；使用 Pod 管理器创建出来的Pod，Pod 管理器会负责保证Pod按期调度，即使 Pod 被删除，也会重新被调度起来。简而言之，Pod 的生存由 Pod 管理器全权负责。

Pod 管理器包含很多种，由很早的 `ReplicationController` 过渡到 `ReplicaSet` 再过渡到当前普遍使用的 `Deployment`，其实这三者能做的事情是类似的，都是调度和监视 Pod 列表，保证 Pod 列表与声明的数量和其他期望相符。

除此之外还有其他的管理器：

- StatefuleSet：带状态的 Pod 管理器，需要持久存储数据，一般用于创建数据库类型的应用实例，如 mysql，redis；
- DaemonSet：每个符合条件的Node都分配一个 Pod，一般用于创建 agent 服务，如日志收集组件，指标数据收集组件等。

一般通过以下方式创建 Pod

- 单行命令创建 Pod

```bash
kubectl run nginx --image=nginx:latest --replicas=2
```

以上命令实际上是创建了一个 Deployment 资源和由其管理的 2 个 Pod。

- 定义资源清单，创建 Pod

以yaml或者json格式定义 Pod 资源，大都选择 yaml。如果你使用VSCode的话，那么 `Kubernetes Support` 插件会成为你的利器。

我们先定义个一个 Pod 的资源文件 pod-sample.yaml：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    name: nginx
spec:
  containers:
    - name: nginx
      image: nginx
      imagePullPolicy: Always
      restartPolicy: Never
      resources:
        requests:
          memory: "128Mi"
          cpu: "256m"
        limits:
          memory: "256Mi"
          cpu: "512m"
      ports:
        - containerPort: 80
```

以上是一个简单的Pod定义文件，我们可以从这个文件得到这些信息：

- 运行nginx镜像，作为Pod的主容器，向外暴露80端口；
- 每次启动这个Pod都会从网络拉取镜像；
- 如果主容器不小心挂了，则不会被重启；
- 容器启动需要的最小资源和运行最大资源。

然后通过 `kubectl` 命令创建（下面这行命令也适用于更新 Pod）：

```shell
kubectl apply -f pod-sample.yaml
```

查看Pod：

```shell
kubectl get pod -o wide
```

通过查看 Pod 的描述、Pod 里面容器的运行日志，或直接进入 Pod 容器分析定位问题：

```shell
# 描述 Pod 详情
kubectl describe pod <POD_NAME>
# 查看 Pod 容器控制台运行日志
kubectl logs <POD_NAME>
# 进入 Pod
kubectl exec -it <POD_NAME> -c <CONTAINER_NAME> -- <COMMAND>
```

删除 Pod：

```bash
kubectl delete -f pod-sample.yaml
kubectl delete pod <POD_NAME>
```

## Pod 字段

通过以下命令查看定义 Pod 资源的字段即作用：

```bash
kubectl explain pod
kubectl explain pod.spec
```

对一些字段简单介绍一下：

### imagePullPolicy

镜像拉取策略，有三种，Always、IfNotPresent、Never

- Always：每次都拉取最新镜像，默认策略；
- IfNotPresent：如果 Pod 被调度的Node上已经存在镜像了则直接使用镜像，不存在在拉取；
- Never：只使用 Node 上的镜像，即使不存在也不拉取。

### restartPolicy

Pod 重启策略，有三种：Always、OnFaliure、Never

- Always：Pod 只要终止运行，kubelet 就会重启它；
- OnFaliure：Pod非正常终止，退出码不为零，kubelet 就会重启它，正常退出不会重启；
- Never：退出了就不重启。

### nodeSelector

定义Lable对，选择调度到拥有该 Label 对的 Node 节点。

### livenessProbe

存活指针，可以理解为 Pod 内容器运行的健康检查，如果健康检查没通过，则重启 Pod 内容器，这里面的内容有点多，有机会详细讲。

### readinessProbe

就绪指针，也是通过健康检查机制，对外呈现 Pod 的就绪状态，如果健康检查通过，Pod 状态为就绪，可以接受外部流量请求。流量无法转发到非就绪状态的 Pod。

### command

容器启动时的命令列表，和 Dockerfile 中定义的 CMD 作用一样。

### args

容器启动命令的参数。

### env

容器内的环境变量列表，和 Dockerfile 中定义的 ENV 作用一样。

### resource

可以定义容器启动的最小字段和运行最大分配资源，对 Pod 的资源使用的控制。

