# shell if 学习

## IF 条件表达式

`if`  后面需要接者 `then`：

```shell
if [ condition-for-test ]
then
  command
  ...
fi
```

或者，

```shell
if [ condition-for-test ]; then
  command
  ...
fi
```

如：

```shell
#!/bin/bash
 
VAR=myvar
if [ $VAR = myvar ]; then
    echo "1: \$VAR is $VAR"   # 1: $VAR is myvar
fi
if [ "$VAR" = myvar ]; then
    echo "2: \$VAR is $VAR"   # 2: $VAR is myvar
fi
if [ $VAR = "myvar" ]; then
    echo "3: \$VAR is $VAR"   # 3: $VAR is myvar
fi
if [ "$VAR" = "myvar" ]; then
    echo "4: \$VAR is $VAR"   # 4: $VAR is myvar
fi
```

上面，我们在比较时，可以用双引号把变量引用起来。

但要注意单引号的使用。

```shell
#!/bin/bash
VAR=myvar
if [ '$VAR' = 'myvar' ]; then
    echo '5a: $VAR is $VAR'
else
    echo "5b: Not equal."
fibas
# Output:
# 5b: Not equal.
```

上面这个就把  `'$VAR'`  当一个字符串了。

但如果变量是多个单词，我们就必须用到双引号了，如

```shell
#!/bin/bash

# 这样写就有问题
VAR1="my var"
if [ $VAR1 = "my var" ]; then
    echo "\$VAR1 is $VAR1"
fi
# Output
# error [: too many arguments

# 用双引号
if [ "$VAR1" = "my var" ]; then
    echo "\$VAR1 is $VAR1"
fi
```

总的来说，双引号可以一直加上。

## 空格问题

比较表达式中，如果 `=` 前后没有空格，那么整个表法式会被认为是一个单词，其判断结果为 `True`.

```shell
#!/bin/bash
 
VAR2=2
#  由于被识别成一个单词， [] 里面为 true
if [ "$VAR2"=1 ]; then
    echo "$VAR2 is 1."
else
    echo "$VAR2 is not 1."
fi
# Output
# 2 is 1.

# 前后加上空格就好了
if [ "$VAR2" = 1 ]; then
    echo "$VAR2 is 1."
else
    echo "$VAR2 is not 1."
fi
# Output
# 2 is not 1.
```

另外需要注意的是， 在判断中，中括号 `[`  和变量之间一定要有一个空格，`=` 或者 `==`。 如果缺少了空格，你可能会到这类似这样的错误：`unary operator expected’ or missing`]` 。

```shell
# 正确， 符号前后有空格
if [ $VAR2 = 1 ]; then
    echo "\$VAR2 is 1."
else
    echo "It's not 1."
fi
# Output
# 2 is 1.

# 错误， 符号前后无空格
if [$VAR2=1]; then
    echo "$VAR2 is 1."
else
    echo "It's not 1."
fi
# Output
# line 3: =1: command not found
# line 5: [=1]: command not found
# It's not 1.
```

## 文件测试表达式

对文件进行相关测试，判断的表达式如下：

| 表达式              | True                                     |
| :------------------ | :--------------------------------------- |
| *file1* -nt *file2* | *file1* 比 *file2* 新。                  |
| *file1* -ot *file2* | *file1* 比 *file2* 老。                  |
| -d *file*           | 文件*file*存在，且是一个文件夹。         |
| -e *file*           | 文件 *file* 存在。                       |
| -f *file*           | 文件*file*存在，且为普通文件。           |
| -L *file*           | 文件*file*存在，且为符号连接。           |
| -O *file*           | 文件 *flle* 存在, 且由有效用户 ID 拥有。 |
| -r *file*           | 文件 *flle* 存在, 且是一个可读文件。     |
| -s *file*           | 文件 *flle* 存在, 且文件大小大于 0。     |
| -w file             | 文件 *flle* 可写入。                     |
| -x file             | 文件 *flle* 可写执行。                   |

可以使用 `man test` 查看详细的说明。

当表达式为 `True` 时，测试命令返回退出状态 0，而表达式为 `False` 时返回退出状态1。

```shell
#!/bin/bash
FILE="/etc/resolv.conf"
if [ -e "$FILE" ]; then
  if [ -f "$FILE" ]; then
      echo "$FILE is a file."
  fi
  if [ -d "$FILE" ]; then
      echo "$FILE is a directory."
  fi
  if [ -r "$FILE" ]; then
      echo "$FILE is readable."
  fi
fi
```

## 字符串比较表达式

| 表达式                                      | True                      |
| :------------------------------------------ | :------------------------ |
| *string1 = string2* 或 *string1 == string2* | 两字符相等                |
| *string1* != *string2*                      | 两个字符串不相等          |
| *string1* > *string2*                       | *string1* 大于 *string2*. |
| *string1* < *string2*                       | *string1* 小于*string2*.  |
| -n *string*                                 | 字符串长度大于0           |
| -z *string*                                 | 字符串长度等于0           |

```shell
#!/bin/bash
STRING=""
if [ -z "$STRING" ]; then
  echo "There is no string." >&2 
  exit 1
fi

# Output
# There is no string.
```

其中 `>&2` 将错误信息定位到标准错误输出。

## 数字比较表达式

下面这些是用来比较数字的一些表达式。

| […]                   | ((…))                  | True                |
| :-------------------- | :--------------------- | :------------------ |
| [ “int1” -eq “int2” ] | (( “int1” == “int2” )) | 相等.               |
| [ “int1” -nq “int2” ] | (( “int1” != “int2” )) | 不等.               |
| [ “int1” -lt “int2” ] | (( “int1” < “int2” ))  | int2 大于 int1.     |
| [ “int1” -le “int2” ] | (( “int1” <= “int2” )) | int2 大于等于 int1. |
| [ “int1” -gt “int2” ] | (( “int1 > “int2” ))   | int1 大于 int2      |
| [ “int1” -ge “int2” ] | (( “int1 >= “int2” ))  | int1 大于等于 int2  |
