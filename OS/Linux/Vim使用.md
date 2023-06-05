# vim 使用

## 设置

```bash
vim /etc/vim/vimrc
```

或者当前环境设置

```bash
:set paste
:set nopaste
:set number
:set nonumber
:set hlsearch
:set nohlsearch
:set cursorline
:set nocursorline
```

## vim删除所有行

```bash
ggdG
```

### 撤销

```shell
u

ctrl+r
```

### 查找

**大小写问题**

默认大小写敏感。

大小写不敏感：/hello\c

大小写敏感：/hello\C

设置大小写敏感：

ecs+:set ignorecase：设置默认忽略大小写敏感

ecs+:set smartcase：如果查找字符中存在大写则自动大小写敏感

**查找当前字符**

### 光标移动

- h：向左
- j：向下
- k：向上
- l：向右

### 替换

- :s/jay/dp/g 替换当前行中所有匹配 jay => dp
- :1,$s/jay/dp/g 替换所有
- :1,5s/jay/dp/g 替换1到5行

### 翻页

- ctrl+f：下一页
- ctrl+d：下半页
- ctrl+b：上一页
- ctrl+u：上半页

### 行操作

- dG：删除当前行到尾行

- dd：删除当前行

- yy：复制当前行
- p：粘贴行
- ddp：下一行

### 退出

如果你没有sudo权限打开了文件，但是你已经编写了很多内容，怎么保存推出呢：

```bash
:w ! sudo tee %
```

保存到另外一个文件：

```bash
:w otherfile # 会生成新文件，修改内容体现在新文件中，原文件不变
```

## 查找

在normal模式下按下`/`即可进入查找模式，输入要查找的字符串并按下回车。 Vim会跳转到第一个匹配。按下`n`查找下一个，按下`N`查找上一个。

Vim查找支持正则表达式，例如`/vim$`匹配行尾的`"vim"`。 需要查找特殊字符需要转义，例如`/vim\$`匹配`"vim$"`。

> 注意查找回车应当用`\n`，而替换为回车应当用`\r`（相当于`<CR>`）。

### 大小写敏感查找

在查找模式中加入`\c`表示大小写不敏感查找，`\C`表示大小写敏感查找。例如：

```shell
/foo\c
```

将会查找所有的`"foo"`,`"FOO"`,`"Foo"`等字符串。

### 大小写敏感配置

Vim 默认采用大小写敏感的查找，为了方便我们常常将其配置为大小写不敏感：

```shell
" 设置默认进行大小写不敏感查找
set ignorecase
" 如果有一个大写字母，则切换到大小写敏感查找
set smartcase 
```

> 将上述设置粘贴到你的`~/.vimrc`，重新打开Vim即可生效。

### 查找当前单词

在normal模式下按下`*`即可查找光标所在单词（word）， 要求每次出现的前后为空白字符或标点符号。例如当前为`foo`， 可以匹配`foo bar`中的`foo`，但不可匹配`foobar`中的`foo`。 这在查找函数名、变量名时非常有用。

按下`g*`即可查找光标所在单词的字符序列，每次出现前后字符无要求。 即`foo bar`和`foobar`中的`foo`均可被匹配到。

### 其他设置

`:set incsearch` 可以在敲键的同时搜索，按下回车把移动光标移动到匹配的词； 按下 Esc 取消搜索。

`:set wrapscan` 用来设置到文件尾部后是否重新从文件头开始搜索。

## 查找与替换

`:s`（substitute）命令用来查找和替换字符串。语法如下：

```shell
:{作用范围}s/{目标}/{替换}/{替换标志}
```

例如`:%s/foo/bar/g`会在全局范围(`%`)查找`foo`并替换为`bar`，所有出现都会被替换（`g`）。

### 作用范围

作用范围分为当前行、全文、选区等等。

当前行：

```shell
:s/foo/bar/g
```

全文：

```shell
:%s/foo/bar/g
```

选区，在Visual模式下选择区域后输入`:`，Vim即可自动补全为 `:'<,'>`。

```shell
:'<,'>s/foo/bar/g
```

2-11行：

```shell
:5,12s/foo/bar/g
```

