# Kops

## Intro

`kops` 是一个用于管理 `kubernetes` 集群的工具，可以用来创建、删除、升级 `kubernetes` 集群。

## Install

```shell
# Linux
wget https://github.com/kubernetes/kops/releases/download/1.14.1/kops-linux-amd64
chmod +x kops-linux-amd64
mv kops-linux-amd64 /usr/local/bin/kops
```

## Usage

> - 主机需要拥有 aws 创建资源的权限
> - 主机需要安装 awscli： **`pip3 install --upgrade --user awscli`**

### Create Route53 with awscli

```shell
aws route53 create-hosted-zone --name dev.dp.example.com --caller-reference 1 --vpc VPCRegion="ap-southeast-1",VPCId="vpc-6c32be08" --hosted-zone-config Comment="Created by dp.",PrivateZone=true
```

> 注意：每次创建 `route53` 时，`--caller-reference` 的值都不能重复，否则会报错：`An error occurred (HostedZoneAlreadyExists) when calling the CreateHostedZone operation: A hosted zone has already been created with the specified caller reference.` 该值是一个唯一的字符串值。

### Create S3 Bucket

```shell
aws s3api create-bucket --bucket clusters.dev.dp.example.com-ap-southeast-1-314566904004 --region us-east-1
aws s3api put-bucket-versioning --bucket clusters.dev.dp.example.com-ap-southeast-1-314566904004 --versioning-configuration Status=Enabled

# delete route53
aws route53 delete-hosted-zone --id Z8UTMZEV00TZC
```

> 注意：
>
> - 如果 `--region` 值不是 `us-east-1` 时，需要添加配置 `--create-bucket-configuration LocationConstraint=ap-southeast-1`
>
> - bucket name全球唯一，当遇到 `when calling the CreateBucket operation: The requested bucket name is not available. The bucket namespace is shared by all users of the system. Please select a different name and try again.` 提示时，更换 bucket name 即可。

### Create Cluster

```shell
# create cluster
kops create cluster \
  --node-count 2 \
  --zones ap-southeast-1a,ap-southeast-1b,ap-southeast-1c \
  --master-zones ap-southeast-1a \
  --dns-zone Z07578152THWOGHAOC5N2 \
  --state s3://clusters.dev.dp.example.com-ap-southeast-1-314566904004 \
  --node-size t2.medium \
  --master-size t2.medium \
  --topology private \
  --networking kopeio-vxlan \
  hacluster.dev.dp.example.com --yes

# update cluster
kops update cluster --name hacluster.dev.dp.example.com  --yes
```

> --dns-zone 值为 **Hosted Zone ID**

```shell
kops validate cluster
kubectl config view 
kubectl get nodes
kubectl get services

# delete cluster
kops delete cluster \
--name hacluster.dev.dp.example.com \
--state s3://clusters.dev.dp.example.com-ap-southeast-1-314566904004 --yes
```

## Kops & Terraform Build Cluster

### Need

- terraform
- kops
- kubectl
- jq

### Files

```shell
.
├── kops
│   ├── template.yaml
└── terraform
    ├── kops_state.tf
    ├── locals.tf
    ├── output.tf
    ├── provider.tf
    ├── route53.tf
    └── vpc.tf
```

**kops/template.yaml**

