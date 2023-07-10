# Linux 命令

[Linux 命令大全](https://www.w3cschool.cn/linux/linux-command-manual.html)

## cat

cat命令用于把档案串连接后传到基本输出（萤幕或加 > fileName 到另一个档案）

### 使用权限

所有使用者

### 语法格式

```shell
cat [-AbeEnstTuv] [--help] [--version] fileName
```

### 参数说明

　　-n 或 --number 由 1 开始对所有输出的行数编号

　　-b 或 --number-nonblank 和 -n 相似，只不过对于空白行不编号

　　-s 或 --squeeze-blank 当遇到有连续两行以上的空白行，就代换为一行的空白行

　　-v 或 --show-nonprinting

### 实例

把 textfile1 的档案内容加上行号后输入 textfile2 这个档案里

```shell
cat -n textfile1 > textfile2
```

把 textfile1 和 textfile2 的档案内容加上行号（空白行不加）之后将内容附加到 textfile3 里。

```shell
cat -b textfile1 textfile2 >> textfile3
```

清空/etc/test.txt档案内容

```shell
cat /dev/null > /etc/test.txt
```

　　cat 也可以用来制作镜像文件。例如要制作软碟的像文件，将软碟放好后打

```shell
cat /dev/fd0 > OUTFILE
```

相反的，如果想把 image file 写到软碟，请打

```shell
cat IMG_FILE > /dev/fd0
```

写入多行到文件：

```shell
cat << EOF > hello.txt
Hello
World
EOF
```

　　**注**：

- \1. OUTFILE 指输出的镜像文件名。
- \2. IMG_FILE 指镜像文件。
- \3. 若从镜像文件写回 device 时，device 容量需与相当。
- \4. 通常用在制作开机磁片。

## chattr

Linux chattr命令用于改变文件属性。

这项指令可改变存放在ext2文件系统上的文件或目录属性，这些属性共有以下8种模式：

1. a：让文件或目录仅供附加用途。
2. b：不更新文件或目录的最后存取时间。
3. c：将文件或目录压缩后存放。
4. d：将文件或目录排除在倾倒操作之外。
5. i：不得任意更动文件或目录。
6. s：保密性删除文件或目录。
7. S：即时更新文件或目录。
8. u：预防以外删除。

### 语法

```shell
chattr [-RV][-v<版本编号>][+/-/=<属性>][文件或目录...]
```

### 参数

　　-R 递归处理，将指定目录下的所有文件及子目录一并处理。

　　-v<版本编号> 设置文件或目录版本。

　　-V 显示指令执行过程。

　　+<属性> 开启文件或目录的该项属性。

　　-<属性> 关闭文件或目录的该项属性。

　　=<属性> 指定文件或目录的该项属性。

### 实例

用chattr命令防止系统中某个关键文件被修改：

```shell
chattr +i /etc/resolv.conf
lsattr /etc/resolv.conf
```

会显示如下属性

```tex
----i-------- /etc/resolv.conf
```

让某个文件只能往里面追加数据，但不能删除，适用于各种日志文件：

```shell
chattr +a /var/log/messages
```

## chgrp

Linux chgrp命令用于变更文件或目录的所属群组。

在UNIX系统家族里，文件或目录权限的掌控以拥有者及所属群组来管理。您可以使用chgrp指令去变更文件与目录的所属群组，设置方式采用群组名称或群组识别码皆可。

### 语法

```shell
chgrp [-cfhRv][--help][--version][所属群组][文件或目录...] 或 chgrp [-cfhRv][--help][--reference=<参考文件或目录>][--version][文件或目录...]
```

### 参数说明

　　-c或--changes 效果类似"-v"参数，但仅回报更改的部分。

　　-f或--quiet或--silent 　不显示错误信息。

　　-h或--no-dereference 　只对符号连接的文件作修改，而不更动其他任何相关文件。

　　-R或--recursive 　递归处理，将指定目录下的所有文件及子目录一并处理。

　　-v或--verbose 　显示指令执行过程。

　　--help 　在线帮助。

　　--reference=<参考文件或目录> 　把指定文件或目录的所属群组全部设成和参考文件或目录的所属群组相同。

　　--version 　显示版本信息。

### 实例

实例1：改变文件的群组属性：

```shell
chgrp -v bin log2012.log
```

输出：

```shell
[root@localhost test]# ll
---xrw-r-- 1 root root 302108 11-13 06:03 log2012.log
[root@localhost test]# chgrp -v bin log2012.log
```

"log2012.log" 的所属组已更改为 bin

```shell
[root@localhost test]# ll
---xrw-r-- 1 root bin  302108 11-13 06:03 log2012.log
```

说明： 将log2012.log文件由root群组改为bin群组

实例2：根据指定文件改变文件的群组属性

```shell
chgrp --reference=log2012.log log2013.log
```

输出：

```shell
[root@localhost test]# ll
---xrw-r-- 1 root bin  302108 11-13 06:03 log2012.log
-rw-r--r-- 1 root root     61 11-13 06:03 log2013.log
[root@localhost test]#  chgrp --reference=log2012.log log2013.log 
[root@localhost test]# ll
---xrw-r-- 1 root bin  302108 11-13 06:03 log2012.log
-rw-r--r-- 1 root bin      61 11-13 06:03 log2013.log
```

说明： 改变文件log2013.log 的群组属性，使得文件log2013.log的群组属性和参考文件log2012.log的群组属性相同

## chmod

Linux/Unix 的文件调用权限分为三级 : 文件拥有者、群组、其他。利用 chmod 可以藉以控制文件如何被他人所调用。

**使用权限** : 所有使用者

### 语法

```shell
chmod [-cfvR] [--help] [--version] mode file...
```

### 参数说明

mode : 权限设定字串，格式如下 :

```shell
[ugoa...][[+-=][rwxX]...][,...]
```

其中：

- u 表示该文件的拥有者，g 表示与该文件的拥有者属于同一个群体(group)者，o 表示其他以外的人，a 表示这三者皆是。
- \+ 表示增加权限、- 表示取消权限、= 表示唯一设定权限。
- r 表示可读取，w 表示可写入，x 表示可执行，X 表示只有当该文件是个子目录或者该文件已经被设定过为可执行。

-c : 若该文件权限确实已经更改，才显示其更改动作

-f : 若该文件权限无法被更改也不要显示错误讯息

-v : 显示权限变更的详细资料

-R : 对目前目录下的所有文件与子目录进行相同的权限变更(即以递回的方式逐个变更)

--help : 显示辅助说明

--version : 显示版本

### 实例

将文件 file1.txt 设为所有人皆可读取 :

```shell
chmod ugo+r file1.txt
```

将文件 file1.txt 设为所有人皆可读取 :

```shell
chmod a+r file1.txt
```

将文件 file1.txt 与 file2.txt 设为该文件拥有者，与其所属同一个群体者可写入，但其他以外的人则不可写入 :

```shell
chmod ug+w,o-w file1.txt file2.txt
```

将 ex1.py 设定为只有该文件拥有者可以执行 :

```shell
chmod u+x ex1.py
```

将目前目录下的所有文件与子目录皆设为任何人可读取 :

```shell
chmod -R a+r *
```

此外chmod也可以用数字来表示权限如 :

```shell
chmod 777 file
```

语法为：

```shell
chmod abc file
```

其中a,b,c各为一个数字，分别表示User、Group、及Other的权限。

#### r=4，w=2，x=1

- 若要rwx属性则4+2+1=7；
- 若要rw-属性则4+2=6；
- 若要r-x属性则4+1=5。

```shell
chmod a=rwx file
```

和

```shell
chmod 777 file
```

效果相同

```shell
chmod ug=rwx,o=x file
```

和

```shell
chmod 771 file
```

效果相同

若用chmod 4755 filename可使此程序具有root的权限

## file

Linux file命令用于辨识文件类型。

通过file指令，我们得以辨识该文件的类型。

### 语法

```shell
file [-beLvz][-f <名称文件>][-m <魔法数字文件>...][文件或目录...]
```

**参数**：

- -b 　列出辨识结果时，不显示文件名称。
- -c 　详细显示指令执行过程，便于排错或分析程序执行的情形。
- -f<名称文件> 　指定名称文件，其内容有一个或多个文件名称呢感，让file依序辨识这些文件，格式为每列一个文件名称。
- -L 　直接显示符号连接所指向的文件的类别。
- -m<魔法数字文件> 　指定魔法数字文件。
- -v 　显示版本信息。
- -z 　尝试去解读压缩文件的内容。
- [文件或目录...] 要确定类型的文件列表，多个文件之间使用空格分开，可以使用shell通配符匹配多个文件。

### 实例

显示文件类型：

```shell
[root@localhost ~]# file install.log
install.log: UTF-8 Unicode text

[root@localhost ~]# file -b install.log      <== 不显示文件名称
UTF-8 Unicode text

[root@localhost ~]# file -i install.log      <== 显示MIME类别。
install.log: text/plain; charset=utf-8

[root@localhost ~]# file -b -i install.log
text/plain; charset=utf-8
```

显示符号链接的文件类型

```shell
[root@localhost ~]# ls -l /var/mail
lrwxrwxrwx 1 root root 10 08-13 00:11 /var/mail -> spool/mail

[root@localhost ~]# file /var/mail
/var/mail: symbolic link to `spool/mail'

[root@localhost ~]# file -L /var/mail
/var/mail: directory

[root@localhost ~]# file /var/spool/mail
/var/spool/mail: directory

[root@localhost ~]# file -L /var/spool/mail
/var/spool/mail: directory
```

## find

Linux find 命令用来在指定目录下查找文件。任何位于参数之前的字符串都将被视为欲查找的目录名。如果使用该命令时，不设置任何参数，则 find 命令将在当前目录下查找子目录与文件。并且将查找到的子目录和文件全部进行显示。

### 语法

```shell
find   path   -option   [   -print ]   [ -exec   -ok   command ]   {} ;
```

参数说明 :

find 根据下列规则判断 path 和 expression，在命令列上第一个 - ( ) , ! 之前的部份为 path，之后的是 expression。如果 path 是空字串则使用目前路径，如果 expression 是空字串则使用 -print 为预设 expression。

expression 中可使用的选项有二三十个之多，在此只介绍最常用的部份。

-mount, -xdev : 只检查和指定目录在同一个文件系统下的文件，避免列出其它文件系统中的文件

-amin n : 在过去 n 分钟内被读取过

-anewer file : 比文件 file 更晚被读取过的文件

-atime n : 在过去 n 天过读取过的文件

-cmin n : 在过去 n 分钟内被修改过

-cnewer file :比文件 file 更新的文件

-ctime n : 在过去 n 天过修改过的文件

-empty : 空的文件-gid n or -group name : gid 是 n 或是 group 名称是 name

-ipath p, -path p : 路径名称符合 p 的文件，ipath 会忽略大小写

-name name, -iname name : 文件名称符合 name 的文件。iname 会忽略大小写

-size n : 文件大小 是 n 单位，b 代表 512 位元组的区块，c 表示字元数，k 表示 kilo bytes，w 是二个位元组。-type c : 文件类型是 c 的文件。

d: 目录

c: 字型装置文件

b: 区块装置文件

p: 具名贮列

f: 一般文件

l: 符号连结

s: socket

-pid n : process id 是 n 的文件

你可以使用 ( ) 将运算式分隔，并使用下列运算。

exp1 -and exp2

! expr

-not expr

exp1 -or exp2

exp1, exp2

### 实例

列出给定目录(base_path)下所有的文件和子目录：

```shell
find base_path -print
```

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/1-18.png)

补充：根据文件名和正则表达式进行搜索，使用选项 -name 或 -iname (忽略大小写)：

```shell
find base_path -name ‘xxx’ -print

find base_path -iname ’xxx‘ -print
```

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/2-11.png)

**否定参数，可以用 ！排除所指定到的模式**

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/3-11.png)

此处将打印出除 txt 文本文件外的的所有文件。

**基于目录深度的搜索**

find 命令指定遍历完所有的子目录。使用 -maxdepth 和-mindefth 可以限制 find 命令遍历的目录深度，并且 find 命令默认不搜索符号链接，可以用 -L 选项改变这种行为。

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/4-9.png)

例如-maxdepth的参数为1时，只匹配当前目录下。

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/5-11.png)

-mindepth 的参数代表了开始进行匹配的目录到 base_path 的最短距离。

**基于文件类型搜索**

使用 -type 可以指定搜索的文件类型，linux/unix 将所有的的一切都视为文件（文件类型有：普通文件 f，目录 d，符号链接 l，字符设备 c，块设备 b，套接字 s，FIFO-p），使用 -type 选项我们能够对文件类型进行过滤。

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/6-10.png)

此处就会只匹配出特定项下的所有普通文件，和目录。

**根据文件的时间戳进行搜索**

Linux/Unix 文件系统中的每一个文件都有三种时间戳，访问时间（-atime）,修改时间（-mtime）,变化时间（-ctime）,单位为天数，用整数指定，数字前加上+，表示大于这个时间；加上-，表示小于这个天数；不加表示刚好这个天数。

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/7-8.png)

此处的文件是我在进行截图之前才创建的，访问，修改，变化时间均小于一天。

当然相应的用分钟作为单位就可以用选项 (-amin）(-mmin)(-cmin)，如下我们测试修改时间

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/8-6.png)

**基于文件大小的搜索**

find 提供了指定文件大小的单位选项进而搜索符合大小文件的功能，这个搜索也常常会让用户感到非常舒服（b:块， c:字节， w:字， k:千字节， M:兆字节， G:吉字节）。

在搜索之前我们先用 ls（list）指令来查看下当前目录下的文件信息：

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/9-5.png)

信息的第五列就是各文件目录的大小（字节），我们通过指定匹配条件来搜索：

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/10-4.png)

经过测试，在开始目录下，文件类型为普通目录，文件大小大于30个字节的文件就是zl.txt了

**基于文件权限和所有权的匹配**

-perm 选项指定了 find 指匹配指定权限的文件，参数为文件对应的权限码。

我们仍然可参考⑥中的所有文件信息的第一列，此处需要掌握一定关于文件权限的知识。如下我们查找权限为 644 的普通文件，即用户可读写，组用户可读，其他可读。

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/11-5.png)

也可以用选项 -user,匹配指定用户所拥有的文件，参数为用户名或者UID

**利用find执行相应操作**

比如删除文件，使用 -delete 选项;删除测试目录下所有的 .txt 普通文件

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/12-4.png)

还可以利用 -exec 选项结合其他命令对文件进行更高效的操作，更改文件的所属权，复制文件等，find 命令使用一对花括号 {} 代表文件名，对于每一个匹配到的文件，find 命令会将{}替换成相应的文件名; 如果 -exec 的命令有多个参数时，需要注意结尾使用 " \; " 或者 "+",前者表示进行转义，不然系统会以为是 find 命令的结尾。

我们将测试目录下的所有的 .txt 文件由用户 lihongbo 转换到用户 litao999，我们必须以 root 用户进行此操作，chown 用于更改权限：

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/13-4.png)

**指定 find 跳过特定的目录**

使用 -prune 选项可以跳过我们在搜寻的的一些明显我们不需要的目录

![Linux/Unix重要find命令详解Linux/Unix重要find命令详解](https://pding.oss-cn-hangzhou.aliyuncs.com/images/14-4.png)

跳过了 ./test1 目录

需要指出的是：选项出现的先后次序我们也应该考虑到内，因为它会影响到整条命令的执行效率。

## echo

## curl

返回httpStatusCode

```bash
curl -I -m 10 -o /dev/null -s -w %{http_code} http://localhost/version
```

>- -I 仅测试HTTP头
>- -m 10 最多查询10s
>- -o /dev/null 屏蔽原有输出信息
>- -s silent 模式，不输出任何东西
>- -w %{http_code} 控制额外输出

## date

查看今天是当年中的第几天

```bash
date '+%j'
```

按照“年-月-日 小时：分钟：秒”的格式查看当前系统时间

```bash
date '+%Y-%m-%d %H:%M:%S'
```

将系统的当前时间设置为2017年9月1日8点30分

```bash
date -s '20170901 8:30:00'
```

## source 命令

source命令将指定函数文件加载到某个shell脚本文件或当前命令窗口。

### 语法

基本使用语法如下：

```shell
source <filename> [arguments]
source functions.sh
source /path/to/functions.sh arg1 arg2
source functions.sh WWWROOT=/apache.jail PHPROOT=/fastcgi.php_jail
```

### 示例

创建一个shell脚本文件mylib.sh，如下：

```shell
#!/bin/bash
JAIL_ROOT=/www/httpd
is_root(){
  [$(id -u) -eq 0] && return $TRUE || return $FALSE
}

function to_lower() 
{
    local str="$@"
    local output     
    output=$(tr '[A-Z]' '[a-z]'<<<"${str}")
    echo $output
}
```

再创建一个shell脚本文件test.sh，在该文件中，可以通过使用如下的语法使用mylib.sh的`JAIL_ROOT`变量，调用`is_root`函数：

```shell
#!/bin/bash
# 使用source命令加载mylib.sh
source mylib.sh
echo "JAIL_ROOT is set to $JAIL_ROOT"
# 调用is_root函数，并打印结果
is_root && echo "You are logged in as root." || echo "You are not logged in as root."
```

运行该文件：

```shell
chmod +x test.sh
./test.sh
```

运行结果如下：

```tex
JAIL_ROOT is set to /www/httpd
You are not logged in as root.
```

在当前命令直接运行

```shell
source mylib.sh
echo $JAIL_ROOT
```

运行结果：

```tex
/www/httpd
```
