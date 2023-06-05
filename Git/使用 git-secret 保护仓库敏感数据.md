# 使用 git-secret 保护仓库敏感数据

如何保护 git 仓库中的敏感数据，例如数据库连接字符串，账号密码等？

首先，最好先将仓库设置成私有仓库！然后，

* 第一种方式：带有敏感数据的文件加入到. gitignore，不提交到仓库中；
* 第二种方式：敏感数据库文件加密后再提交到仓库中，这个就是今天要说的 **git-secret**。

这两种方式都有优缺点：

第一种方式，较为靠谱，敏感文件在 git 仓库之外，根本上避免仓库敏感数据的泄露，但是敏感文件不受版本控制了，开发人员需要在其他频道同步敏感文件的更新，而且使用到自动部署时需要另外去拉取敏感数据，最好是有自己的敏感数据配置中心统一管理；

第二种方式，使用 git-secret 加密敏感文件，这样敏感文件被仓库 ignore 掉，转而提交加密后的文件，但是敏感文件如果更新了开发人员要记得再次加密。

## **git-secret 简介**

git-secret 是一个在 git 仓库中加密文件的工具，将敏感文件加密，得到加密文件，将文件保存到仓库中，这样敏感文件也是版本控制，你可以获取到该文件的所有提交记录。

使用 gpg 和所有信任用户的公钥加密文件，每个信任用户可以使用个人密钥解密文件，如果用户离开团队，将删除用户的公钥即可，他也就不能再解密文件了。

## **git-secret 使用**

假设我现在有一个仓库 git-secret-demo，仓库下有一个包含敏感信息的文件 secret.json：

![202305160835285](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305160835285.png)

我现在想做的是使用 git-secret 将 secret.json 文件加密。

* 首先得安装 gpg 工具

```bash
# Debian & Ubuntu
sudo apt install gnupg -y
​
# Macos
brew install gnupg
```

* 本地创建 gpg RSA 密钥对

```bash
gpg --gen-key
```

在创建时需要输入自己的用户名和邮箱，并且需要输入你的加密密码。

![202305160835334](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305160835334.png)

导出你的公钥文件，你可以拿到这个公钥文件交给 git 仓库管理员，让他把你加入到仓库的信任用户列表：

```bash
gpg --armor --export ding.peng@email.cn > dp-public-key.gpg
```

![202305160835376](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305160835376.png)

导入公钥文件，git 仓库管理员将公钥文件导入本地环境，之后可以将本地环境中的公钥加入到 git-secret 信任用户列表：

```bash
gpg --import other-pulic-key.gpg
```

查看本地密钥对列表

```bash
gpg --list-key
```

![202305160835439](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305160835439.png)

* 安装 git-secret

```bash
# Debian & Ubuntu
sudo apt install git-secret -y
​
# Macos
brew install git-secret
```

* 使用 `git secret init` 初始化，在仓库根目录下执行

```bash
git secret init
```

![202305160835464](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305160835464.png)

默认会在仓库下生成 .gitsecret 目录和 .gitignore 文件。

* 将用户加入到 git-secret 信任用户列表

```bash
git secret tell ding.peng@email.cn
```

![202305160835521](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305160835521.png)

* 添加加密文件到 git-secret

```bash
git secret add -i secret.json
```

![202305160835620](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305160835620.png)

这里 `-i` 自动将要加密的文件添加到 `.gitignore`

此时使用如下命令可以在目录下看到生成的 `secret.json.secret` 的加密后文件

```bash
git secret hide
```

![202305160835909](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305160835909.png)

到这时，你的加密文件不会提交到仓库中，从 git 仓库新克隆下来的时候是没有加密文件的，你需要解密文件才能得到文件，例如我现在删除加密文件，然后再通过解密加密过的文件重新得到敏感文件，使用命令:

```bash
git secret reveal # 第一次使用该命令需要输入信任用户的密码
```

![202305160835973](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305160835973.png)

从以上截图，你可以看到敏感文件 `secret.json` 失而复得的整个过程。

## **git-secret 常用命令**

除了上面使用过的命令，你可能还会用到以下命令：

![202305160835992](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202305160835992.png)

* **git secret usage：**列出 git secret 可用命令。
* **git secret whoknows：**查看当前 git 仓库允许访问私密文件的用户邮箱列表。
* **git secret add**：添加加密文件。
* **git secret remove：**移除加密文件。
* **git secret list：**列出加密文件。
* **git secret changes：**查看加密文件的更改记录。
* **git secret clean：**清除所有加密文件。
* **git secret removeperson：**移除信任用户。
