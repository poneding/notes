# 设置

## 配置 PATH

在终端使用 `export` 命令设置 `PATH` 并不能全局生效，如果你想设置全局 `PATH` ，可以使用以下这个方法：

```bash
sudo mkdir /etc/paths.d/mypath
vim /etc/paths.d/mypath
/your/path
```

## 查看端口占用并退出程序

有时候使用 VSCode 调试或运行程序后，无法成功推出程序，端口一直占用。

查看端口占用：

```bash
# [port] 替换成你想查看的端口号，例如：sudo lsof -i tcp:8080
sudo lsof -i tcp:[port]
```

上述命令可以得到程序的进程 PID，退出进程：

```bash
# [PID] 替换成程序的进程 PID
sudo kill -9 [PID]
```
