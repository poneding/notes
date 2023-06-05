# kubebuilder 实战

## 简介

kubebuilder 是一个构建 Operator（CRD + Controller）的框架。

## 安装

### 条件

* kustomize

```bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
```

* controller-gen

```bash
go install sigs.k8s.io/controller-tools/cmd/controller-gen@latest
```

> ⚠️ 注意：以上命令都是直接下载了对应命令工具最新的版本，在使用 `kubebuilder` 创建项目之后，在 `Makefile` 文件中会指定 `kustomize` 和 `controller-gen` 的版本，为了避免不兼容，推荐下载对应指定的版本。

使用以下命令安装 kubebuilder：

```bash
# download kubebuilder and install locally.
GOOS=$(go env GOOS)
GOARCH=$(go env GOARCH)
curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/$GOOS/$GOARCH
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/
```

代码自动补全：

```bash
source <(kubebuilder completion bash)
source <(kubebuilder completion zsh)

# zsh
echo "source <(kubebuilder completion zsh)" >> ~/.zshrc

# bash
echo "source <(kubebuilder completion bash)" >> ~/.bashrc
```

## 创建项目

```bash
mkdir ./kube-acme && cd ./kube-acme
kubebuilder init --domain ketches.cn --repo github.com/ketches/kube-acme

# 如果不开启多 Group 模式，生成的 API 文件路径为：api/{version}
# 开启多 Group 模式，生成 API 的文件路径为 apis/{grouop}/{version}
kubebuilder edit --multigroup
```

> 创建项目后，会在目录中生成 `hack/boilerplate.go.txt` 文件，用于`kubebuilder` 生成 go 文件的版权信息，建议在开始编写代码之前修改该文件，例如作者信息。

## 创建 API

```bash
kubebuilder create api --group acme --version v1alpha1 --kind DNSProvider
# 连续输入 y 确认生成 API 以及 Controller 文件
```

## 在集群中部署

将控制器编译成镜像并推送到镜像仓库：

```bash
make docker-build docker-push IMG=ketches/kube-acme:v0.0.1
```

将控制器部署到集群中：

```bash
make deploy IMG=ketches/kube-acme:v0.0.1
```

## 卸载 CRD

从集群中删除CRD：

```bash
make uninstall
```

## 卸载控制器

从集群中卸载控制器：

```bash
make undeploy
```
