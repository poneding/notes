# 搭建EKS集群

## 安装aws，kubectl和eksctl命令行工具

### 引言

- 安装aws cli
- 安装kubectl cli
- 安装eksctl cli

### 安装aws cli

#### 参考

https://docs.aws.amazon.com/zh_cn/cli/latest/userguide/cli-chap-install.html

#### 安装示例（windows）

- 下载安装包：https://awscli.amazonaws.com/AWSCLIV2.msi
- 运行下载的安装包
- 确实安装是否成功

```bash
$ aws --version
```

#### 使用Security Credentials配置aws cli

- 访问aws控制台：Service => IAM
- 选择IAM User，使用子用户，强烈不建议使用root用户
- 进入用户详情页面，Security Credentials页
- 创建Access Key
- 拷贝Access Key ID和Secret Access Key
- 使用aws命令配置

```bash
$ aws configure
AWS Access Key ID [None]: ABCDEFGHIAZBERTUCNGG  (替换Access Key ID)
AWS Secret Access Key [None]: uMe7fumK1IdDB094q2sGFhM5Bqt3HQRw3IHZzBDTm  (替换Secret Access Key)
Default region name [None]: us-east-1
Default output format [None]: json
```

- 测试配置是否生效

```bash
$ aws ec2 describe-vpcs
```

#### 卸载（windows）

- 控制面板 => 程序和功能，找到aws cli，卸载即可。

### 安装kubectl cli

如果你确实是使用EKS的Kubernetes，建议使用aws提供的kubectl命令工具。

#### 参考

AWS

https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/install-kubectl.html

官方

https://kubernetes.io/docs/tasks/tools/

#### 安装示例（windows）

- 下载安装包，示例中下载路径：C:\apps\kubectl

```bash
curl -o kubectl.exe https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/windows/amd64/kubectl.exe
```

- 更新系统PATH环境变量，添加C:\apps\kubectl

- 验证kubectl版本

```bash
kubectl version --client
```

#### 卸载（windows）

直接删除程序文件以及PATH环境变量即可。

### 安装eksctl cli

#### 参考

https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/eksctl.html

#### 安装示例（windows）

#### 卸载（windows）

EKS最佳实践：

https://aws.github.io/aws-eks-best-practices/security/docs/iam/