# tee 保存 stderr 到文件

**tee**命令是将stdout写入到某文件当中，但是如何将stderr也写入到文件当中？

示例如下：

1.sh

```shell
echo exec 1.sh start! && \
cat hello.txt && \
echo exec 1.sh end!
```

假如hello.txt文件不存在，执行1.sh文件中的cat命令将报错。如果我们想将执行1.sh文件的输出写入到一个log文件，例如：

```bash
sh 1.sh | tee 1.log
```

执行以上命令，控制台的输出是：

```tex
$ sh 1.sh | tee 1.log
exec 1.sh start!
cat: hello.txt: No such file or directory
```

但是写入到1.log日志文件中的内容是：

```tex
exec 1.sh start!
```

可以看到，并没有将错误输出到日志文件中，如果我们想将错误一并输出到日志文件，该怎么做呢？

使用以下办法：

```bash
sh 1.sh 2&>1 | tee 1.log
```

这下我们就能同时在控制台和日志文件中看到错误输出了。

**科普**

上述命令中使用到的`2>&1`是什么意思？

> 0 stdin，1 stdout，2 stderr
>
> 2>&1：将标准错误重定向至标准输出
