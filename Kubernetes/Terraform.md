# Terraform

## 创建ec2同时安装应用的三种方式

### Mode 1: userdata

> - 需要shell脚本文件install_nginx.sh

```shell
resource "aws_instance" "demo" {
  # ...
  
  # Mode 1: userdata
  user_data = "${file("../templates/install_nginx.sh")}"
  
  # ...
}
```

### Mode 2: remote-exec

> - 需要连接主机，connection;
> - 密钥文件xxx.pem

```shell
resource "aws_instance" "demo" {
  # ...
  
  # Mode 2: remote-exec
  connection {
    host = "${self.private_ip}"
    private_key = "${file("xxx.pem")}"
    user        = "${var.ansible_user}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo service nginx start"
    ]
  }
   
  # ...
}
```

### Mode 3: local-exec with Ansible

> - 需要执行Terraform命令的主机安装Ansible
> - 密钥文件xxx.pem
> - 额外的ansible-playbook文件，目录../playbooks/install_nginx.yaml
> - **实战过程中发现，使用Ansible在主机远程为ec2安装nginx时，需要等待一定时间(sleep 30)才会成功，猜测可能是等待ec2完全创建成功并运行(安装python，毕竟Ansible对host的唯一要求就是python)之后才可以使用Ansible，这可能会成为一个坑。**

```shell
resource "aws_instance" "demo" {
  # ...
  
  # Mode 3: local-exec with ansible-playbook
  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
	  >nginx.ini;
	  echo "[nginx]" | tee -a nginx.ini;
      chmod 600 xxx.pem;
	  echo "${self.private_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=xxx.pem" | tee -a nginx.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	  ansible-playbook -u ${var.ansible_user} --private-key xxx.pem -i nginx.ini ../playbooks/install_nginx.yaml
    EOT
  }
   
   # ...
}
```

