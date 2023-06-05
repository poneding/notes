# EKS实践 集成Gitlab自动发布（一）

系列介绍如何使用Gitlab CI/CD自动部署应用到EKS（K8s）集群中。本篇介绍如何在EKS（K8s）集群中为Gitlab的CI/CD创建Gitlab Runner。

## Gitlab添加K8s集群

### 添加方式

**第一种方式，基于单个仓库添加K8s集群**

进入Gitlab仓库，依次从左边菜单栏Operations => Kubernetes进入添加页面，点击Add Kubernetes cluster按钮。这种方式添加的K8s集群只对该项目仓库有效。

![image-20200720173119837](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200720173119837.png)

**第二种方式，基于Group添加K8s集群**

进入Gitlab主页，依次从上边菜单栏Groups => Your groups，选择Group进入页面，然后依次从左边菜单栏Kuberentes进入添加页面，点击Add Kubernetes cluster。这种方式添加的K8s集群对该Group下的项目仓库有效。

![image-20200720173146103](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200720173146103.png)

**第三种方式，基于全局添加K8s集群**

这种方式需要用到gitlab的root权限。进入Gitlab主页，从上边菜单栏Admin Area(扳手图标) 进入页面，然后依次从左边菜单栏Kuberentes进入添加页面，点击Add Kubernetes cluster。这种方式添加的K8s集群对所有项目仓库有效。

![image-20200722175155838](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200722175155838.png)

### 添加步骤

添加已有的K8s集群，按照如下步骤获取到对应的值填入表单即可。

![image-20200722175602233](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200722175602233.png)

- **Cluster Name**

这个可以自定义，能自行区分就行。

- **API URL**

运行以下命令得到输出值：

```bash
kubectl cluster-info | grep 'Kubernetes master' | awk '/http/ {print $NF}'
```

- **CA Certificate**

运行以下命令得到输出值：

```bash
kubectl get secret $(kubectl get secret | grep default-token | awk '{print $1}') -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
```

- **Service Token**

创建文件gitlab-admin-service-account.yaml：

```bash
vim gitlab-admin-service-account.yaml
```

文件写入如下内容：

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: gitlab-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: gitlab-admin
  namespace: kube-system
```

运行以下命令得到输出值：

```bash
kubectl apply -f gitlab-admin-service-account.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab-admin | awk '{print $1}')
```

## 安装Helm以及Runner

添加完K8s集群之后，在集群中安装Helm Tiller。

![image-20200723162157505](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200723162157505.png)

安装完Helm Tiller之后，再安装Helm TIller下面的Runner。

![image-20200723162635775](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200723162635775.png)

之后，你可以发现K8s资源中多了一个`gitlab-managed-apps`命令空间，并且在该命名空间下，包含了tiller和runner的一些资源。

## 安装Gitlab Runner

上面介绍了Gitlab集成EKS，并安装Gitlab Runner的操作过程，其实也可以完全不用这种方法。下面介绍另一种安装Gitlab Runner的方法。

在Group或项目仓库下都可以，Settings => CI / CD => Runners 获取到Url和Token。

![image-20200729154127626](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200729154127626.png)

从这里下载values.yaml文件：https://gitlab.com/gitlab-org/charts/gitlab-runner/blob/master/values.yaml

下载完之后，将上面获取到的Url和Token替换文件中gitlabUrl和runnerRegistrationToken值。

![image-20200729154743876](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200729154743876.png)

然后使用helm命令安装Gitlab Runner：

```bash
kubectl create -n gitlab-managed-apps # 手动创建命名空间
helm install -n gitlab-managed-apps <gitlab-runner-name> -f values.yaml gitlab/gitlab-runner

# 删除gitlab runner
# helm uninstall -n gitlab-managed-apps <gitlab-runner-name>
```

在安装了之后，查看安装的Gitlab Runner：

![image-20200730174432289](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200730174432289.png)

此时，进入Gitlab Group页面 Setting => CI / CD => Runners下可以看到有一个可用的Group Runner。

![image-20200730174330210](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200730174330210.png)

## 一些经验

1. 要求Gitlab的服务和K8s可以互相访问，也就是网络是连通的；

2. 重复添加集群安装Helm Tiller

   同一个K8s集群可以被同一个Gitlab服务多次添加，但是Helm Tiller和Runner是不能多次安装的，这是因为安装Helm Tiller和Gitlab Runner创建K8s资源（gitlab-managed-apps命名空间下的Deployment）会冲突。

![image-20200729113424514](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200729113424514.png)

2. Gitlab Runner的作用域

   一个项目可以选择使用多个Gitlab Runner：

   - Specific Runners：基于当前项目添加的K8s集群中安装的Gitlab Runner

   - Shared Runners：Root权限基于全局添加的K8s集群中安装的Gitlab Runner

   - Group Runners：当前项目所属Group添加的K8s集群中安装的Gitlab Runner

   如果使用Root权限基于全局添加了一个K8s集群，并且安装了Gitlab Runner之后，随便进入一个项目仓库 Settings => CI / CD => Runners下面可以看到Shared Runners下面会有一个可用的Runner，如下图所示。你可能注意到了这个Runner默认有两个Tag：`cluster`，`kubernetes`，这两个Tag的作用下次将会使用到。

   ![image-20200729114046476](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200729114046476.png)

## 结束语

本篇介绍将EKS（K8s）集群添加到项目仓库中，并且安装所需的Helm Tiller和GItlab Runner。

Helm是K8s的类似包管理工具，Helm的各类Charts可以帮助我们快速的定义，安装和升级K8s应。Helm对K8s来说是一个客户端，它的服务端则是安装在K8s中的Tiller。

可以使用Helm在K8s集群中安装Gitlab Runner，使用Gitlab Runner实现Gitlab 自动CI/CD，前面我们的步骤就是使用Helm安装GItlab Runner。

