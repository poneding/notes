# EKS实践 集成Gitlab自动发布（二）

系列介绍如何使用Gitlab CI/CD自动部署应用到EKS（K8s）集群中。本篇介绍如何为Runnr镜像的制作。

上文中创建的Gitlab Runner会持续存活在EKS集群中，但是它不做具体的Pipeline任务，当有Pipeline任务来临时，由它来创建临时的Runner来执行。而临时拆功创建的Runner使用什么容器环境以及具体执行什么任务是由仓库目录下.gitlab-ci.yml文件定义的。

![image-20200731152950901](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200731152950901.png)

## 制作Temp Runner镜像

我们制作这个镜像的目的是为了能让镜像运行起来后，可以完成我们的自动发布任务。比如在容器temp-runner容器需要将我们的代码build成应用镜像，然后将应用镜像发布到EKS集群，可以看到，在容器中我们就必须可以使用docker build功能以及kubectl apply功能。

按照以上的需要，我们制作的镜像至少需要安装好docker 以及kubectl。

Dockerfile如下：

```dockerfile
FROM docker:18

RUN apk add --no-cache curl jq python3 git tar tree && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl
```

> 直接使用docker镜像作为基础镜像，然后安装kubectl

使用命令制作并推送镜像到dockerhub（实际我的镜像推动到了ECR）

```bash
docker build . -t gitlab-runner-base:latest --rm --no-cache
docker push gitlab-runner-base:latest
```

## 仓库配置

项目仓库根目录下新增.gitlab-ci.yml文件，然后文件内容

