# HPA-DEVOPS-K8s

## Server Info

- **服务器信息**

  bastion： 13.250.172.80

## Terraform

- **ubuntu安装Terraform**

  Terraform 下载地址：https://www.terraform.io/downloads.html 

  ```shell
  # step 1
  wget https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip
  
  # step 2
  unzip terraform***.zip
   
  # step 3 
  mkdir downloads
  mv terraform downloads/
  
  # step 4
  vim ~/.profile
  # append text
  export PATH="$PATH:~/downloads"
   
  # step 5
  source ~/.profile
  terraform --version
  ```

- **使用Terraform创建资源**

  *Step 1*: 创建tf文件，如example.tf
  
  *Setp 2*: 编辑tf文件，写入创建ec2实例的文本内容如下：
  
  ```
  provider "aws" {
    profile    = "default"
    region     = "us-east-1"
  }
  
  resource "aws_instance" "example" {
    ami           = "ami-2757f631"
    instance_type = "t2.micro"
  }
  ```
  
  *Step 3*: 使用Terraform命令
  
  ```shell
  terraform init
  
  terraform plan
  
  # format *.tf file
  terraform fmt
  
  # validate *.tf file
  terraform validate
  
  terraform apply
  ```
  
- **使用Terraform销毁资源**

  ```
  terraform destroy
  ```
## Ansible

-   **ubuntu安装Ansible**

  ```shell
  sudo apt update
  sudo apt install software-properties-common
  sudo apt-add-repository --yes --update ppa:ansible/ansible
  sudo apt install ansible
  
  ansible --version
  ```

- **维护主机清单**

  Ansible可访问对象必须存在于主机清单，否则不认识。

  在文件/etc/ansible/hosts中维护，添加ip或主机名，主机之间可以维护成主机组

  ```shell
  # ip or hostname
  [aws:vars]
  ansible_ssh_private_key_file=/home/ubuntu/**.pem
  
  [aws]
  192.168.0.1 ansible_ssh_user=ec2-user
  192.168.0.1 ansible_ssh_user=ubuntu
  ```

- **操作主机**

  ```
  # ping
  ansible [ip/hostgroup] -m ping
  
  # common
  ansible [ip/hostgroup] -a 'cat /home/ec2-user/hello.txt'
  
  # copy local file to host
  ansible [ip/hostgroup] -m copy -a "src=/home/ubuntu/hello1.txt dest=/home/ec2-user/"
  
  # install app
  ansible [ip/hostgroup] -m command -a "sudo apt install python3"
  ```

  > **-m:** 模块，如copy, command, ping
  >
  > **-a:** 参数

  > 在host group中的主机都会执行ansible指定的操作。

- **Ansible Playbook**

  - 创建yml文件，如test.yml，写入内容。

    ```
    ---
    - hosts: aws
      gather_facts: False
      remote_user: ec2-user
  
      tasks:
      - name: ping
        ping:
      - name: rmfile
        command: rm /home/ec2-user/hello.txt
    ```
    
    > 预先在aws机器上创建hello.txt文件，执行playbook yml文件后就删除掉了
    
  - 测试
  
    ```shell
    ansible-playbook -i /etc/ansible/hosts /etc/ansible/test.yml
    ```
  
    > playbook：就是将你需要对主机的操作都写到一个yml文件中，ansibe帮你完成操作。就如同演员对着剧本表演一样。你只需要写好剧本，然后喊action。
  
- **遇到的问题记录**

  - 问题1

    连接aws的linux实例时，需要在/etc/ansible/hosts定义的参数

    ```
    [ubuntu:vars]
    ansible_private_key_file=/home/ubuntu/singapore.pem
    
    [ubuntu]
    192.168.0.1 ansible_ssh_user=ubuntu
    ```

  - 问题2

    使用docker创建可以ssh连接的ubuntu容器，无法使用root连接，但是使用其他user时，在`ansible local -m ping`时也会出现以下问题。

    ```
    Authentication or permission failure.  In some cases, you may have been able to authenticate and did not have permissions on the remote directory. Consider changing the remote temp path in ansible.cfg to a path rooted in "/tmp"....
    ```

    其实上面的信息已经有了一些提示，修改/etc/ansible/ansible.cfg的remote_tmp配置
    
    ```
    remote_tmp     = /tmp/.ansible-${USER}/tmp
    ```
  
- 问题3
  
  如果在使用pem文件连接服务器时遇到`Permissions 0664 for '/home/ubuntu/dev-mysql.pem' are too open.\r\nIt is required that your private key files are NOT accessible by others.`问题。
  
  修改文件权限即可
  
  ```shell
  sudo chmod 400 /path/to/file.pem
  ```
  
  
  
- 问题4

   Failed to lock apt for exclusive operation

  添加
  
  ```
become: yes
  ```

  

- ~~**访问主机**~~

  1. ~~生成访问密钥~~

     ```shell
     sudo ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
     ```

     ~~会在/root/.ssh目录下生成密钥对文件。~~

  2. ~~将密钥同步到主机清单中的主机~~

     ```shell
     sudo ssh-copy-id 192.168.0.1
     ```

     ~~同样会在要访问的主机/root下生成/.ssh目录以及/.ssh目录下的密钥文件~~

  3. ~~以上两个步骤可以实现Ansible对主机清单中的主机**免密登录**~~

  4. ~~登录~~

     ```shell
     ssh 192.168.0.1
     ```

  5. 

     

## Prometheus

> 1. 监控框架，可以监控CPU，Memory，Disk Usage，I/O，Network Statistics，MySql Server和Nginx
> 2. Go语言编写

- **[安装Prometheus on Ubuntu]( https://www.howtoforge.com/tutorial/monitor-ubuntu-server-with-prometheus/ )**

  ```
  wget https://github.com/prometheus/prometheus/releases/download/v2.13.1/prometheus-2.13.1.linux-amd64.tar.gz
  tar xvfz prometheus-2.13.1.linux-amd64.tar.gz
  cd prometheus-2.13.1.linux-amd64
  ./prometheus

  # 此时已经启动了prometheus的服务了
  ```
  
  

## Minikube

Ubuntu

在安装Minikube之前，先安装kubectl

```shell
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version
```

安装virtualbox

```shell
sudo add-apt-repository multiverse && sudo apt-get update

# 如果出现 command add-apt-repository not found，则执行一下命令
apt-get install software-properties-common
# 如果还不行，则执行以下命令
ls -al /usr/bin/apt-add-repository 
sudo apt install --reinstall software-properties-common

sudo apt install virtualbox -y
virtualbox
sudo apt install virtualbox-ext-pack
# Enter
# yes
```

安装Minikube

```shell
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/
minikube start

# 如果以上命令报错machine does not exist，执行以下
minikube delete
```