当前行`.`与接下来两行`+2`：

```shell
:.,+2s/foo/bar/g
```

### 替换标志

上文中命令结尾的`g`即是替换标志之一，表示全局`global`替换（即替换目标的所有出现）。 还有很多其他有用的替换标志：

空替换标志表示只替换从光标位置开始，目标的第一次出现：

```shell
:%s/foo/bar
```

`i`表示大小写不敏感查找，`I`表示大小写敏感：

```shell
:%s/foo/bar/i
# 等效于模式中的\c（不敏感）或\C（敏感）
:%s/foo\c/bar
```

`c`表示需要确认，例如全局查找`"foo"`替换为`"bar"`并且需要确认：

```shell
:%s/foo/bar/gc
```

回车后Vim会将光标移动到每一次`"foo"`出现的位置，并提示

```shell
replace with bar (y/n/a/q/l/^E/^Y)?
```

按下`y`表示替换，`n`表示不替换，`a`表示替换所有，`q`表示退出查找模式， `l`表示替换当前位置并退出。`^E`与`^Y`是光标移动快捷键，参考： [Vim中如何快速进行光标移动](https://harttle.land/2015/11/07/vim-cursor.html)。

## 高亮设置

### 高亮颜色设置

如果你像我一样觉得高亮的颜色不太舒服，可以在 `~/.vimrc` 中进行设置：

```shell
highlight Search ctermbg=yellow ctermfg=black 
highlight IncSearch ctermbg=black ctermfg=yellow 
highlight MatchParen cterm=underline ctermbg=NONE ctermfg=NONE
```

上述配置指定 Search 结果的前景色（foreground）为黑色，背景色（background）为灰色； 渐进搜索的前景色为黑色，背景色为黄色；光标处的字符加下划线。

> 更多的CTERM颜色可以查阅：http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim

### 禁用/启用高亮

有木有觉得每次查找替换后 Vim 仍然高亮着搜索结果？ 可以手动让它停止高亮，在normal模式下输入：

```shell
:nohighlight
" 等效于
:nohl
```

其实上述命令禁用了所有高亮，只禁用搜索高亮的命令是`:set nohlsearch`。 下次搜索时需要`:set hlsearch`再次启动搜索高亮。

#### 延时禁用

怎么能够让Vim查找/替换后一段时间自动取消高亮，发生查找时自动开启呢？

```shell
" 当光标一段时间保持不动了，就禁用高亮
autocmd cursorhold * set nohlsearch
" 当输入查找命令时，再启用高亮
noremap n :set hlsearch<cr>n
noremap N :set hlsearch<cr>N
noremap / :set hlsearch<cr>/
noremap ? :set hlsearch<cr>?
noremap * *:set hlsearch<cr>
```

> 将上述配置粘贴到`~/.vimrc`，重新打开vim即可生效。

#### 一键禁用

如果延时禁用搜索高亮仍然不够舒服，可以设置快捷键来一键禁用/开启搜索高亮：

```shell
noremap n :set hlsearch<cr>n
noremap N :set hlsearch<cr>N
noremap / :set hlsearch<cr>/
noremap ? :set hlsearch<cr>?
noremap * *:set hlsearch<cr>

nnoremap <c-h> :call DisableHighlight()<cr>
function! DisableHighlight()
    set nohlsearch
endfunc
```

希望关闭高亮时只需要按下 `Ctrl+H`，当发生下次搜索时又会自动启用。

## 参考阅读

- XTERM 256色：http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim
- Vim Wikia - 查找与替换：http://vim.wikia.com/wiki/Search_and_replace
- 用 Vim 打造 IDE 环境：https://harttle.land/2015/11/04/vim-ide.html

本文采用 [知识共享署名 4.0 国际许可协议](http://creativecommons.org/licenses/by/4.0/)（CC-BY 4.0）进行许可，转载注明来源即可： https://harttle.land/2016/08/08/vim-search-in-file.html。学识粗浅写作仓促，如有错误辛苦评论或 [邮件](mailto:yangjvn@126.com) 指出。

## 写入、保存、退出

```shell
:q[uit]                 " 退出
:q!                     " 强制退出
:w[rite]                " 保存
:w!                     " 强制保存，能不能保存成功取决于用户对文件的权限
:w ! sudo tee %         " 如果没有权限保存，试试这个命令
ZZ                      " 两个大写的 Z，没有修改直接退出，有修改保存后退出
:w newfilename          " 另存为新文件
:1, 10 w newfilename    " 将 1 到 10 行的内容另存为新文件
:1, 10 w >> filename    " 将 1 到 10 行的内容另存为新文件
:r filename             " 将目标文件的内容追加到当前光标下一行
:3 r filename           " 将目标文件的内容追加到第 3 行一下
:! ls                   " 暂时离开 Vim 查看当前目录的文件，回车后返回 Vim
```

## 光标移动

```shell
h           " 方向键 ←
j           " 方向键 ↓
k           " 方向键 ↑
l           " 方向键 →
0           " 移动到行首
$           " 移动到行尾的回车符
g_          " 移动到行尾最后一个非空字符
gg          " 移动到第一行
G           " 移动到最后一行"
w           " 移动到下一个单词开头
e           " 移动到单词的结尾
b           " 移动到单词的开头
" 不常用
nh          " 向左移动 n 格，n 为数字
nl          " 向右移动 n 格
nj          " 向下移动 n 行
nk          " 向上移动 n 行
n<space>    " 向右移动 n 格，同 nl
H            " 移动到当前屏幕第一行的第一个字符
M            " 移动到当前屏幕中间行的第一个字符
L            " 移动到当前屏幕最后一行的第一个字符
+            " 移动到非空白字符的下一行
-            " 移动到非空白字符的上一行
:n<cr>      " 跳转到第 n 行h           " 方向键 ←
j           " 方向键 ↓
k           " 方向键 ↑
l           " 方向键 →
0           " 移动到行首
$           " 移动到行尾的回车符
g_          " 移动到行尾最后一个非空字符
gg          " 移动到第一行
G           " 移动到最后一行"
w           " 移动到下一个单词开头
e           " 移动到单词的结尾
b           " 移动到单词的开头
" 不常用
nh          " 向左移动 n 格，n 为数字
nl          " 向右移动 n 格
nj          " 向下移动 n 行
nk          " 向上移动 n 行
n<space>    " 向右移动 n 格，同 nl
H            " 移动到当前屏幕第一行的第一个字符
M            " 移动到当前屏幕中间行的第一个字符
L            " 移动到当前屏幕最后一行的第一个字符
+            " 移动到非空白字符的下一行
-            " 移动到非空白字符的上一行
:n<cr>      " 跳转到第 n 行
```

## 翻页

```shell
<c-f>   " 向下移动一页
<c-d>   " 向下移动半页
<c-b>   " 向上移动一页
<c-u>   " 向上移动半页
```

## 查找与替换

```shell
/word   " 从光标位置向下搜索 word 单词
?word   " 从光标位置向上搜索 word 单词
n       " 英文字母 n，根据 / 或 ? 搜索的方向定位到下一个匹配目标
N       " 与 n 相反，定位匹配目标
:n1,n2s/word1/word2/g   " n1, n2 表示数字，替换 n1 行到 n2 行的单词
:1,$s/word1/word2/g     " 全文替换，也可以写成 :%s/word1/word2/g
:1,$s/word1/word2/gc    " 全文替换，并出现确认提示
```

## 复制、粘贴、删除

```bash
x           " 向后删除一个字符
nx          " 向后删除 n 个字符
X           " 向前删除一个字符
nX          " 向前删除 n 个字符
dd          " 删除当前行
ndd         " 向下删除 n 行
d1G / dgg   " 删除第一行到当前行的数据
dG          " 删除当前行到最后一行的数据
d$          " 删除当前字符到行尾
D           " 删除当前字符到行尾
d0          " 从行首删除到当前字符
yy          " 复制当前行
Y           " 复制当前行
nyy         " 从当前行开始复制 n 行
y1G / ygg   " 从第一行复制到当前行
yG          " 从当前行复制到最后一行
y0          " 从行首复制到当前字符
y$          " 从当前字符复制到行尾
p, P        " 黏贴，p 黏贴到光标下一行，P 黏贴到光标上一行
yyp         " 复制并粘贴
ddp         " 删除并粘贴，相当于下移当前行
"+y         " 复制本文到系统剪切板
"+p         " 粘贴系统剪切板到 Vim（不会影响文本格式）
```

## 插入

```shell
i   " 在光标前进入 insert 模式
I   " 在当前行左边第一个非空字符前进入 insert 模式，类似其他编辑器的 <c-a> 快捷键
a   " 在光标后进入 insert 模式
A   " 在当前行右边第一个非空字符前进入 insert 模式，类似其他编辑器的 <c-e> 快捷键
o   " 在光标的下一行插入
O   " 在光标的上一行插入
s   " 删除当前字符，并进入 insert 模式
S   " 删除当前行，并进入插入模式
vc  " 删除当前字符，并进入 insert 模式
cc  " 删除当前行，并进入插入模式
c0  " 删除光标位置到行首，并进入 insert 模式
cg_ " 删除光标位置到行尾最后一个非空字符，并进入 insert 模式
ce  " 删除光标位置到单词末尾，并进入 insert 模式
cw  " 删除光标位置到单词末尾，并进入 insert 模式
ciw " 删除当前单词，并进入 insert 模式
cip " 删除整个段落，并进入 insert 模式
ci( " 删除当前括号内的内容，并进入 insert 模式 适用于 ([{<'` 等所有成对的标签
```

## 撤销重做

```shell
u       " 撤销
<c-r>   " 重做
.       " 重复完成操作
```

## 替换

```shell
r   " 替换单个字符，自动返回 normal 模式
R   " 连续替换多个字符，手动 <esc> 返回 normal 模式
```

## 大小写

```shell
~       " 当前字符大小写反转
g~~     " 正行字符大小写反转
vu      " 当前字符小写
vU      " 当前字符大写
vU      " 当前字符大写
viwu    " 当前字符小写
viwU    " 当前字符大写
ggguG   " 文本所有字符小写
gggUG   " 文本所有字符大写
:%s/\<./\u&/g       " 将所有单词首字母大写（需要使用 :nohls 去掉高亮）
:%s/\<./\l&/g       " 将所有单词首字母小写
:%s/.*/\u&          " 将每行第一个字母大写
:%s/.*/\l&          " 将每行第一个字母小写
```

## 多窗口操作

```shell
:sp filename        " 上下分割窗口
:vs[p] filename     " 左右分割窗口
<c-w>h[j[k[l]]]     " 根据方向键移动光标到该方向的窗口上
<c-w>[N]>           " N 位数字，可选，增加当前窗口 N 列宽"
<c-w>[N]<           " N 位数字，可选，减少当前窗口 N 列宽"
<c-w>[N]+           " N 位数字，可选，增加当前窗口 N 行高"
<c-w>[N]-           " N 位数字，可选，减少当前窗口 N 行高"
<c-w>=              " 将所有窗口设置等宽高
<c-w>[N]n           " N 位数字，可选，打开一个新窗口 N 行高，默认为整个窗口的一半"
<c-w>[N]s           " N 位数字，可选，将当前窗口垂直分割为上下两个窗口展示"
                    " 新窗口可以为 N 行高，默认为整个窗口的一半"
                    " 类似于 :sp current_file"
<c-w>[N]v           " N 位数字，可选，将当前窗口水平分割为左右两个窗口展示"
                    " 新窗口可以为 N 列宽，默认为整个窗口的一半"
                    " 类似于 :vs current_file"
<c-w>o              " 关闭除当前窗口外的所有窗口
<c-w>r              " 顺时针转动窗口
<c-w>R              " 逆时针转动窗口
<c-w>x              " 对调左右或上下两个对应的窗口
<c-w>q              " 退出窗口
:q                  " 退出窗口
```

## 多文件编辑

```bash
vim file1 file2     " 同时打开两个文件
:files              " 查看现在编辑的文件列表，%a 代表正在操作哪个文件
  1 %a   "file1"                        line 1
  2      "file2"                        line 0
:n                  " 跳到下一个文件，这里的 n 就是字母
:N                  " 跳到上一个文件
```

