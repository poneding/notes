# Kubernets

HPA: Hotizontal Pod Autoscaler。

HPA根据监测到的CPU/内存占用情况自动伸缩通过ReplicationController, ReplicaSet, Deployment或StatefulSet部署的Pod的数量，对DaemonSet部署的Pod不起作用。

#### HPA自动伸缩Pod工作机制

![水平自动伸缩示意图](https://pding.oss-cn-hangzhou.aliyuncs.com/images/horizontal-pod-autoscaler.svg)

#### 定义HPA

## Service

### ClusterIP

### NodePort

### LoadBalancer

## Ingress

如果你的Service使用了LoadBalancer形式，那么你可能会需要Ingress。因为每个LoadBalancer服务作为单独的负载均衡器，都需要一个独有的公有IP。如果你的Service服务达到一定数量，这无疑会使你的维护成本增加。而Ingress，只需要一个共有IP就可以负责多个Service，发送到Ingress的http请求会根据具体的路径转发的目标Service。

Ingress概念里面包含了两个组件（k8s资源），分辨是Ingress和Ingress Controller。

#### Ingress

将集群内的http/https的路由公开到外网，外网访问时，根据Ingress定义的路由规则转发请求。请求转发可以参考下文的Ingress资源配置。

可以简单将Ingress理解为一个负载均衡器。

#### Ingress Controller

为了使Ingress运作，集群中需要有个运行着的Ingress Controller。（*这是必要的*）

可以通过ingress-nginx部署Ingress Controller。

- **Nginx Controller**

#### Deployment

[参考地址](https://kubernetes.github.io/ingress-nginx/deploy/)

[以下yaml文件查看地址](https://github.com/kubernetes/ingress-nginx/tree/master/deploy/static)

- **必要**

```shell
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

## update
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/aws/deploy.yaml
```

- **Aws**

在aws中使用elb暴露nginx-controller代理的Type类型为NodePort或LoadBalancer的Service，需要配置ELB。

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/aws/service-nlb.yaml
```

**Layer 4**

集群内http服务，也允许使用https方式访问服务。

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/aws/service-l4.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/aws/patch-configmap-l4.yaml
```

**Layer 7**

集群内的服务必须是https协议，否则是无法访问的。

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/aws/service-l7.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/aws/patch-configmap-l7.yaml
```

- **Deployment-Service-Ingress**

```

```

#### 转发配置

- 多个host

![image-20191230164032329](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20191230164032329.png)

- 同一host路由

![image-20191230164008003](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20191230164008003.png)

更多参考：https://kubernetes-sigs.github.io/aws-alb-ingress-controller/

## Pod存储卷-Volume

Volume实现应用的持久化存储，比如数据库，或应用日志的存储。我们说Volume，其实说的是Pod的Volume，而非容器的，一个在Pod中容器是共用存储的。一个Pod可以定义多个Volume，所以在定义Pod资源的yaml文件中，是用pods.spec.volumes声明的。

### 较常见的几种挂载存储方式

- **节点存储**

HostPath

- **网络存储**

- **分布式存储**

  

### References

1. https://www.cnblogs.com/life-of-coding/p/11794993.html
2. https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/#deploying-the-dashboard-ui

## Share to Vision

- 使用Terraform + Kops创建k8s集群
- k8s集群Node的伸缩，升级
- 起一个deployment（可以写日志），集群内访问Pod应用，进入Pod查看日志
- Pod Limit更新， Pod伸缩，deployment roll up & back
- 定义一个Service，ClusterIP访问应用，NodePort，LoadBalancer
- Ingress代理Service，应用开放到外网
- 部署EFK，展示Pod应用日志
- 部署kubernetes dashboard
- 部署Prometheus+Grafana，展示Node资源使用情况

## Kubectl拷贝文件

### 从本机拷贝到Pod

```
kubectl cp /tmp/foo_dir <some-pod>:/tmp/bar_dir
```

### 从Pod拷贝到本机

```
kubectl cp <some-pod>:/tmp/foo /tmp/bar
```

### 指定Pod中的容器

```
kubectl cp /tmp/foo <some-pod>:/tmp/bar -c <specific-container>
```

### 指定Pod所在命名空间

```
kubectl cp /tmp/foo <some-namespace>/<some-pod>:/tmp/bar
```

### Auto Scaler

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "autoscaling:DescribeTags"
            ],
            "Resource": ["*"]
        }
    ]
}
```

https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/cluster-autoscaler.html

### 获取EKS集群的CIDR

```bash
aws eks describe-cluster --name <cluster-name> --query "cluster.resourcesVpcConfig.vpcId" --output text
 # 上面的命令会输出vpc
 aws ec2 describe-vpcs --vpc-ids <vpc-id> --query "Vpcs[].CidrBlock" --output text
```

### 回滚Deployment

```bash
$ kubectl rollout history deployment nginx
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>
4         <none>
5         <none>
6         <none>
7         <none>
8         <none>
9         <none>
10        <none>
11        <none>
$ kubectl rollout undo --to-revision=10 deployment nginx
```

