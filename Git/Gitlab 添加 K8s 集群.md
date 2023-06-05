# Gitlab 添加 K8s 集群

本文介绍如何在 Gitlab 项目中添加 K8s 集群，以便使用 K8s 集群部署 gitlab-runner 帮我们运行 gitlab 的 CI/CD。

参考官方文档：https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html#add-existing-cluster

## 操作步骤

**找到添加位置**

登入 gitlab 后，进入自己的项目主页，菜单栏 Operations => Kubernetes => Add Kubernetes cluster，选择页签 Add existing cluster。

![image-20200616142451397](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200616142451397.png)

我们只需要获取响应的值填录到该表单即可。Kubernetes cluster name 集群名称随意填，Project namespace 可不填。

**获取 API URL**

运行以下命令得到输出值：

```bash
kubectl cluster-info | grep 'Kubernetes master' | awk '/http/ {print $NF}'
```

**获取 CA Certificate**

运行以下命令得到输出值：

```shell
kubectl get secret $(kubectl get secret | grep default-token | awk '{print $1}') -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
```

**获取 Token**

创建文件 gitlab-sa.yaml：

```bash
vim gitlab-sa.yaml
```

文件写入如下内容：

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-sa
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: gitlab-sa
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: gitlab-sa
  namespace: kube-system
```

运行以下命令得到输出值：

```shell
kubectl apply -f gitlab-sa.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab-sa | awk '{print $1}')
```

添加完成之后，可以在集群中安装你想用的插件了，例如 gitlab-runner。

## 踩坑记录

1. Gitlab 与 Kubernetes 版本兼容问题

   在 Gitlab 中添加 Kubernetes 集群，可能存在两者版本不兼容的问题，这会导致 gitlab 调用 K8s 集群的 API 失败，可能是因为 K8s 不同版本的 api 更新的缘故。尽量使用最新版本的 Gitlab，他会支持更多版本的 K8s API。

   可以通过文档查看 Gitlab 支持的 K8s 版本：https://docs.gitlab.com/ee/user/project/clusters/index.html

2. 如果在添加集群遇到 `is blocked: Requests to the local network are not allowed` 问题，需要设置

   Settings => Network => Outbound requests，将选项 Allow requests to the local network from web hooks and services 勾选即可。
