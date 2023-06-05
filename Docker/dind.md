# Docker in Docker

![docker](https://pding.oss-cn-hangzhou.aliyuncs.com/images/docker.png)

`Docker-in-Docker`的意思是在Docker容器中使用docker，就像和在宿主机上使用docker一样，你可以理解为**套娃**。

场景：

如果你的Jenkins是使用Docker容器的方式运行的，如果你想使用Jenkins的Docker插件来为Jenkins Job提供运行容器，这时候你就需要用到Docker-in-Docker；

一般这个技术使用在应用的程序集成中**CI/CD**。

## 1. 挂载主机/var/run/docker.sock

![docker-in-docker-01](https://pding.oss-cn-hangzhou.aliyuncs.com/images/docker-in-docker-01.png)

**Docker容器**

```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock --name docker-in-docker -it docker
```

在运行起来的容器中使用docker：

```bash
$ docker run -v /var/run/docker.sock:/var/run/docker.sock --name docker-in-docker -it docker
/ # docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

可以看到，在该容器中可以像在宿主机一样运行docker容器。

但是，使用`docker ps -a`命令可以查看到宿主机的运行容器，这说明容器的权限是很大的，存在一定的安全隐患：

![image-20201208143849939](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20201208143849939.png)

**Kubernetes Pod**

准备docker-in-docker.yaml文件如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: docker-in-docker
spec:
  containers:
    - name: docker
      image: docker
      command: ["/bin/sh", "-c"]
      args:
        - sleep 300s;
      volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
```

```bash
kubectl apply -f docker-in-docker.yaml
kubectl exec -it docker-in-docker -c docker /bin/sh
```

同样，这种方式也能获取到宿主机的容器。

![image-20210115093238930](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20210115093238930.png)

## 2. 使用Docker-Dind

![docker-in-docker-02](https://pding.oss-cn-hangzhou.aliyuncs.com/images/docker-in-docker-02.png)

**Docker容器**

```bash
docker run --privileged -d --name docker-in-docker docker:dind
docker exec -it docker-in-docker /bin/sh
```

与上面方式不同的是，这种方式运行起来的docker-in-docker无法看到宿主机上的容器。

![image-20210115090727784](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20210115090727784.png)

**Kubernetes Pod**

准备docker-in-docker.yaml文件如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: docker-in-docker
spec:
  containers:
    - name: docker
      image: docker:18
      imagePullPolicy: Always
      env:
        - name: DOCKER_HOST
          value: tcp://localhost:2375
      command: ["/bin/sh", "-c"]
      args:
        - sleep 300s;
    - name: docker-dind
      image: docker:18-dind
      securityContext:
        privileged: true
  restartPolicy: OnFailure
```

> 注意：
>
> 需要两个容器，第一容器由docker镜像运行，第二容器由docker:dind镜像运行；
>
> 第一容器需要设置环境变量：DOCKER_HOST=tcp://localhost:2375；
>
> 第二容器使用特权模式运行。

```bash
kubectl apply -f docker-in-docker.yaml
kubectl exec -it docker-in-docker -c docker /bin/sh
```

## 3. 结束语

前面提到了，由于第一种方式`挂载主机/var/run/docker.sock`，在容器视角依然能获取到宿主机的容器，也能运行或删除容器，存在一定的安全隐患，更推荐使用第二种方式，Over!