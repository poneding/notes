# 使用 SSH Tunnel 连接中间件

## 背景

一般线上的数据库是不允许本机直接访问的，只能通过跳板机访问。但是这么多的开发人员都要访问数据库的话，跳板机的数量就有压力了。

本篇介绍如何使用 SSH Tunnel 的方式访问数据库，数据库不限于 Sql Server、MySql、Mongodb、Redis 等。

## 前提条件

- 已经拥有数据库的登录信息，如数据库访问的 host、port、user、password；
- 拥有一台可以访问数据库的跳板机登录权限，如跳板机的 IP、user、password（或密钥文件）；
- 本机安装了有 SSH Tunnel 功能的数据库的可视化工具，如 **DBeaver，Navicate，Robo 3T** 等。

## RDB

使用 `DBeaver` 或 `Navicate` 等工具通过 SSH Tunnel 方式访问关系型数据库，以 Sql Server 为例。

打开DBeaver，选择 Sql Server 连接。

![image-20200417141130980](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417141130980.png)

在连接配置页面 Main，输入 Sql Server 连接的基本信息，这里 host 直接使用原本的数据库 host 即可。

![image-20200417105404157](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417105404157.png)

切至 SSH，勾选 Use SSH Tunnel，输入跳板机的连接配置即可。

![image-20200417105649823](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417105649823.png)

配置完成，Ok连接即可。

### 使用 SSMS + SSH Tunnel 连接 Sql Server

> 本机需要安装 SSMS 和 Putty 工具。
>
> 这篇文档对我帮助很大：https://courses.cs.washington.edu/courses/cse444/11wi/resources/tunneling-instructions.html

打开 Putty 工具，在 Session 创建跳板机的连接。

![image-20200417095445082](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417095445082.png)

并且在 Connection 中配置登录账号和密码（或密钥文件）。

![image-20200417095628340](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417095628340.png)

然后在 Connection=>SSH=>Tunnels 中添加 Sql Server 的 server 信息

> 在 Source Port 中输入 `<port>`（Sql Server的默认端口是1433）；
>
> 在 Destination 中输入 `<host>:<port>`（例如：db.example.com:1433）；
>
> 输入完之后点击Add按钮。

完成操作之后你的页面也应是下面这个样子。

![image-20200417100423372](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417100423372.png)

回到 Connection=>SSH，勾选 Don’t start as shell or command at all.

![image-20200417100552751](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417100552751.png)

上面的配置完成后，点击 Open，应该会跳入如下的远程界面。

![image-20200417101930819](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417101930819.png)

> **注意：**如果本机已经安装了 Sql Server 数据库，需要现在 Service 中停掉本机的 SqlServer 服务，否则可能会造成端口冲突。

这时，你可以使用 SSMS 连接数据库服务了。

![image-20200417103957417](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417103957417.png)

> **注意：**SSMS 连接配置页面，Server name 必须是 127.0.0.1 而不是原本的数据库 host。

## NoSql

打开 Robo 3T，新建连接，并在 Connection 页面配置 mongo 的连接信息。

![image-20200417140845010](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417140845010.png)

切至 SSH 页面，勾选 Use SSH Tunnel，输入跳板机的连接配置即可。

![image-20200417140748111](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417140748111.png)

配置完成，Save 后连接即可。

其他例如Redis数据库，可以使用 Redis Desktop Manager SSH Tunnel 连接。

![image-20200417140544099](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200417140544099.png)
