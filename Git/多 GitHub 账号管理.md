# 多 GitHub 账号管理

实际开发工作中，你有可能多个 GitHub 账号：个人开发账号，工作开发账号。

在仓库代码管理的过程中你需要重复的使用 `git config user.*` 来切换代码提交账号，很是麻烦。以下方案可以帮你解决你的烦恼。

请确保你的 git 版本最低为 `2.13`

`~/.gitconfig`

```ini
[user]
        name = poneding
        email = poneding@gmail.com
[includeIf "gitdir:~/src/workspace/"]
        path = ~/src/workspace/.gitconfig
[url "git@github-workspace"]
        insteadOf = git@github.com
[pull]
        rebase = false
[init]
        defaultBranch = master
[core]
        excludesfile = ~/.gitignore_global
```

`~/src/workspace/.gitconfig`

```ini
[user]
        name = dingpeng24001
        email = dingpeng24001@talkweb.com.cn
[url "git@github-workspace"]
        insteadOf = git@github.com
[pull]
        rebase = false
[init]
        defaultBranch = master
[core]
        excludesfile = ~/.gitignore_global
```

`~/.ssh/config`

```ini
Host github.com
  HostName github.com
  IdentityFile ~/.ssh/id_rsa
​
Host github-workspace
  HostName github.com
  IdentityFile ~/.ssh/id_rsa_dingpeng24001
```

> `~/.ssh/id_rsa` 是个人账号 github ssh key
>
> `~/.ssh/id_rsa_dingpeng24001` 是工作账号 github ssh key
