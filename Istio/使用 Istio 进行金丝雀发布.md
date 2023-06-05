# 使用 Istio 进行金丝雀发布

我们的应用 `myweb` 从v1升级到v2，使用金丝雀的方式发布，首先我们模拟10%的流量到 v2，90%的流量到 v1。

## Kubernetes 发布

**Kubernetes Service**

```yaml
apiVersion: v1
kind: Service
metadata:
name: myweb
labels:
  app: myweb
spec:
  selector:
    app: myweb
  ...
```

**Kubernetes Deployment**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myweb-v1
spec:
  replicas: 9
  template:
    metadata:
      labels:
        app: myweb
        version: v1
    spec:
      containers:
      - image: myweb-v1
        ...
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myweb-v2
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: myweb
        version: v2
    spec:
      containers:
      - image: myweb-v2
        ...
```

按照 Kubernetes Service 的逻辑，它会轮询的将请求分发到后端的 endpoint，如果我们想实现百分比的流量分配，我们就只能在 endpoint 的数量上做文章，所以可以看到我们的 v1 和 v2 版本的 Deployment 的 Replicas 分别为 9 和 1。这肯定是不友好的并且不太现实的，接下来我们再看看 Istio 怎么实现金丝雀发布。

## Istio发布

**Virtual Service**

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myweb
spec:
  hosts:
    - myweb
  http:
  - route:
    - destination:
        host: myweb
        subset: v1
        weight: 90
    - destination:
        host: myweb
        subset: v2
        weight: 10
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: myweb
spec:
  host: myweb
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

**Kubernetes Service**

```yaml
kind: Deployment
metadata:
  name: myweb-v1
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: myweb
        version: v1
    spec:
      containers:
      - image: myweb-v1
        ...
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: myweb-v2
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: myweb
        version: v2
    spec:
      containers:
      - image: myweb-v2
        ...
```

不需要刻意的调整不同版本的 replicas 数量，甚至我们还可能为这两个版本的 Deployment 做 HPA 的自动扩缩。

