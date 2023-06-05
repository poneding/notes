# Linux-history 输出附带日期

![202305291417259](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305291417259.jpg)

如果我们在linux系统中想看历史的命令记录，我们可以通过command命令来获取。

```shell
history
```

输出大概会是下面这种样子，只有简单的command列表。

```tex
    1  ls
    2  top
    4  docker ps
    5  df
    6  ls 
```

那么，如果想知道历史执行的command的时间该怎么做呢。

按照如下步骤，一步一步来。

1. 首先设置HISTTIMEFORMAT变量

```shell
$ HISTTIMEFORMAT="%d/%m/%y %T "
# OR
$ echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bash_profile
```

2. 使用source命令加载HISTTIMEFORMAT变量到当前shell命令窗

```shell
$ . ~/.bash_profile
# OR
$ source ~/.bash_profile
```

3. 再次运行history命令，已经可以输出附带执行时间的history了。

```shell
    1  root 2020/02/18 11:28:19 ls
    2  root 2020/02/18 11:28:21 top
    4  root 2020/02/18 11:28:58 docker ps
    5  root 2020/02/18 11:34:09 df
    6  root 2020/02/18 11:34:15 ls
```
