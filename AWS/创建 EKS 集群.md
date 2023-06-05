# 创建 EKS 集群

![eks](https://pding.oss-cn-hangzhou.aliyuncs.com/images/eks.jpg)

## 1. EKS简介

Amazon Elastic Kubernetes Service (Amazon EKS) 是一项托管服务，可让您在 AWS 上轻松运行 Kubernetes，而无需支持或维护您自己的 Kubernetes 控制层面。Kubernetes 是一个用于实现容器化应用程序的部署、扩展和管理的自动化的开源系统。（该段介绍来自Amazon EKS文档，更多了解https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/what-is-eks.html）

## 2. eksctl创建eks集群

### 2.1 什么是eksctl

eksctl是一种用于在 Amazon EKS 上创建和管理 Kubernetes 集群的简单命令行实用程序。`eksctl` 命令行实用程序提供了使用工作线程节点为 Amazon EKS 创建新集群的最快、最简单的方式。

eksctl更多了解https://eksctl.io

### 2.2 为什么用eksctl

创建EKS集群可以在AWS的控制台创建，也可以使用AWS开发的eksctl工具创建，为什么选择使用eksctl创建eks集群呢，有以下几点原因：

- 直接在AWS的控制台创建集群，需要手动创建各种Role，以及选择合适的Subnet，Security Group等繁杂操作，你需要在浏览器中打开多个页面，操作过程可能也要时不时参阅文档；
- eksctl创建EKS集群只需要一行eksctl create cluster <参数>命令即可，会自动的给你创建Role等资源；
- eksctl的命令可以记录到脚本，便于复用。

### 2.3 安装eksctl（基于ubuntu）

1. 使用以下命令下载并提取最新版本的 `eksctl`。

```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
```

2. 将提取的二进制文件移至 `/usr/local/bin`。

```
sudo mv /tmp/eksctl /usr/local/bin
```

3. 使用以下命令测试您的安装是否成功。                                                            

```
eksctl version
```

**注意**

`GitTag` 版本应至少为 `0.11.1`。否则，请检查您的终端输出是否有任何安装或升级错误。

### 2.4 使用eksctl创建集群

**准备工作**

- 一台拥有创建eks权限的机器
- 已经安装好eksctl

```shell
eksctl create cluster \
--name prod-eks \
--version 1.14 \
--region us-east-1 \
--nodegroup-name prod-eks-workers \
--node-type t3.medium \
--nodes 2 \
--nodes-min 2 \
--nodes-max 4 \
--ssh-access \
--ssh-public-key                                                                -eks-public-key \
--managed
```

 `--ssh-public-key` 可选的，但建议您在创建包含节点组的集群时指定该选项。通过此选项，可以对托管节点组中的节点进行 SSH 访问。启用 SSH 访问后，如果出现问题，您可以连接到实例并收集诊断信息。

注意：在us-east-1区中，创建eks集群时您可能会遇到UnsupportedAvailabilityZoneException类型的异常。如果遇到这种情况，可以传递zones参数，例如，

```shell
eksctl create cluster \
--name prod-eks \
--version 1.14 \
--region us-east-1 \
--zones us-east-1a,us-east-1b \
--nodegroup-name prod-eks-workers \
--node-type t3.medium \
--nodes 2 \
--nodes-min 2 \
--nodes-max 4 \
--ssh-access \
--ssh-public-key prod-eks-public-key \
--managed
```

以上创建eks集群的命令会大致输出以下内容，集群的整个创建过程可能会花费10到15分钟：

```shell
[ℹ]  CloudWatch logging will not be enabled for cluster "prod-eks" in "us-east-1"
[ℹ]  you can enable it with 'eksctl utils update-cluster-logging --region=us-east-1 --cluster=prod-eks'
[ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "prod-eks" in "us-east-1"
[ℹ]  2 sequential tasks: { create cluster control plane "prod-eks", create managed nodegroup "prod-eks-workers" }
[ℹ]  building cluster stack "eksctl-prod-eks-cluster"
[ℹ]  deploying stack "eksctl-prod-eks-cluster"
[ℹ]  building managed nodegroup stack "eksctl-prod-eks-nodegroup-prod-eks-workers"
[ℹ]  deploying stack "eksctl-prod-eks-nodegroup-prod-eks-workers"
[✔]  all EKS cluster resources for "prod-eks" have been created
...
```

如果输出中存在 could not find any of the authenticator commands: aws-iam-authenticator, heptio-authenticator-aws，则需要安装aws-iam-authenticator，使用以下命令：

```shell
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
aws-iam-authenticator help
```

如果本次操作机器没有安装kubectl，可以使用以下命令安装，如果已经安装则跳过：

```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

可以通过kubectl命令操作本次创建的集群：

```shell
kubectl get svc
```

输出如下，可以说明eks集群已经成功创建了。

```shell
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.100.0.1   <none>        443/TCP   31m
```

## 3. 部署 Kubernetes Metrics Server

1. 打开终端窗口，导航到您要下载最新 `metrics-server` 版本的目录。

2. 将以下命令复制并粘贴到您的终端窗口，然后键入 **Enter** 执行这些命令。这些命令将下载最新版本，提取它，然后在集群中应用版本 1.8+ 清单。

```
DOWNLOAD_URL=$(curl -Ls "https://api.github.com/repos/kubernetes-sigs/metrics-server/releases/latest" | jq -r .tarball_url)
DOWNLOAD_VERSION=$(grep -o '[^/v]*$' <<< $DOWNLOAD_URL)
curl -Ls $DOWNLOAD_URL -o metrics-server-$DOWNLOAD_VERSION.tar.gz
mkdir metrics-server-$DOWNLOAD_VERSION
tar -xzf metrics-server-$DOWNLOAD_VERSION.tar.gz --directory metrics-server-$DOWNLOAD_VERSION --strip-components 1
kubectl apply -f metrics-server-$DOWNLOAD_VERSION/deploy/1.8+/
```

3. 使用以下命令验证 `metrics-server` 部署是否运行所需数量的 Pod：

```
kubectl get deployment metrics-server -n kube-system
```
 输出:
```
NAME             DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1         1         1            1           56m
```

```
eksctl create cluster --name dev-devops-eks2 --version 1.14 --region ap-southeast-1 --nodegroup-name dev-devops-eks2-workers --node-type t3.medium --nodes 3 --nodes-min 1 --nodes-max 4 --ssh-access --ssh-public-key dev-devops-eks2-public-key --managed
```

EKS Node 默认给的Role权限需要attch s3、secrets manager的权限。