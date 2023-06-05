# Docker-拷贝容器内文件

命令：`docker cp`

## 1. 将Docker容器内文件拷贝到Host

 获取docker容器的Container ID或Name

```shell
sudo docker ps
```

![image-20200227102557616](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200227102557616.png)

使用以下命令从容器内拷出文件

```shell
sudo docker cp [CONTAINER ID/NAME]:[CONTAINER_PATH] [HOST_PATH]
```

例如我需要将容器内/app/appsettings.json文件拷贝到宿主机的~/temp/目录***（该目录必须存在）***下

```shell
sudo docker cp b3e608e28f21:/app/appsettings.json ~/temp/appsettings.json
# 不指定文件名亦可，默认使用原文件名
sudo docker cp b3e608e28f21:/app/appsettings.json ~/temp/
```

## 2. 将Host文件拷贝至Docker容器

同样，需要先获取容器的Container ID或Name；

使用以下命令将文件拷贝至容器内

```shell
sudo docker cp [HOST_PATH] [CONTAINER ID/NAME]:[CONTAINER_PATH]
```

例如我需要将宿主机的~/temp/hello.txt文件拷贝至容器内/app/目录***（该目录必须存在）***下

```shell
sudo docker cp ~/temp/hello.txt b3e608e28f21:/app/hello.txt 
# 不指定文件名亦可，默认使用原文件名
sudo docker cp ~/temp/hello.txt b3e608e28f21:/app/
```