```yaml
apiVersion: kops/v1alpha2
kind: Cluster
metadata:
  name: {{.cluster_name.value}}
spec:
  api:
    loadBalancer:
      type: Public
      additionalSecurityGroups: ["{{.k8s_api_http_security_group_id.value}}"]
  authorization:
    rbac: {}
  channel: stable
  cloudProvider: aws
  configBase: s3://{{.kops_s3_bucket_name.value}}/{{.cluster_name.value}}
  # Create one etcd member per AZ
  etcdClusters:
  - etcdMembers:
  {{range $i, $az := .availability_zones.value}}
    - instanceGroup: master-{{.}}
      name: {{. | replace $.region.value "" }}
  {{end}}
    name: main
  - etcdMembers:
  {{range $i, $az := .availability_zones.value}}
    - instanceGroup: master-{{.}}
      name: {{. | replace $.region.value "" }}
  {{end}}
    name: events
  iam:
    allowContainerRegistry: true
    legacy: false
  kubernetesVersion: 1.11.6
  masterPublicName: api.{{.cluster_name.value}}
  networkCIDR: {{.vpc_cidr_block.value}}
  kubeControllerManager:
    clusterCIDR: {{.vpc_cidr_block.value}}
  kubeProxy:
    clusterCIDR: {{.vpc_cidr_block.value}}
  networkID: {{.vpc_id.value}}
  kubelet:
    anonymousAuth: false
  networking:
    amazonvpc: {}
  nonMasqueradeCIDR: {{.vpc_cidr_block.value}}
  sshAccess:
  - 0.0.0.0/0
  subnets:
  # Public (utility) subnets, one per AZ
  {{range $i, $id := .public_subnet_ids.value}}
  - id: {{.}}
    name: utility-{{index $.availability_zones.value $i}}
    type: Utility
    zone: {{index $.availability_zones.value $i}}
  {{end}}
  # Private subnets, one per AZ
  {{range $i, $id := .private_subnet_ids.value}}
  - id: {{.}}
    name: {{index $.availability_zones.value $i}}
    type: Private
    zone: {{index $.availability_zones.value $i}}
    egress: {{index $.nat_gateway_ids.value 0}}
  {{end}}
  topology:
    bastion:
      bastionPublicName: bastion.{{.cluster_name.value}}
    dns:
      type: Public
    masters: private
    nodes: private
---

# Create one master per AZ
{{range .availability_zones.value}}
apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{$.cluster_name.value}}
  name: master-{{.}}
spec:
  image: kope.io/k8s-1.11-debian-stretch-amd64-hvm-ebs-2018-08-17
  machineType: t2.medium
  maxSize: 1
  minSize: 1
  role: Master
  nodeLabels:
    kops.k8s.io/instancegroup: master-{{.}}
  subnets:
  - {{.}}
---
{{end}}

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{.cluster_name.value}}
  name: nodes
spec:
  image: kope.io/k8s-1.11-debian-stretch-amd64-hvm-ebs-2018-08-17
  machineType: t2.small
  maxSize: 2
  minSize: 2
  role: Node
  nodeLabels:
    kops.k8s.io/instancegroup: nodes
  subnets:
  {{range .availability_zones.value}}
  - {{.}}
  {{end}}
---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{.cluster_name.value}}
  name: bastions
spec:
  image: kope.io/k8s-1.11-debian-stretch-amd64-hvm-ebs-2018-08-17
  machineType: t2.micro
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: bastions
  role: Bastion
  subnets:
  {{range .availability_zones.value}}
  - utility-{{.}}
  {{end}}
```

**terraform/kops_state.tf**

```tex
resource "aws_s3_bucket" "dp-k8s-kops" {
  bucket = "${local.kops_state_bucket_name}"
  acl    = "private"

  versioning {
    enabled = true	# 请注意：如果为 true，terraform destroy 时无法销毁 bucket
  }

  tags = {
    Environment = "dev"
    Application = "kops"
  }
}

resource "aws_security_group" "k8s_api_http" {
  name   = "${local.environment}_k8s_api_http"
  vpc_id = "${module.vpc.vpc_id}"
  tags   = "${local.tags}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = "${local.ingress_ips}"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = "${local.ingress_ips}"
  }
}
```

**terraform/locals.tf**

```tex
locals {
  cluster_name           = "k8s.dp.io"
  cidr                   = "10.0.0.0/16"
  azs                    = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets         = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  environment            = "dev"
  kops_state_bucket_name = "dp-k8s-kops"
  ingress_ips            = ["10.0.0.100/32", "10.0.0.101/32"]

  tags = {
    environment = "${local.environment}"
    terraform   = true
  }
}
```

**terraform/output.tf**

```tex
output "region" {
  value = "ap-southeast-1"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_cidr_block" {
  value = "${module.vpc.vpc_cidr_block}"
}

output "public_subnet_ids" {
  value = "${module.vpc.public_subnets}"
}

output "public_route_table_ids" {
  value = "${module.vpc.public_route_table_ids}"
}

output "private_subnet_ids" {
  value = "${module.vpc.private_subnets}"
}

output "private_route_table_ids" {
  value = "${module.vpc.private_route_table_ids}"
}

output "default_security_group_id" {
  value = "${module.vpc.default_security_group_id}"
}

output "nat_gateway_ids" {
  value = "${module.vpc.natgw_ids}"
}

output "availability_zones" {
  value = "${local.azs}"
}

output "kops_s3_bucket_name" {
  value = "${aws_s3_bucket.dp-k8s-kops.bucket}"
}

output "cluster_name" {
  value = "${local.cluster_name}"
}

output "k8s_api_http_security_group_id" {
  value = "${aws_security_group.k8s_api_http.id}"
}
```

