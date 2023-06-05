# K3s

k3s 是一款轻量级的 Kubernetes 发行版，专为物联网及边缘计算设计。

## 要求

K3s 有望在大多数现代 Linux 系统上运行。

**规格要求**

-   CPU: 1 核
-   Memory：512M

**端口要求**

K3s Server 节点的入站规则如下：

| 协议 | 端口      | 源                       | 描述                                          |
| ---- | --------- | ------------------------ | --------------------------------------------- |
| TCP  | 6443      | K3s agent 节点           | Kubernetes API Server                         |
| UDP  | 8472      | K3s server 和 agent 节点 | 仅对 Flannel VXLAN 需要                       |
| UDP  | 51820     | K3s server 和 agent 节点 | 只有 Flannel Wireguard 后端需要               |
| UDP  | 51821     | K3s server 和 agent 节点 | 只有使用 IPv6 的 Flannel Wireguard 后端才需要 |
| TCP  | 10250     | K3s server 和 agent 节点 | Kubelet metrics                               |
| TCP  | 2379-2380 | K3s server 节点          | 只有嵌入式 etcd 高可用才需要                  |

## 启动

```bash
curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -
# Check for Ready node, takes maybe 30 seconds
k3s kubectl get node
```

## 梧桐 Region 安装 k3s

安装前提：

-   docker

-   helm 3.0+
-   80，443，6060，6443，7070，8443 端口可访问
-   nfs `sudo apt install nfs-common -y`

```bash
curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | INSTALL_K3S_VERSION="v1.22.6+k3s1" INSTALL_K3S_MIRROR=cn sh -s - server --node-ip "192.168.0.41,116.63.181.152,127.0.0.1" --docker --disable traefik
```

> 使用 --docker 参数指定 docker 作为容器引擎：k3s 默认使用 docker 作为容器引擎，但是目前梧桐 PaaS 还不支持；
>
> 使用 --disable traefik 关闭 k3s 默认的 ingress controller，梧桐 PaaS 默认使用 wt-gateway，避免端口冲突。

默认生成的k3s 配置文件位置：`/etc/rancher/k3s/k3s.yaml`，可以将其拷贝至 `~/.kube/config`，以便 helm 等工具可以默认连接到 k3s。

自动部署清单：`/var/lib/rancher/k3s/server/manifests/`

## 卸载

```bash
/usr/local/bin/k3s-uninstall.sh
```

## 汇总

- k3s 默认使用的 local-path 存储不支持 RWX 模式，所以还是得搭建存储服务 nfs 或者 longhorn；
