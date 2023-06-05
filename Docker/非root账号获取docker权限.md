# Docker 非root账号获取docker权限

默认docker的命令是需要sudo权限的，如果你觉得麻烦，想直接在当前用户下执行docker权限，你可以尝试使用下面这个解决方案。

拢共分两步：

第一步，将当前用户添加到docker组

```shell
sudo usermod -aG docker $USER
```

第二步，授权

```shell
sudo chmod a+rw /var/run/docker.sock
```

快去试试吧。

