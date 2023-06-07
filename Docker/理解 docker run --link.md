# 理解 docker run --link

## 使用方式

```shell
# 前提已经存在一个 container2 在运行
docker run img1 --name container1 --link container2
```

## 作用

container1 连接 container2，达到：

- 与 container2 直接通信
- 获取 container2 的环境变量
