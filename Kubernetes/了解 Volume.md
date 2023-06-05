# 了解 Volume

我们知道容器与容器之间是隔离的，有独立的文件系统。并且存储的文件性质时临时的，当容器被销毁时，容器内的文件一并被清除。

在 Pod 内可能运行着多个容器，这可能需要容器共享文件。在 K8s 中，抽象除了 `Volume` 的概念来满足这种需求。

## Volume 介绍

在 Docker 中，也有 Volume 的概念，它是将容器内某文件目录挂载到宿主机的目录。

在 K8s 中，Volume 供 Pod 内的容器使用，一个容器可以使用多个 Volume，同一 Pod 内的多个容器可以同时使用一个 Volume，实现文件共享，或数据持久存储。

容器与 Volume 的简单关系：

![image-20200623123450872](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200623123450872.png)

## Volume 定义

定义在 `pod.spec.container` 属性下：

```yaml
kind: Pod
...
spec:
  container: 
    ...
    volumeMounts:
      - mountPath: <path>
        name: <volume-name>
        subPath: <volume-path>
  volumes:
    - name: <volume-name>
      <volume-type>:
      ...
```

- mountPath： 容器内的目录，如果不存在则创建该目录
- subPath：默认会将 mountPath 直接映射到 volume 的根目录，使用 subpath 映射到 volume 特定的目录。

## Volume 类型

Volume 有多种类型，有的可以直接在集群中使用，有的则需要第三方服务或云平台的支持。简单罗列几种常见类型，更多了类型参考：https://kubernetes.io/zh/docs/concepts/storage/volumes

### emptyDir

如果指定 Volume 类型为 emptyDir，它会在 Pod 刚被调度时，在被调度到的节点上创建起来。卷初始时时空的，里面没有文件，Pod 内的容器可以在卷中写入文件。多个容器绑定的 Volume 如果存在目录相同，则目录可以被共享读写。

如果 Pod 在该节点被销毁，那么 emptyDir 也将被永久删除。Pod 内的容器崩溃或重启是不会影响 emptyDir 的生命周期的。

由于 emptyDir 的生命周期受Pod影响，emptyDir 适合的使用场景也会受限，emptyDir 适合使用在数据临时计算，临时缓存等，不适合存储配置信息或持久化数据。

使用示例：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-redis
spec:
  containers:
    - image: nginx
      name: nginx
      volumeMounts:
        - name: dir
          mountPath: /shareDir
    - image: redis
      name: redis
      volumeMounts:
        - name: dir
          mountPath: /shareDir
  volumes:
    - name: dir
      emptyDir: {}
```

如果在 K8s 中创建上面这个 Pod，容器都运行起来后，分别进入 nginx 容器和 redis 容器，都可以在根目录下看到 `shareDir` 目录，并且在一个容器中写入了文件，另一个容器也可以读取到。当删除这个 Pod，再重新创建后，之前写入的文件会消失。

emptyDir 可以指定存储介质，默认是使用节点的磁盘创建起来的，也可以指定介质为内存，这种读写更快：

```yaml
volumes:
  - name: dir
    emptyDir:
      medium: Memory
```

### hostPath

hostPath 卷指向节点文件系统上的特定文件或目录，如果多个 Pod 运行在同一节点，并且指向相同的卷路径，则他们看的文件是相同的。

![image-20200623145055913](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200623145055913.png)

hostPath 类型的 Volume 的生命周期不受Pod限制，Pod 被删除，hostPath 下的文件仍然保留。由于 hostPath 数据只会保留在节点上，当 Pod 被重新调度到其他节点时，相对来说数据是丢失的。一般可以使用 hostPath 作为 DaemonSet（每个匹配节点都调度一个 Pod）管理的 Pod 的 Volume。

使用示例：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
    - image: redis
      name: redis
      volumeMounts:
        - name: dir
          mountPath: /data
  volumes:
    - name: dir
      hostPath:
        path: /vol/redis/data
        type: DirectoryOrCreate
```

当我们创建以上 Pod 资源，容器运行起来之后，则会在 Pod 所调度的宿主机上创建 `/vol/redis/data` 目录。如果我们删除Pod，宿主机上的 `/vol/redis/data` 目录不会被删除。

hostPath 的 type 类型，默认为空，直接使用 path，其他 type 使用时会检查和初始化 path：

- DirectoryOrCreate，如果 hostPath 定义的 path 目录不存在，则创建目录
- Directory，hostPath 定义的 path 目录已经存在，否则会异常
- FileOrCreate，如果 hostPath 定义 的path 文件不存在，则创建文件，如果前缀目录不存在也会报错，需要先使用 DirectoryOrCreate 创建目录
- File，hostPath 定义的 path 文件已经存在，否则会异常

### persistentVolumeClaim

### awsElasticBlockStore

使用 aws 的存储卷作为 Pod 的 Volume，它可以被多个 Pod 共同使用，并且它的生命周期不受 Pod 限制，当 Pod 被销毁，只是取消了绑定关系，存储不会被删除。

使用 awsElasticBlockStore 作为 Volume，需要提前在 aws 中创 volume，获取到 volumeID，然后 Pod 的 Volume 指定awsElasticBlockStore 的 volumeID 即可。

使用 aws-cli 创建 aws 中的 volume：

```bash
aws ec2 create-volume --availability-zone=ap-southeast-1a --size=2 --volume-type=gp2
```

以上命令完成会输出 volumeID。

使用 awsElasticBlockStore 作为 Pod 的 Volume 简单示例，前提我们已经获取到 了volumeID 为 vol-07afc8d24f8f08d2a：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis
  labels:
    name: redis
spec:
  containers:
    - name: redis
      image: redis
      volumeMounts:
        - mountPath: /data
          name: redis-data
  volumes:
    - name: redis-data
      awsElasticBlockStore:
        volumeID: vol-07afc8d24f8f08d2a
```

当我们创建以上 Pod 资源，容器运行起来之后，我们进入 redis 容器，使用 redis-cli往redis 中写入一个key-value后，立即退出容器，删除 Pod 并重新创建后，再次进入容器，是依然可以获取 key-value 的，这说明 Volume 数据没有随 Pod 被删除。

### configMap

存储配置项信息，供 Volume 使用，后续可能会单独介绍它的使用。

### Secret

存储敏感信息的配置，供 Volume 使用，后续可能会单独介绍它的使用。

