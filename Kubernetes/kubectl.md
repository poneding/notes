# kubectl

## 安装

linux

```bash
# amd64
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# arm64
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"

mv ./kubectl /usr/local/bin/kubectl
```

macos

```bash
brew install kubectl
```

参考文档：https://kubernetes.io/docs/tasks/tools/#kubectl

## 常用命令

### 自动补全

```bash
source <(kubectl completion bash)
```

可以将上面的命令写入 `~/.bashrc` 或 `/etc/bash.bashrc` 中，这样每次登录都会自动补全。

```bash
$ vim ~/.bashrc
...
source <(kubectl completion bash)
```

### 命令别名

```bash
alias k=kubectl
complete -F __start_kubectl k
```

## Troubleshooting

### Q1. _get_comp_words_by_ref: command not found

解决方法：

```bash
apt install bash-completion -y
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
```
