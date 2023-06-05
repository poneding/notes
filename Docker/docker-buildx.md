# Docker 0-1 buildx

```bash
$ docker buildx

Usage:  docker buildx [OPTIONS] COMMAND

Extended build capabilities with BuildKit

Options:
      --builder string   Override the configured builder instance

Management Commands:
  imagetools  Commands to work on images in registry

Commands:
  bake        Build from a file
  build       Start a build
  create      Create a new builder instance
  du          Disk usage
  inspect     Inspect current builder instance
  ls          List builder instances
  prune       Remove build cache
  rm          Remove a builder instance
  stop        Stop builder instance
  use         Set the current builder instance
  version     Show buildx version information

Run 'docker buildx COMMAND --help' for more information on a command.
```

本篇介绍如何使用`docker buildx`命令实现交叉编译不同系统架构下的Docker镜像。

## 安装

如果根据docker官网的安装手册安装docker，会默认安装`docker buildx`。

参照文档：[Docker Buildx | Docker Documentation](https://docs.docker.com/buildx/working-with-buildx/)

**手动安装**

下载地址：https://github.com/docker/buildx/releases/latest

手动下载对应版本的二进制文件，重命名并拷贝到目标目录，例如：

```bash
wget https://github.com/docker/buildx/releases/download/v0.8.1/buildx-v0.8.1.linux-amd64
mv buildx-v0.8.1.linux-amd64 $HOME/.docker/cli-plugins/docker-buildx
```

## 将buildx设置成默认的镜像编译器

因为`docker buildx build`命令后续的大部分参数与`docker build`完全一致，所以可以通过设置命令别名的方式，将buildx作为默认的镜像编译器。

你只需要执行以下命令即可：

```bash
docker buildx install
```

如果需要取消这个命令别名，执行以下命令：

```bash
docker buildx uninstall
```

## 使用

开始一个新的构建，执行命令`docker buildx build .`。

创建实例

```bash
docker buildx create --name demo-builder
# 创建并使用
docker buildx create --use --name demo-builder
```

使用实例

```bash
docker buildx use demo-builder
```

交叉编译

```bash
docker buildx build . -t demo:latest
```

删除实例

```bash
docker buildx rm demo-builder
```
