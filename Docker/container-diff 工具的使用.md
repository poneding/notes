# container-diff 工具的使用

![docker](C:\Users\dp\Pictures\docker.png)

## 简介

container-diff 是 google 开源的一款用于分析和比较 Docker 镜像的工具，它可以从多个维度分析一个或者比较两个容器镜像：

- 镜像构建历史
- 镜像文件系统
- 镜像大小
- 软件包管理

项目地址：https://github.com/GoogleContainerTools/container-diff

## 安装

### macOS

```bash
curl -LO https://storage.googleapis.com/container-diff/latest/container-diff-darwin-amd64 && chmod +x container-diff-darwin-amd64 && sudo mv container-diff-darwin-amd64 /usr/local/bin/container-diff
```

### Linux

```bash
curl -LO https://storage.googleapis.com/container-diff/latest/container-diff-linux-amd64 && chmod +x container-diff-linux-amd64 && sudo mv container-diff-linux-amd64 /usr/local/bin/container-diff
# or
curl -LO https://storage.googleapis.com/container-diff/latest/container-diff-linux-amd64 && chmod +x container-diff-linux-amd64 && mkdir -p $HOME/bin && export PATH=$PATH:$HOME/bin && mv container-diff-linux-amd64 $HOME/bin/container-diff
```

### Windows

下载地址：https://storage.googleapis.com/container-diff/latest/container-diff-windows-amd64.exe

下载 exe 文件重命名为 `container-diff.exe`，添加到系统环境变量 PATH 中。

## 使用

分析单个 Docker 镜像

```shell
container-diff analyze <image-name>
```

对比两个 Docker 镜像

```shell
container-diff diff <image1-name> <image2-name>
```

如果不指定 `type`，默认分析/对比的是镜像大小，即 `--type=size`

可以通过指定 `type`，分析/对比特定维度

```shell
container-diff analyze <image-name> --type=<type-name>
container-diff diff <image1-name> <image2-name> --type=<type-name>
```

type 类型支持如下：

- history：镜像构建历史
- file：镜像文件
- size：镜像大小
- rpm：rpm 包管理器
- pip：pip 包管理器
- apt：apt 包管理器
- node：node 包管理器

通过设置多组 `type`，可以一次性分析/对比多个维度，例如：

```bash
container-diff analyze nginx --type=history --type=size
```

通过设置 `--type=file` 和 `--filename=/path/file`，可以比较比较两个 docker 镜像中某目录或文件的区别，例如：

```bash
container-diff diff nginx:v1 nginx:v2 --type=file --filename=/etc/  
```

通过设置 `-j`，可以使用 json 格式输出结果。

通过设置 `-w <file-path>`，可以将结果输入到文件。

更多命令参数可以通过 `-h` 解锁。
