# Kubernetes 0-1 K8s部署Zookeeper和KafkaK

![](https://pding.oss-cn-hangzhou.aliyuncs.com/images/kubernetes_kafka_1.png)

按照官方定义，Kafka是一个分布式的流处理平台。更多了解官方文档：http://kafka.apachecn.org/intro.html

那么直接开始在K8s中部署kafka吧。

部署kafka，首先要有一个可用的Zookeeper集群，所以我们还需要先部署一个Zookeeper集群。

首先说明，我的K8s集群是使用的AWS的EKS服务，与自建的K8s集群的配置方面可能会有所差别。

## 部署Zookeeper

编写zookeeper-statefulSet.yaml文件：

```shell
vim zookeeper-statefulSet.yaml
```

写入内容:

```yaml
kind: StatefulSet
apiVersion: apps/v1beta1
metadata:
  name: zookeeper-1
  namespace: dev
spec:
  serviceName: zookeeper-1
  replicas: 1
  selector:
    matchLabels:
      app: zookeeper-1
  template:
    metadata:
      labels:
        app: zookeeper-1
    spec:
      containers:
        - name: zookeeper
          image: digitalwonderland/zookeeper
          ports:
            - containerPort: 2181
          env:
            - name: ZOOKEEPER_ID
              value: "1"
            - name: ZOOKEEPER_SERVER_1
              value: zookeeper-1
            - name: ZOOKEEPER_SERVER_2
              value: zookeeper-2
            - name: ZOOKEEPER_SERVER_3
              value: zookeeper-3
          volumeMounts:
            - name: zookeeper-data
              mountPath: "/var/lib/zookeeper/data"
              subPath: zookeeper
  volumeClaimTemplates:
    - metadata:
        name: zookeeper-data
        labels:
          app: zookeeper-1
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: gp2
        resources:
          requests:
            storage: 30Gi
---
kind: StatefulSet
apiVersion: apps/v1beta1
metadata:
  name: zookeeper-2
  namespace: dev
spec:
  serviceName: zookeeper-2
  replicas: 1
  selector:
    matchLabels:
      app: zookeeper-2
  template:
    metadata:
      labels:
        app: zookeeper-2
    spec:
      containers:
        - name: zookeeper
          image: digitalwonderland/zookeeper
          ports:
            - containerPort: 2181
          env:
            - name: ZOOKEEPER_ID
              value: "2"
            - name: ZOOKEEPER_SERVER_1
              value: zookeeper-1
            - name: ZOOKEEPER_SERVER_2
              value: zookeeper-2
            - name: ZOOKEEPER_SERVER_3
              value: zookeeper-3
          volumeMounts:
            - name: zookeeper-data
              mountPath: "/var/lib/zookeeper/data"
              subPath: zookeeper-data
  volumeClaimTemplates:
    - metadata:
        name: zookeeper-data
        labels:
          app: zookeeper-2
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: gp2
        resources:
          requests:
            storage: 30Gi

---
kind: StatefulSet
apiVersion: apps/v1beta1
metadata:
  name: zookeeper-3
  namespace: dev
spec:
  serviceName: zookeeper-3
  replicas: 1
  selector:
    matchLabels:
      app: zookeeper-3
  template:
    metadata:
      labels:
        app: zookeeper-3
    spec:
      containers:
        - name: zookeeper
          image: digitalwonderland/zookeeper
          ports:
            - containerPort: 2181
          env:
            - name: ZOOKEEPER_ID
              value: "3"
            - name: ZOOKEEPER_SERVER_1
              value: zookeeper-1
            - name: ZOOKEEPER_SERVER_2
              value: zookeeper-2
            - name: ZOOKEEPER_SERVER_3
              value: zookeeper-3
          volumeMounts:
            - name: zookeeper-data
              mountPath: "/var/lib/zookeeper/data"
              subPath: zookeeper
  volumeClaimTemplates:
    - metadata:
        name: zookeeper-data
        labels:
          app: zookeeper-3
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: gp2
        resources:
          requests:
            storage: 30Gi
```

编写zookeeper-service.yaml文件：

```shell
vim zookeeper-service.yaml
```

写入内容：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: zookeeper-1
  namespace: dev
  labels:
    app: zookeeper-1
spec:
  ports:
    - name: client
      port: 2181
      protocol: TCP
    - name: follower
      port: 2888
      protocol: TCP
    - name: leader
      port: 3888
      protocol: TCP
  selector:
    app: zookeeper-1

---
apiVersion: v1
kind: Service
metadata:
  name: zookeeper-2
  namespace: dev
  labels:
    app: zookeeper-2
spec:
  ports:
    - name: client
      port: 2181
      protocol: TCP
    - name: follower
      port: 2888
      protocol: TCP
    - name: leader
      port: 3888
      protocol: TCP
  selector:
    app: zookeeper-2

---
apiVersion: v1
kind: Service
metadata:
  name: zookeeper-3
  namespace: dev
  labels:
    app: zookeeper-3
spec:
  ports:
    - name: client
      port: 2181
      protocol: TCP
    - name: follower
      port: 2888
      protocol: TCP
    - name: leader
      port: 3888
      protocol: TCP
  selector:
    app: zookeeper-3
```

完成以上两个文件后，执行kubectl命令即可：

```shell
kubectl apply -f zookeeper-statefulSet.yaml
kubectl apply -f zookeeper-service.yaml
```

## 部署Kafka

## 部署Kafka Connect

```shell
wget https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/0.16.1/examples/kafka/kafka-persistent-single.yaml
```

安装集群

```shell
wget https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.18.0/strimzi-cluster-operator-0.18.0.yaml
```

> 可能该文件下载下来你需要修改其中的namespace。

