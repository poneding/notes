# ohmyzsh

## macos

```bash
echo $SHELL
/bin/zsh
```

- 安装 ohmyzsh

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

- 安装 zsh-autosuggestions

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

- 配置 `.zshrc` 文件添加 ohmyzsh 插件：

```bash
plugins=(git docker docker-compose kubectl autojump zsh-autosuggestions)
```

## linux

- **安装 zsh**

```bash
sudo apt update
sudo apt install zsh -y
```

- **修改 shell**

```bash
chsh -s /usr/bin/zsh
```

打开新的终端，将使用 zsh

```bash
echo $SHELL
/usr/bin/zsh
```

- **安装 ohmyzsh**

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

- **安装 zsh-autosuggestions**

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

- **配置 `.zshrc` 文件添加 ohmyzsh 插件：**

```bash
plugins=(git docker docker-compose kubectl autojump zsh-autosuggestions)
```
