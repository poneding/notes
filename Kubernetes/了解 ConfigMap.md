# 了解 ConfigMap

![202306051105607](https://pding.oss-cn-hangzhou.aliyuncs.com/images/202306051105607.png)

几乎所有的应用都需要配置信息，在 K8s 部署应用，最佳实践是将应用的配置信息（环境变量或者配置文件）和程序本身分离，这样配置信息的更新和复用都可以更简单，也使得程序更加灵活。

Kubernetes 允许将配置选项分离到单独的资源对象 ConfigMap 中，本质上是一个键值对映射，值可以是一个短 string 串，也可以是一个完整的配置文件。

本篇主要介绍 ConfigMap 资源的创建和使用。

## ConfigMap 的创建

可以直接通过 `kubectl create configmap` 命令创建，也可以先编写 configmap 的 yaml 文件再使用`kubectl apply -f <filename>`创建，推荐使用后者。

### 单行命令创建 ConfigMap

- 创建一个键值对的 ConfigMap：

```shell
kubectl create configmap first-config --from-literal=user=admin
```

创建完成之后，使用 `kubectl describe configmap first-config` 查看，可以看到这个 configmap 的键值内容。

![image-20200703102551743](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200703102551743.png)

> 可以使用多组 `--from-literal=<key>=<value>` 参数，在 configmap 中定义多组键值对。

- 创建一个文件内容的 ConfigMap

假如我当前有一个配置文件 app.json，文件内容如下：

```json
{
  "App": "MyApp",
  "Version": "v1.0"
}
```

使用以下命令创建 ConfigMap：

```shell
kubectl create configmap second-config --from-file=app.json
```

创建完成之后，使用 `kubectl describe configmap second-config` 查看 configmap 的键值内容：

![image-20200703114012333](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200703114012333.png)

> 默认使用文件名称 app.json 作为键值对的 key，也可以通过 `--from-file=app_config=app.json` 指定key为 `app_config`；
>
> 可以使用多组 `--from-file=<key>=<filename>` 参数，在 configmap 中定义多组文件；
>
> `--from-file=` 后面可以直接跟某个文件路径，这样会将目录下的所有文件引入到 ConfigMap;
>
> `--from-literal` 和 `--from-file` 可以共同使用，键值合并。

删除创建的 `first-config` 和 `second-config`：

```shell
kubectl delete configmap first-config
kubectl delete configmap second-config
```

### 基于资源清单文件创建 ConfigMap

- 创建一个键值对的 ConfigMap：

首先定义 ConfigMap 的资源文件 first-config.yaml，定义如下：

```shell
vim first-config.yaml
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: first-config
data:
  user: "admin"
```

使用 `kubectl apply` 命令创建 ConfigMap 资源：

```shell
kubectl apply -f first-config.yaml
```

创建完成之后，使用 `kubectl describe configmap first-config` 查看，可以看到这个 configmap 的键值内容，结果与上文第一次创建的 `first-configmap` 是一致的。

> 可以在 `data` 下定义多组键值对。

- 创建一个文件内容的 ConfigMap

首先定义 ConfigMap 的资源文件 second-config.yaml，定义如下：

```shell
vim second-config.yaml
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: second-config
data:
  app.json: |
    {
      "App": "MyApp",
      "Version": "v1.0"
    }
```

使用 `kubectl apply` 命令创建 ConfigMap 资源：

```shell
kubectl apply -f second-config.yaml
```

创建完成之后，使用 `kubectl describe configmap second-config` 查看，可以看到这个 configmap 的键值内容，结果与上文第一次创建的 `second-configmap` 是一致的。

>可以在 `data` 下定义多组文件，也可以和键值对一起定义；
>
>其本质也是键值对，只是 value 为多行格式的文本内容；
>
>对 value 有格式要求，”|“接换行并且文件内容的每行按照 key 都往后退格。

删除创建的 `first-config` 和 `second-config`：

```shell
kubectl delete configmap first-config
kubectl delete configmap second-config
```

## ConfigMap 的使用

我们创建了 ConfigMap 后，我们的 Pod 资源就可以利用了。主要有两种方式使用 ConfigMap：

- 使用 ConfigMap 作为容器的环境变量
- 使用 ConfigMap 作为 Volume 向容器提供文件

### 使用 ConfigMap 作为容器的环境变量

假如有一个名为 `first-config`的 ConfigMap，里面包含了一个键为 `user`，我想将这个 ConfigMap 中 `user` 键用到我的环境变量 `USER_NAME` 中，可以使用如下方式：

```yaml
...
env:
- name: USER_NAME
  valueFrom:
    configMapKeyRef:
      name: first-config
      key: user
...
```

如果有一个名为 `second-config` ConfigMap 中包含多个键如 `HOST`，`PORT`，`USER_NAME`，`PASSWORD`，我想将这个 ConfigMap 中所有的键都用到我的环境变量中，可以使用如下方式：

```yaml
...
spec:
  container:
  - image: <some-image>
    envFrom:
    - prefix: DB_
      configMapRef:
        name: second-config
...
```

容器将会生成 `DB_HOST`，`DB_PORT`，`DB_USER_NAME`，`DB_PASSWORD` 四个环境变量，`prefix` 也可以不配置，则直接使用 ConfigMap 的键。

注意：

- `configMapRef` 与上面 `configMapKeyRef` 的区别；
- 如果ConfigMap中有一个为 `USER-NAME` 键，那么将不会生成 `DB_USER-NAME` 的环境变量，因为 `DB_USER-NAME` 不是一个合法的环境变量名称。

### 使用 ConfigMap 作为 Volume 向容器提供文件

从这里开始，结合实际演练可能效果会好一点。

我仍然使用 `poneding/mockapi:v1` 镜像运行模拟应用程序，程序的代码在这：https://github.com/poneding/for-docker

这个应用程序根目录下存在 `mysettings/app.json` 和 `mysettings/secret.json` 两个配置文件，需要提前说明的是这个镜像中已经存在了这两个文件，并且文件内容如下：

*mysettings/app.json*

```json
{
    "App": "Hello Web",
    "Version": "v1"
}
```

*mysettings/secret.json*

```json
{
    "UserName": "admin",
    "Password": "123456"
}
```

我现在将这两个配置文件放在我的 ConfigMap 中，并且内容与镜像中略微区别，用于区分程序读取配置源自 ConfigMap，然后使用 Volume 的形式将文件挂载到应用中去。

首先，定义 ConfigMap 文件如下：

```shell
vim mockapi-mysettings.yaml
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mockapi-mysettings
data:
  app.json: |
    {
      "App":"Hello Web [From ConfigMap]",
      "Version":"v1 [From ConfigMap]"
    }  
  secret.json: |
    {
      "UserName":"admin [From ConfigMap]",
      "Password":"123456 [From ConfigMap]"
    }
```

定义 Pod 文件如下：

```shell
vim mockapi-pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mockapi
spec:
  containers:
  - name: mockapi
    image: poneding/mockapi:v1
    ports:
      - containerPort: 80
    volumeMounts:
      - mountPath: /app/mysettings
        name: mockapi-mysettings
  volumes:
  - name:  mockapi-mysettings
    configMap:
      name: mockapi-mysettings
```

Apply 资源：

```shell
kubectl apply -f mockapi-mysettings.yaml
kubectl apply -f mockapi-pod.yaml
```

等待 mockapi 的 Pod 起来之后，我们调用 `http://<pod-ip>/configuration/mysettings` 查看挂载的配置文件是否生效：

![image-20200703145347110](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200703145347110.png)

>mockapi 应用访问 `/configuration/mysettings` 会获取 app.json 和 secret.json 里面的总共四个配置项，然后输出到客户端。

可以看到，已经获取到了 ConfigMap 里面的配置，进入容器也可以看到里面的问题件内容：

![image-20200703145553692](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200703145553692.png)

**修改 ConfigMap 自动更新挂载文件**

现在，如果我想要修改我的配置，比如我的密码修改成了 `abcdefg`，我不用重新启动 Pod，我只需要修改 ConfigMap 文件：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mockapi-mysettings
data:
  app.json: |
    {
      "App":"Hello Web [From ConfigMap]",
      "Version":"v1 [From ConfigMap]"
    }  
  secret.json: |
    {
      "UserName":"admin [From ConfigMap]",
      "Password":"abcdefg [From ConfigMap]"
    }
```

然后重新 Apply 资源：

```shell
kubectl apply -f mockapi-mysettings.yaml
```

配置文件的更新需要 1-2 分钟的时间，我们可以连续观察文件的更新情况：

![image-20200703150408425](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200703150408425.png)

可以看到，过段时间后配置文件更新了。

> 这里遇到了一个小问题，继续访问 `/configuration/mysettings`，应用程序并没有热更新，但是我使用 hostPath 的 Volume 形式挂载时，修改配置文件是可以热更新的，希望有缘人能给我解答吧。

**多文件目录下挂载单个文件**

在实际的应用中，可能 `secret.json` 的变动更为频繁，而 `app.json` 文件几乎不会变动，我现在只想使用 ConfigMap 传递 `secret.json` 文件，而不再传递 `app.json`，这时，修改 ConfigMap 文件如下：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mockapi-mysettings
data:
  secret.json: |
    {
      "UserName":"admin [From ConfigMap]",
      "Password":"123456 [From ConfigMap]"
    }
```

然后，重新 Apply 资源:

```shell
kubectl apply -f mockapi-mysettings.yaml
```

这时候，我们继续访问 `/configuration/mysettings`：

![image-20200703165501675](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200703165501675.png)

很遗憾的发现，我们的 `app.json` 的配置项都失效了，我们接着去容器中一探究竟：

![image-20200703165644716](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200703165644716.png)

原来，app.json 文件已经不存在了。

大概推测一下可以知道，**如果使用 ConfigMap 挂载到容器的一个目录，那么该目录会被 ConfigMap 所覆盖。**那么如果只挂载单个目录呢？使用 **subPath**！

修改 Pod 文件如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mockapi
spec:
  containers:
  - name: mockapi
    image: poneding/mockapi:v1
    ports:
      - containerPort: 80
    volumeMounts:
      - mountPath: /app/mysettings/secret.json
        name: mockapi-mysettings
        subPath: secret.json
  volumes:
  - name:  mockapi-mysettings
    configMap:
      name: mockapi-mysettings
```

> `mountPath` 是容器中目标文件路径；
>
> `subPath` 是ConfgMap文件的 Key 值。

然后，重新 Apply 资源:

```shell
kubectl delete -f mockapi-pod.yaml
kubectl apply -f mockapi-pod.yaml
```

等待Pod运行后，我们访问 `/configuration/mysettings`，并查看 mysettings 目录下文件：

![image-20200703170634355](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200703170634355.png)

可以看到成功的挂载 `secret.json` 文件而没有挂载 `app.json` 文件，[From ConfigMap] 就是证明。

需要额外注意的是，在使用过程中发现，使用 `subPath` 挂载单文件的话，ConfigMap 的更新不会同步更新到容器对应文件中。这时候的解决办法是一个目录只存放一个配置文件，然后 ConfigMap 挂载到目录。

如果一个 ConfigMap（app-config）中定义了多个文件（app1.json、app2.json），但是 app1-pod 中只会使用到 `app1.json`，可以使用如下方式：

```yaml
...
      volumeMounts:
      - mountPath: /config/path
        name: mockapi-mysettings
  volumes:
  - name:  app-config
    configMap:
      name: app-config
      items:
      - key: app1.json
        path: app.json
```

> items 的 key 用于指定 ConfigMap 的 key，path 则可以定义为程序中的文件名。
