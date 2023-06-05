# Docker 0-1 理解docker run --link

## 使用方式

```shell
# 前提已经存在一个container2在运行
docker run img1 --name container1 --link container2
```

## 作用

container1连接container2，达到：

- 与container2直接通信
- 获取container2的环境变量