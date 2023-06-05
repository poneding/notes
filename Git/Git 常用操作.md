# Git 常用操作

```sh
git status
git branch 查看分支
git log 查看提交记录
git remote -v 查看远程仓库
git diff <local——branch> <remote-branch> 查看本地分支的最近提交和远程的差异
git stash 将已经添加但是还未提交的代码放在暂存区
git stash list 查看暂存区
git stash pop 从暂存区取出(暂存区删除)
```

## 本地生成公私钥文件

```sh
ssh-keygen -t rsa -C "poneding@gmail.com"
# ssh-keygen -t rsa -C "poneding@gmail.com" -f ~/.ssh/id_rsa_github
vim ~/.ssh/config
Host github.com
  Identityfile ~/.ssh/id_rsa
```

## git更新git-url

```shell
git remote set-url origin xxx.git
```

## git初始化

```bash
git init
git remote add origin xxx.git
git remote rm origin
git push -u origin master
```

## 撤销git版本记录

对某个文件修改后，丢弃修改（还没执行 git add）：

> ⚠️ 注意：以下命令中的 `--` 很重要，没有 `--`，就变成了“切换到另一个分支”的命令

```bash
git checkout -- README.md
```

已经git add，撤销

```bash
git reset HEAD README.md
```

已经git add & git commit，撤销：

```bash
git log # 得到commit_id（6位即可）
git reset --hard commit_id
```

## 合并分支

例如：dev 分支合并代码到 master

```shell
git checkout dev
git merge master
git push
```

## 配置User

```bash
# 非全局
git config user.name {name}
git config user.email {email}

# 全局
git config --global user.name {name}
git config --global user.email {email}
```

## 创建 tag

```bash
git tag // 列出所有tag
git tag {tag-name} // 打tag
git tag -a {tag-name} -m {tag-message}

git push origin {tag-name}
```

## 删除 tag

远端删除

```bash
git push origin :refs/tags/{tag-name}
```

远端批量删除

```bash
git show-ref --tag | awk '/(.*)(\s+)(.*)$/ {print ":" $2}' | xargs git push origin
```

本地删除

```bash
git tag -d {tag-name}
```

本地批量删除

```bash
# 删除符合条件的
git tag | grep "v1.1.0.\d$" | xargs git tag -d
git tag | xargs git tag -d
```

## PR

获取其他仓库分支

```bash
git remote add {remote-name} {remote-url}
git fetch {remote-name}
git pull {remote-name} {branch-name}

# 新增远端分支
git checkout -b {new-branch} {remote-name}/{new-branch}
```

## 删除远程仓库历史提交

```bash
rm -rf .git
git init
git add .
git commit -m "init repo."
git remote add origin {remote-name}
git push -f --set-upstream origin master
```

## Troubleshooting

### Q1. 证书颁发者不识别

```tex
Peer’s Certificate issuer is not recognized.
```

解决方法：

```shell
# 仓库级别，在仓库目录下执行
git config http."sslVerify" false

# 全局级别
git config --global http."sslVerify" false
```
