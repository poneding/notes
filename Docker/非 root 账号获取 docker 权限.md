# 非 root 账号获取 docker 权限

默认 docker 的命令是需要 sudo 权限的，如果你觉得麻烦，想直接在当前用户下执行 docker 权限，你可以尝试使用下面这个解决方案。

拢共分两步：

第一步，将当前用户添加到 docker 组

```shell
sudo usermod -aG docker $USER
```

第二步，授权

```shell
sudo chmod a+rw /var/run/docker.sock
```

快去试试吧。
