# Docker-常用命令

## 启动容器命令

默认需要sudo权限执行

```sh
sudo docker run -d -p 80:80 --name nginx nginx
```

> --name：容器命名
>
> -d：在后台启动
>
> -p：<host端口>：<容器端口>
>
> --rm：容器退出即删除
>
> -it：i-与容器交互，t-终端

### 以root权限进入容器

```shell
sudo docker exec -it -u root nginx bash
```

## 操作镜像命令

#### 查看镜像

```shell
sudo docker images
```

#### 删除镜像

```shell
sudo docker rmi <image>
# or
sudo docker image rm <image>
```

#### 删除所有镜像

```shell
sudo docker rmi $(docker images -q)
```

#### 清除未使用镜像

```shell
sudo docker image prune
# or
sudo docker rmi $(sudo docker images | grep "^<none>" | awk "{print $3}")
```

## 操作容器命令

#### 查看已经退出的容器

```shell
sudo docker ps -a | grep Exited
```

#### 清理已经退出的容器

```shell
sudo docker rm $(sudo docker ps -qf status=exited)
# or
sudo docker rm `sudo docker ps -a | grep Exited | awk '{print $1}'`
```

#### 清除所有容器

> 使用-f参数才能清除所有容器，不使用则只会清理已经退出的容器

```shell
sudo docker rm $(sudo docker ps -a -q) -f
```

#### 清除孤立容器

```shell
sudo docker container prune
```

### 强制删除容器

如果某个Pod突然不可用，那么运行在该节点上的Pod可能会一直处于Terminating的状态，无法移除。这时候如果想强制将该Pod从etcd数据库中删除，可以使用以下命令：

```bash
kubectl delete po <pod-name> -n <namespace> --force --grace-period=0
```

grace-period表示过渡存活期，默认30s，在删除POD之前允许POD慢慢终止其上的容器进程，从而优雅退出，0表示立即终止POD。