**terraform/provider.tf**

```tex
provider "aws" {
  region = "ap-southeast-1"
}
```

**terraform/route53.tf**

```tex
resource "aws_route53_zone" "cluster" {
  name = "${local.cluster_name}"
}
```

**terraform/vpc.tf**

```tex
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "kops-vpc"
  cidr = "${local.cidr}"

  azs             = "${local.azs}"
  private_subnets = "${local.private_subnets}"
  public_subnets  = "${local.public_subnets}"

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  tags = {
    Environment = "${local.environment}"
    Application = "network"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}
```

### Command

**terraform dir**

```bash
terraform init
terraform apply --auto-approve
```

**kops dir**

```bash
TF_OUTPUT=$(cd ../terraform && terraform output -json)
CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .cluster_name.value)"
kops toolbox template --name ${CLUSTER_NAME} --values <( echo ${TF_OUTPUT}) --template template.yaml --format-yaml > cluster.yaml
```

> 生成 cluster.yaml

```bash
STATE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_s3_bucket_name.value)"
kops replace -f cluster.yaml --state ${STATE} --name ${CLUSTER_NAME} --force
kops create secret --name ${CLUSTER_NAME} --state ${STATE} sshpublickey admin -i ~/dp/k8s.dp.io/.ssh/id_rsa.pub
```

```bash
kops update cluster \
  --out=. \
  --target=terraform \
  --state ${STATE} \
  --name ${CLUSTER_NAME}
```

```bash
terraform 0.12upgrade
terraform init
terraform apply --auto-approve
```

elb dnsname 远程跳板机。

## SIMPLE

```shell
# 创建 host-zone
aws route53 create-hosted-zone --name k8s.local --caller-reference "$(date)" --vpc VPCRegion="ap-southeast-1",VPCId="vpc-6c32be08" --hosted-zone-config Comment="Created by dp.",PrivateZone=true

# 创建 s3， 除了 us-east-1 都需要指定 LocationConstraint
aws s3api create-bucket --bucket cluster.k8s.local.state-ap-southeast-1-314566904004 --region ap-southeast-1 --create-bucket-configuration LocationConstraint=ap-southeast-1

# 定义 cluster 变量
export NAME=clusters.dp.k8s.local
export KOPS_STATE_STORE=s3://cluster.k8s.local.state-ap-southeast-1-314566904004

# 创建集群
kops create cluster \
--cloud=aws \
--master-zones=ap-southeast-1a \
--zones=ap-southeast-1a,ap-southeast-1b \
--node-count=2 \
--topology private \
--networking kopeio-vxlan \
--node-size=t2.micro \
--master-size=t2.micro \
${NAME}

kops update cluster ${NAME} --yes

kops create instancegroup bastions --role Bastion --subnet utility-ap-southeast-1a --name ${NAME}
kops update cluster ${NAME} --yes

kops validate cluster

aws elb --region=ap-southeast-1  --output=table describe-load-balancers|grep DNSName.\*bastion|awk '{print $4}'

kops delete cluster ${NAME} --yes

export BASTION_HOST=$(aws elb --region=ap-southeast-1  --output=table describe-load-balancers|grep DNSName.\*bastion|awk '{print $4}')

sudo scp -i ~/.ssh/id_rsa /home/ubuntu/.ssh/id_rsa admin@$BASTION_HOST:~/sshkey
sudo ssh -i ~/.ssh/id_rsa admin@$BASTION_HOST

# 如果本机创建了多个集群，则可以通过以下方式切换集群上下文
# 1. 获取本机所有集群上下文
kubectl config get-contexts

# 2. 切换集群上下文
kubectl config use-context clusters.dp.k8s.local
```

From aziz share:

![kops](https://pding.oss-cn-hangzhou.aliyuncs.com/images/kops.png)
