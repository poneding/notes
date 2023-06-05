# Docker可视化工具Kitematic

![](https://pding.oss-cn-hangzhou.aliyuncs.com/images/kitematic.png)

使用Kitematic，以可视化的方式管理docker镜像，容器等。

## 安装Kitematic

在ubuntu（desktop）中安装kitematic作为示例，其他平台安装下载地址：https://github.com/docker/kitematic/releases

```
# download
wget https://github.com/docker/kitematic/releases/download/v0.17.11/Kitematic-0.17.11-Ubuntu.zip
unzip Kitematic-0.17.11-Ubuntu.zip

# install
sudo dpkg -i Kitematic-0.17.11_amd64.deb
```

## 用户组管理

ubuntu已经安装了docker了，当我们安装完Kitematic之后，第一次打开会遇到

将当前用户加入到docker组：

```shell
sudo usermod -aG docker $USER
# 重启docker
sudo systemctl restart docker
sudo chmod a+rw /var/run/docker.sock
```

完成上面操作后，重启主机，应该就可以使用Kitamatic了。

## 使用Kitematic

第一次启动Kitematic，需要登录docker账号，登录完成后，界面如下。

![image-20200623174214567](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200623174214567.png)

主界面会列出一些热门的镜像，比如redis，jenkins。可以通过切换右上角菜单选项，查看我的Docker账号中的镜像列表，以及我当前主机中已经拉取的镜像列表。

点击镜像的Create按钮，可以直接以默认方式启动容器，比如我选择redis镜像，点击Create按钮，之后会在我的左侧Containers列表中出现一个redis容器，这个过程中包含拉取镜像，启动容器。

![image-20200623174723774](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200623174723774.png)

容器运行后，可以在容器界面对容器进行容器配置，例如环境变量配置、端口映射配置、卷映射配置等；

也可以在容器界面对容器进行容器管理，例如容器停止、重启、和删除。

![image-20200623175341385](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200623175341385.png)

这个工具功能还在不断完善，但是使用体验还算不错，推荐给大家，更多使用细节可以自己慢慢挖掘。