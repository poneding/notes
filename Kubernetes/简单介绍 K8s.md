# 简单介绍 K8s

![202306051105607](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202306051105607.png)

## 简介

我们的应用部署趋势由大型单体应用向微服务演变，微服务应用之间解耦，形成可被独立开发、部署、升级、伸缩的软件单元。

另一方面容器技术由于它的轻量级，资源隔离，可移植、部署高效等特性得到了迅速的发展和普及。越来越多的应用选择使用容器来部署，微服务更不例外。

这时，便有了管理微服务+容器的需求，**Kubernetes** 开始大放异彩。

Kubernetes 是基于容器技术的服务器集群管理系统，通过它，可以托管数量庞大的应用集，并且内置完备的集群管理能力，它有能力帮你做到这些：

- 应用的容器化部署、健康检查、自我修复、自动伸缩、滚动更新、资源分配等
- 服务的注册、发现、均衡负载等

Kubernetes 对于运维团队来说，是一个强大的帮手，更自动化的部署和管理应用，更高效的利用硬件资源。

## 基本概念

Kubernetes 集群，后面简称为K8s，主要是由控制节点（Master）和工作节点（Node）组成。

在 Master 节点中运行着三大组件：`kube-api-server`、`kube-controller-manager`、`kube-scheduler`，通常也会将 `etcd` 数据库部署在 Master 节点。

在 Node 节点中，也是需要部署三个主要组件，容器引擎（基本默认 `docker` 了）、`kubelet`、`kube-proxy`。

K8s 的组成结构大致如下图：

![image-20200523001832961](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200523001832961.png)

### Master 节点

负责 K8s 资源的调度管理，由 Master 向 Node 下达控制命令，并且一般运维人员使用 Master 操作和执行命令。

Master 节点扮演的角色相当于 K8s 的大脑，其重要性可想而知，因此建议部署 3 台 Master 节点保证 K8s 的高可用性。

- **kube-api-server**：http rest 接口服务，与 K8s 其他组件通信，负责 K8s 资源的 CURD 的操作入口；

- **kube-controller-manager**：K8s 资源的自动化控制管理中心，如跟踪资源状态，资源修复等；
- **kube-scheduler**：应用调度，为应用自动分配节点等；

- **etcd**：分布式的数据库系统，存储 K8s 中的各种资源信息。

### Node 节点

负责 K8s 应用资源的容器化部署和运行，Node 节点配置要求一般高于 Master，当其中一个 Node 不可用时，部署在其上的 K8s 资源会自动被迁移到可用的 Node。

- **docker**：部署应用的容器引擎；
- **kubelet**：与 kube-api-server 通信，向 Master 注册自己，定时汇报自身 Node 信息，Master 下达调度命令，同时负责容器生命周期的管理；
- **kube-proxy**：实现 service 代理 endpoint 和负载均衡，分配 Node 端口等。

其实了解了 K8s 的整个组成和相关组件服务的功能，我们就能知道如何来管理我们的 K8s 节点了。例如，我们要新增 Node 节点，该如何操作？

原理上新扩 Node 只需要在一台新的机器上安装以上三个服务，然后配置 kubectl 和 kube-proxy 的启动参数，通过 kubelet 向 Master的kube-api-server 提交 Node 注册信息，就可以将 Node 纳入 Master 的调度中心了。

## 工具

- **kubeadm**

  使用 `kubeadm` 快速创建 K8s 集群，一般仅用于学习测试使用。

- **kubectl**

  使用 `kubectl` 命令工具对 K8s 下达操作指令，一般将这个工具安装在 Master 节点。
