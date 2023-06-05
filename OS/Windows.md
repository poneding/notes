# Windows使用姿势

## 1. Windows Terminal SSH 连接超时自动断开

使用 Windows Terminal SSH 连接 linux 服务器，每过一段时间后，就会自动断开。

**解决方案**

打开配置文件 `%USERPROFILE%/.ssh/config`，在该配置文件中添加配置行：

```ini
ServerAliveInterval 60
```

## 2. VSCode 搭配 Remote-SSH

配置远程访问文件 `%USERPROFILE%/.ssh/config`：

### 密钥文件进行SSH连接

 ```ini
 Host aliyun
   HostName 11.11.11.11
   User root
   IdentityFile ~/.ssh/aliyun_key
 ```

### 用户密码进行SSH连接

```ini
Host ubuntu
  HostName 192.168.11.11
  User dp
```

但是如果你不是使用密钥形式配置的话，每次连接时都需要输入密码。

**解决方案**

```bash
cd ~/.ssh
ssh-keygen -t rsa -C "remote" -f ubuntu
```

将生成 `ubuntu` 和 `ubuntu.pub` 文件，将 `ubuntu.pub` 文件内容**追加**拷贝至远程服务器 `~/.ssh/authorized_keys` 文件即可，如果文件不存在，则创建。

## 3. Powershell 命令

清除历史命令

```powershell
Remove-Item (Get-PSReadlineOption).HistorySavePath
```

