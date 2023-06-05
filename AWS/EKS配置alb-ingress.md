# EKS配置 ALB Ingress

官方文档：https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/controller/installation/

## 部署Alb Ingress Controller

IAM中创建Policy，给集群的Node节点的Role添加该Policy。

Policy的JSON配置如下：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cognito-idp:DescribeUserPoolClient"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "shield:DescribeProtection",
        "shield:GetSubscriptionState",
        "shield:DeleteProtection",
        "shield:CreateProtection",
        "shield:DescribeSubscription",
        "shield:ListProtections"
      ],
      "Resource": "*"
    }
  ]
}
```

下载alb-ingress-controller.yaml

```bash
wget https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.6/docs/examples/alb-ingress-controller.yaml
```

修改alb-ingress-controller.yaml，修改以下三个配置项

- `--cluster-name=dev-eks`
- `--aws-vpc-id=vpc-xxxxxx`

- `--aws-region=us-west-1`

部署：

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.6/docs/examples/rbac-role.yaml
kubectl apply -f alb-ingress-controller.yaml
```

验证部署情况：

```bash
kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o "alb-ingress[a-zA-Z0-9-]+")
```

## 配置Alb Ingress Controller

  ## 设置External DNS

本篇内容来源：https://kubernetes-sigs.github.io/aws-load-balancer-controller/v1.1/guide/external-dns/setup/

### 背景

在AWS中，如果我们希望以某个域名访问K8s集群的某个服务，我们可以通过维护Route 53中Record Set和LoadBalancer映射来实现，这无疑会增加一些手动操作的成本，本篇即介绍使用**external-dns**来自动维护它们之间的关系。

**external-dns**项目地址：https://github.com/kubernetes-incubator/external-dns

external-dns根据host的信息提供DNS记录，它将建立和管理Route 53中Record Set与LoadBalancer的映射关系。

### 前提条件

#### 角色权限

必须给K8s集群运行external-dns的Node配置角色和策略。

IAM中创建Policy，给集群的Node节点的Role添加该Policy。

Policy的JSON配置如下：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
```

### 安装

1. 下载external-dns.yaml示例文件

```shell
wget https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.6/docs/examples/external-dns.yaml
```

2. 修改external-dns.yaml文件，主要修改``--domain-filter`这个配置内容

- `--domain-filter=example.com`

3. 部署external-dns

```bash
kubectl apply -f external-dns.yaml
```

4. 验证部署是否成功和实时记录

```bash
kubectl logs -f $(kubectl get po | egrep -o 'external-dns[A-Za-z0-9-]+')
```

### 使用方式

1. 为了在子域名中建立Record Set，需要在`Ingress`或者`Service`资源中添加如下注释：

```yaml
annotations:
  # for creating record-set
  external-dns.alpha.kubernetes.io/hostname: nginx.example.com # give your domain name here
```

> 如果是`service`，需要将`type`设置成`LoadBalancer`

1. 查看实时日志，2分钟后在Route 53中查看记录是否生成或更新。

## 实践记录

- Pod内容器使用Secrets Manager，需要给Node的Role添加相应的权限；