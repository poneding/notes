# Kubernetes 0-1 设置kubectl命令自动提示

安装bash-completion

```bash
yum install bash-completion -y
# 如果是ubuntu，则使用以下命令 
# apt install bash-completion -y
source /usr/share/bash-completion/bash_completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
# 可以使用kubectl命令提示了
```

