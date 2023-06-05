# Docker知识

[TOC]

## 容器技术

​        容器是轻量级的操作系统级虚拟化，允许我们在资源隔离的进程中运行应用程序及其依赖项。运行应用程序所需的所有必要组件都打包为一个镜像，可以重复使用。当一个镜像被执行时，它在一个隔离的环境中运行，不共享内存、CPU或主机操作系统的磁盘。这样可以保证容器内的进程不能监视容器外的任何进程。

### 容器和虚拟机

​        容器本身运行在Linux中，与其他容器共享主机的内核。运行一个独立的进程，不影响其他进程，占用额定的资源。虚拟机则是运行一整个操作系统，提供的资源相对更大，用来独立部署应用的话一般会有资源溢出的问题。从下图可以看出容器引擎Docker与VM的区别。

![1570780061309](https://pding.oss-cn-hangzhou.aliyuncs.com/images/1570780061309.png)

​        容器可以看作是一种轻量级的操作系统，它与传统的Linux操作系统对比拥有着众多优势：

1. **将n个应用部署在n个容器中与部署在1个Linux系统中**
   
   | 容器                    | Linux系统         |
   | --------------------- | --------------- |
   | 容器资源隔离受限，容器内的应用之间互不影响 | 不同应用共享资源，应用资源制约 |
   | 部署应用无需考虑环境配置          | 需要正确的准备应用环境     |
   |                       |                 |

2. **将n个应用部署在n个容器中与部署在m个Linux系统中**
   
   | 容器             | Linux系统   |
   | -------------- | --------- |
   | 轻量级，本身占用资源少    | 系统本身占用资源多 |
   | 开销少，启动速度快，性能更高 | 开销多，启动速度慢 |
   |                |           |

3. **应用的交付部署迁移扩展**
   
   ​        由于应用镜像的存在，应用的部署和应用的迁移变得相当的简单。而部署在虚拟机中应用在迁移之前，常常会因为准备操作系统，应用环境而手忙脚乱，焦头烂额。

## Docker

### Docker是什么

​        开源的应用容器引擎，基于Linux Container，通过Linux Namespace和cgroups实现进程和资源的隔离、资源限制。

​        是开发人员和运维人员开发、部署和运行带有容器的应用程序的平台，使用Linux

​        使用Docker可以更加快速的实现应用打包，测试，交付和部署。

> Docker在0.9版本之前基于Linux Container实现，0.9版本之后基于libcontainer实现，在1.11版本后改为基于runC和containerd实现。

### Docker架构

![img](https://pding.oss-cn-hangzhou.aliyuncs.com/images/docker-architecture.png)

> 从以上的架构图中可以看出Docker包含的组件：
> 
> - Docker Client
> - Docker Daemon
> - Docker Image
> - Docker Registry
> - Docker Container

### Docker Client

​        Docker客户端是Docker的用户界面，它可以接受用户命令和配置标识，并与Docker daemon通信。图中，docker build等都是Docker的相关命令。

### Docker Deamon

​        Docker daemon是一个运行在宿主机（DOCKER_HOST）的后台进程。我们可通过Docker客户端与之通信。

### Docker Image

​        包含应用程序以及应用程序依赖的运行环境的只读的文件集合，通过运行镜像来产生一个个的Docker容器。

#### 镜像分层存储架构

#### 镜像的基本命令

**Build Image（Dockerfile）**

​        Docker一般使用Dockerfile构建镜像，Dockerfile中包含构建新镜像的执行命令语句，可以参考【4.6 Dockerfile】。

​        构建镜像的命令如下：

```shell
$ docker build -t myapp:v1 .
```

> 命令说明：
> 
> ​    -t :    给生成的镜像打上tag
> 
> ​    myapp:v1 :    镜像名
> 
> ​    . :    Dockerfile文件路径

**Push Image**

```shell
$ docker push [user name]/[image name]
```

> 默认推送到docker hub上。

**Pull Image**

```shell
$ docker pull [user name]/[image name]
```

> 默认从docker hub上拉取。

### Docker Registry

### Docker Container

​        镜像运行起来后就是一个Container。

### Docker Image和Docker Container关系

#### 电灯泡

**构造**

> - 灯丝：开发人员交付的应用程序包
> - 玻璃灯壳：应用程序包的运行环境

**类比Docker概念**

> - 一个单独灯泡 ==> Docker Image，通电的灯泡 ==> Docker Container
> - 完整的一个灯泡（灯丝、玻璃灯壳）提供给用户，用户拧上灯泡，通电可用 ==>应用程序、运行环境、配置数据一股脑的打包成镜像，只要拿到镜像，到处都可以直接运行起来

## Dockerfile

### Dockerfile命令

**COPY-复制文件**

```
COPY [--chown=<user>:<group>] <源路径>... <目标路径>
COPY [--chown=<user>:<group>] ["<源路径1>",... "<目标路径>"]
```

**ADD-高级复制**

​        包含复制文件，解压文件，远程下载等。 

**CMD-容器启动命令**

**ENTRYPOINT-入口点**

## Docker Compose

## Docker实战

### 应用程序准备

### dockerfile编写

### 生成镜像

### 推送镜像到docker hub

### 本地删除镜像

### 从docker hub拉取镜像

### 镜像运行

### 坑记录

## Docker进阶

### Docker数据持久化

Docker中两种持久化数据的方式：

1. **数据卷（Data Volumes）**
   
   绕过UFS(Unix File System)，供一个或多个容器使用的特殊目录。
   
   > - 数据卷在容器之间共享和重用
   > - 数据卷更新不影响镜像，镜像是只读的
   > - 数据卷独立于容器，容器删除了数据卷依然在
   > - 一个容器可以挂载多个数据卷
   
   创建数据卷：
   
   ```shell
   $ docker volume create myvol
   ```

```shell
   $ docker run --name mynginx -v /nginxvolume nginx
```

   启动容器的同时挂载到

2. **数据卷容器（Data Volumes Dontainers**）
   
   如果数据在容器之间共享，考虑使用数据卷容器。

### Docker网络管理

### Network命令
