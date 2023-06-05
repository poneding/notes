# Dockerfile

官方文档参考：https://docs.docker.com/engine/reference/builder/

Dockerfile Linter：https://hadolint.github.io/hadolint/

## Usage

```bash
docker build [work-dir] -t [image-tag] -f [dockerfile-path] --build-arg [arg-key]=[arg-value]
```

## 指令

[Dockerfile reference | Docker Documentation](https://docs.docker.com/engine/reference/builder/#from)

### FROM

### ARG

由docker build命令传的参数。

#### ARG在multi-stage的作用范围

如果ARG放置在第一个FROM之前，那么作用范围是全局的；如果ARG放在FROM之后，那么只对FROM的stage作用。

```dockerfile
ARG USERNAME
FROM alpine
RUN echo hello, ${USERNAME}

FROM alpine
RUN echo hi, ${USERNAME}
```

### CMD

CMD 指令的目的是为一个可执行容器提供初始运行命令或运行参数。

CMD 指令有三种形式：

- 可执行命令 + 命令参数列表，推荐使用

```dockerfile
CMD ["executable","param1","param2"]
```

- 命令参数列表，作为 ENTRYPOINT 的参数

```dockerfile
CMD ["param1","param2"]
```

- Shell 形式，字符串形式的命令

```dockerfile
CMD command param1 param2
```

单个 build stage 只允许存在一个 CMD 指令，如果存在多个 CMD 指令，只有最后一个 CMD 指令生效。

### ENTRYPOINT

ENTRYPOINT 指令用于定义容器启动时被调用的可执行程序。

ENTRYPOINT 指令有两种形式，以运行 node 程序示例：

- exec 形式，推荐使用

```dockerfile
ENTRYPOINT ["node","app.js"]
```

- Shell 形式

```dockerfile
ENTRYPOINT node app.js
```

这两种形式的区别在于 shell 会在容器中运行 `/bin/sh -c node app.js`，而 exec 是直接运行 `node app.js` 命令，因此采用 exec 形式是更为合适的。

### Q&A

#### 1. Dockerfile中ARG无法被CMD使用？

可能你需要修改你的CMD：

```dockerfile
FROM alpine
ARG USERNAME
ENV USERNAME ${USERNAME}
RUN echo ${USERNAME}

# CMD ["echo","${USERNAME}"]  	 # 会原样输出 ${USERNAME}
CMD ["/bin/sh", "-c", "echo ${USERNAME}"] # 输出 dp
# 或者
# CMD echo ${USERNAME}			# 输出 dp
```

```bash
docker build . -t echo-user --build-arg USERNAME=dp
docker run echo-user
```

