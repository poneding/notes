# Kubernetes 0-1 PVC扩容

K8s部署的kafka程序突然挂了，查看相关日志发现原来是挂日志的磁盘空间不足，那么现在需要对磁盘进行扩容。

使用以下命令执行PVC扩容的操作：

```bash
kubectl edit pvc <pvc-name> -n <namespace>
```

执行过程中发现，无法对该PVC进行动态扩容，需要分配pvc存储的storageclass支持动态扩容。

![image-20200905152418894](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200905152418894.png)

那么怎么是的storageclass支持动态扩容呢，很简单，更新storageclass即可。

```bash
kubectl edit storageclass <storageclass-name>
```

添加属性：

```tex
allowVolumeExpansion: true # 允许卷扩充
```

之后再次执行PVC扩容的操作即可。

