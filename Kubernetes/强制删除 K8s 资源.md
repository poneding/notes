# 强制删除 K8s 资源

## 强制删除 Pod

```bash
kubectl delete po <pod> -n <namespace> --force --grace-period=0
```

## 强制删除 PVC

```bash
kubectl patch pv <pv> -n <namespace> -p '{"metadata":{"finalizers":null}}'
```

## 强制删除 PV

```bash
kubectl patch pvc <pvc> -n <namespace> -p '{"metadata":{"finalizers":null}}'
```

## 强制删除命名空间

在删除 kubesphere 的命名空间时遇到无法删除成功的现象，命名空间一直处于 Terminating 状态。

```bash
$ kubectl get ns |grep kubesphere
NAME                           STATUS        AGE
kubesphere-controls-system     Terminating   22d
kubesphere-monitoring-system   Terminating   21d
```

在网上找到了一种解决方案。

首先获取命名空间的 json 文件，

```bash
kubectl get ns kubesphere-controls-system -o json > temp.json
```

修改 temp.json 如下：

```json
{
    "apiVersion": "v1",
    "kind": "Namespace",
    "metadata": {
        ...
        "finalizers": [
            "finalizers.kubesphere.io/namespaces"	//删除此行
        ],
...
}
```

还有一种情况不同，可能需要删除的地方如下：

```json
{
    "apiVersion": "v1",
    "kind": "Namespace",
	...
    "spec": {
        "finalizers": [			// 删除
            "kubernetes"		// 删除
        ]					   // 删除
    },
...
}
```

完成文件修改后，本地代理 kubernetes service：

```bash
kubectl proxy --port 8081
```

以上操作会占用当前终端窗口，另外开启终端，执行命令：

```bash
curl -k -H "Content-Type:application/json" -X PUT --data-binary @temp.json http://127.0.0.1:8081/api/v1/namespaces/kubesphere-controls-system/finalize
```

执行以上命令大致输出如下：

```bash
$ curl -k -H "Content-Type:application/json" -X PUT --data-binary @kcs.json http://127.0.0.1:8081/api/v1/namespaces/kubesphere-controls-system/finalize
{
  "kind": "Namespace",
  "apiVersion": "v1",
  "metadata": {
	...
    "deletionGracePeriodSeconds": 0,
    "labels": {
      "kubesphere.io/namespace": "kubesphere-controls-system",
      "kubesphere.io/workspace": "system-workspace"
    },
	...
    "finalizers": [
      "finalizers.kubesphere.io/namespaces"
    ]
  },
  "spec": {
    
  },
  "status": {
    "phase": "Terminating",
    "conditions": [
      {
        "type": "NamespaceDeletionDiscoveryFailure",
        "status": "False",
        "lastTransitionTime": "2021-01-26T07:22:06Z",
        "reason": "ResourcesDiscovered",
        "message": "All resources successfully discovered"
      },
      {
        "type": "NamespaceDeletionGroupVersionParsingFailure",
        "status": "False",
        "lastTransitionTime": "2021-01-26T07:22:06Z",
        "reason": "ParsedGroupVersions",
        "message": "All legacy kube types successfully parsed"
      },
      {
        "type": "NamespaceDeletionContentFailure",
        "status": "False",
        "lastTransitionTime": "2021-01-26T07:23:13Z",
        "reason": "ContentDeleted",
        "message": "All content successfully deleted"
      }
    ]
  }
}
```

这时候顽固的的命名空间已经清除掉了。
