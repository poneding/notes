# shell 中的引号

## 变量引用

当你要使用变量的时候，用 `$` 来引用， 如果后面要接一些其他字符，可以用 `{}` 括起来。

```shell
#!/bin/bash
WORLD="world world"
echo "hello $WORLD"  # hello world world
echo "hello ${WORLD}2" # hello world world2
```

在 Bash 中要注意 单引号 `'` ，双引号 `"` ，反引号 ` 的区别。

单引号，双引号都能用来保留引号内的为文字值，其差别在于，双引号在遇到 `$(参数替换)` ，反引号 `(命令替换) 的时候有例外，单引号则剥夺其中所有字符的特殊含义。

而反引号的作用 和 `$()` 是差不多的。 在执行一条命令的时候，会先执行其中的命令，再把结果放到原命令中。

```shell
#!/bin/bash
var="music"
sports='sports'
echo "I like $var"   # I like music
echo "I like ${var}" # I like music
echo I like $var     # I like music
echo 'I like $var'   # I like $var
echo "I like \$var"  # I like $var
echo 'I like \$var'  # I like \$var
echo `bash -version` # GNU bash, version 5.0.17(1)-release (x86_64-pc-linux-gnu)...
echo 'bash -version' # bash -version
```
