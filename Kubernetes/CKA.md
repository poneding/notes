# CKA

## 搭建CKA考试环境

```bash
git clone https://github.com/arush-sal/cka-practice-environment.git
cd cka-practice-environment
docker-compose up -d
```

访问`http://localhost`即可。

### 题目汇总

**1. Q. Bootstrap a Kubernetes v1.10 cluster using kubeadm**

You need to bootstrap a Kubernetes v1.10 cluster with one master and one worker node using kubeadm.

**2. Q. Enable cluster auditing**

Enable cluster wide auditing. You can use the audit policy provided [here](https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/audit/audit-policy.yaml).

Make sure the audit logs are properly generated and saved to a log file.

**3. Q. Create a deployment running nginx version 1.12.2 that will run in 2 pods**

Scale this to 4 pods.
Scale it back to 2 pods.
Upgrade nginx version to 1.13.8
Check the status of the upgrade
How do you do this in a way that you can see history of what happened?
Undo the upgrade.

**4. Q. Create a service that uses a scratch disk**

Change the service to mount a disk from the host.
Change the service to mount a persistent volume.

**5. Q. Create a pod with a Liveness and Readiness probes**

You need to create a pod called <i>upNready</i> that has liveness and readiness probes configured for it.

Feel free to choose any application of your choice for the pod.

**6. Q. Create a daemon set**

Create a daemon set and change the update strategy to do a rolling update with a delay of 30 seconds between each update.

**7. Q. Create a busybox pod**

Create a busybox pod without using a manifest and then edit the manifest as per your liking.

**8. Q. Create a pod that uses secrets**

Pull secrets from environment variables.
Pull secrets from a volume.
Dump the secrets out via kubectl to show it worked.

**9. Q. Create a scheduled Job**

Create a job that runs every 3 minutes and prints out the current time.

**10. Q. Create a parallel Job**

Create a job that runs 80 times, with 5 containers at a time, and prints "Hello parallel world".

**11. xxx**

xxx

**12. xxx**

xxx

**13. xxx**

xxx

**14. xxx**

xxx

**15. xxx**

xxx

**16. xxx**

xxx

**17. xxx**

xxx

**18. xxx**

xxx

**19. xxx**

xxx

**20. xxx**

xxx

**21. xxx**

xxx

**22. xxx**

xxx

**23. xxx**

xxx

**24. xxx**

xxx

## 注意事项

## 聪明贴士

**1.使用kubectl bash自动补全命令**

```bash
source <(kubectl completion bash) # 可以将改行命令添加到~/.bashrc文件中
```

**2.切换context**

```bash
kubectl config use-context <context-name>
```

**3.尽量使用命令创建Pod，Deployment，Service**

```bash
kubectl run nginx --image=nginx --restart=Never -n <ns-name>
kubectl create deployment nginx-app --image=nginx --replicas=3 -n <ns-name>
kubectl expose pod nginx --port=80 --name=nginx -n <ns-name>
kubectl expose deployment nginx-app --port=80 --name=nginx-app -n <ns-name>
```

**4.使用-o yaml --dry-run > xx.yaml的习惯**

```bash
kubectl run nginx --image=nginx --restart=Never -o yaml --dry-run > nginx.yaml
kubectl apply -f nginx.yaml
```

> 较新kubectl版本--dry-run后面需要跟命令行参数的值，--dry-client=client。

**5.使用kubectl -h、etcdctl -h查看命令使用**

```bash
kubectl -h
etcdctl -h
```

**6.如果已经名为test-cronjob存在一个cronjob，怎么手动触发一次**

```bash
kubectl create job test-job-001 --from=cronjob/test-cronjob
```

> 注意：job名不能是已经存在的job。

## 考题示例

**1.列出所有pv并以name字段排序**

```bash
kubectl get pv --sort-by=.metadata.name > sorted_pv
```

**2.设置node2不可用，并将除了deamonset的pod调度出去**

```bash
kubectl cordon node2
kubectl drain --ignore-daemonsets --delete-emptydir-data node2
```

**创建pod**

方法一：

```bash
kubectl run pod1 --image=nginx --generator=run-pod/v1
# 带label
kubectl run pod2 --image=nginx --generator=run-pod/v1 --labels app=nginx,env=prod
# 多容器pod
kubectl run pod3 --image=nginx --image=redis --image=consul
```

方法二

pod1.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod1
  labels:
    app: nginx
spec:
  containers:
  - name: ngxin
    image: nginx
  - name: redis
    image: redis
  - name: consul
    image: consul
  - name: memcached
    image: memcached
```

```bash
kubectl apply -f pod1.yaml
```

**创建deployment**

```bash
kubectl run deployment nginx-app --replicas=3 --image=nginx:1.11.9 

kubectl set image deployment nginx-app nginx-app=nginx.1.12.0 --record
kubectl rollout history deployment nginx-app
kubectl rollout undo deployment nginx-app
kubectl rollout status deployment nginx-app
kubectl rollout history deployment nginx-app
```

**创建service**

```yaml
kubectl expose pod nginx --name=nginx-app --port=80 --type=NodePort
```

**创建namespace**

```bash
kubectl create ns website --dry-run -o yaml > /opt/traning/8/website-ns.yaml
```

