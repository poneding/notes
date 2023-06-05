# 安装 Kubernetes

## 要求

* Master 节点 CPU >= 2；
* 所有节点内存 >= 2 GB；
* 节点之间网络互通，节点主机名不重复；
* ApiServer 服务开通 6443 端口（例如：安全组）。

## 准备

禁用交换分区：

```bash
sudo swapoff -a

vim /etc/fstab
# 注视文件中包含 swap 的行
```

安装内核，配置系统：

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
```

## 开始

> ⚠️ 以 root 账号执行。

安装 Docker：

```bash
sudo apt-get remove docker docker-engine docker.io containerd runc

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

安装容器运行时（正式环境建议安装 [`containerd`](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)），这里列出的是安装 `cri-dockerd` 的命令：

```bash
# 下载源码
git clone https://github.com/Mirantis/cri-dockerd.git

# 安装 Go，如果已经安装可以省去
wget https://storage.googleapis.com/golang/getgo/installer_linux
chmod +x ./installer_linux
./installer_linux
source ~/.bash_profile

# 编译 cri-dockerd
cd cri-dockerd
mkdir bin
go build -o bin/cri-dockerd
mkdir -p /usr/local/bin
install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
cp -a packaging/systemd/* /etc/systemd/system
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
systemctl daemon-reload
systemctl enable cri-docker.service
systemctl enable --now cri-docker.socket
```

安装 kubeadm、kubectl、kubelet：

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# 国内网络使用下面命令替换
# curl -fsSL https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -

cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# 国内网络使用下面命令替换
# cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
# deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
# EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## 安装集群

确保容器运行时与 `kubelet` 所使用的 `cgroup driver` 一致。

例如，查看 Docker 运行时设置的 Cgroup Driver：

```bash
$ docker info | grep "Cgroup Driver"
 Cgroup Driver: systemd
```

docker 设置使用 systemd 作为 cgroup driver：

```bash
cat /etc/docker/daemon.jsonbash
{
  ...
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ]
}
```

`kubelet` 设置使用 `systemd` 作为 cgroup driver：

```bash
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
...
Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=systemd"
...
```

初始化集群

国内网络需要提前拉取 `registry.k8s.io/pause:3.6` 镜像:

```bash
docker pull registry.aliyuncs.com/google_containers/pause:3.6
docker tag registry.aliyuncs.com/google_containers/pause:3.6 registry.k8s.io/pause:3.6
```

```bash
sudo kubeadm init \
  --pod-network-cidr 10.244.0.0/16 \
  --kubernetes-version 1.27.2 \
  --control-plane-endpoint=34.143.183.48:6443 \
  --ignore-preflight-errors=Swap \
  --cri-socket=unix:///var/run/cri-dockerd.sock
```

> 1. 需要确保 `--control-plane-endpoint` 端点在执行环境是可以访问的，如果参数值为服务器的公网 IP，那么你可能需要对安全组开通 6443 端口;
> 2. 国内网络添加命令参数：`--image-repository registry.aliyuncs.com/google_containers`&#x20;

集群成功创建后，将 kubeconfig 文件拷贝到 ～/.kube/config：

```bash
mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

去除 Master 节点不可调度的污点：

```bash
kubectl taint node --all node-role.kubernetes.io/control-plane-
```

## 安装网络插件

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

> 需要确保 `kubeadm init` 初始化集群时 `--pod-network-cidr`值 配置值为 `10.244.0.0/16`，否则则需要调整 `kube-flannel.yaml` 中的默认配置，与 `--pod-network-cidr` 保持一致。

## 安装网关控制器

选择安装 ingress-nginx：

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.1/deploy/static/provider/baremetal/deploy.yaml
```

国内网络需要提前拉取镜像：

```bash
# 需要提前使用 github.com/poneding/image2 工具迁出镜像
docker pull registry.cn-hangzhou.aliyuncs.com/poneding/controller:v1.7.1
docker tag registry.cn-hangzhou.aliyuncs.com/poneding/controller:v1.7.1 registry.k8s.io/ingress-nginx/controller:v1.7.1

docker pull registry.cn-hangzhou.aliyuncs.com/poneding/kube-webhook-certgen:v20230312-helm-chart-4.5.2-28-g66a760794
docker tag registry.cn-hangzhou.aliyuncs.com/poneding/kube-webhook-certgen:v20230312-helm-chart-4.5.2-28-g66a760794 registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20230312-helm-chart-4.5.2-28-g66a760794
```

执行以上命令安装的ingress-controller 使用 NodePort 的方式对外暴露网关服务，如果想使用 80，443 端口需要做以下调整：

```bash
# Pod 添加 hostnetwork 配置
$ kubectl edit deployments.apps -n ingress-nginx ingress-nginx-controller
spec:
  template:
    spec:
      hostNetwork: true
      
# 删除 NodePort 服务
$ kubectl delete service -n ingress-nginx ingress-nginx-controller
```
