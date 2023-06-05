# Linux-安全登录

![202305291417259](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305291417259.jpg)

我们都知道

- root 是 linux 系统默认的最高权限账号
- linux 系统默认的 ssh 端口是 22
- 大多数人习惯使用 user/password 来登录 linux 系统

很遗憾，如果你的系统没有做特殊等登陆配置，那么其他人便可以利用 `ssh ip:22 root/暴力密码` 来破解登入你 的 linux 系统，一旦被他破解，你的系统就可以为他所用了。

但是，我们可以通过以下三种方式来避免发生这类安全问题。

## 1. 禁用 root 账号登录

禁用 root 账号，那么我们就必须创建其他登录账号，这里建议账号名不要为 admin 这类常见用户名。

- 创建用户（以下都基于 ubuntu 系统操作）

```shell
adduser dp
```

- 用户赋权

此时创建的用户不能使用 sudo 权限，考虑将用户加入 sudo 组

```shell
usermod -a -G sudo dp
```

并且，为了避免使用 sudo 权限需要时不时的输入密码的麻烦，进行免密设置。在 /etc/sudoers 文件中新增行。

```shell
dp ALL=(ALL) NOPASSWD: ALL
```

- 到了这一步，应该尝试使用新用户登录系统，如果成功登录再往下继续。
- 禁用 root 登录

打开 /etc/ssh/sshd_config 文件，找到 PermitRootLogin 项，修改该项成如下：

```ini
PermitRootLogin	no
```

保存配置后，重启 ssh 服务:

```shell
systemctl restart ssh
```

至此，root 账号已经被禁用远程登录了。

## 2. 更改 ssh 远程端口

弃用 22 端口，使用 0~65535 范围内随机端口作为 ssh 端口。

要做的是修改 /etc/ssh/sshd_conf 文件，找到 Port 项，修改该项成如下：

```shell
Port 39855
```

保存配置后，重启 ssh 服务:

```shell
service ssh restart
```

至此，服务器 ssh 远程端口已经修改为 39855，不能再使用 22 端口登陆系统了。

## 3. 使用密钥文件登录

本地创建密钥文件：

```bash
ssh-keygen -t rsa -C poneding@gmail.com -f ~/.ssh/id_rsa_poneding
```

以上命令会默认在 ~/.ssh 目录下生成 id_rsa_poneding 私钥文件和 id_rsa_poneding.pub 文件，将 id_rsa_poneding.pub 文件内容追加到服务器 ~/.ssh/authorized_keys 文件中即可。
