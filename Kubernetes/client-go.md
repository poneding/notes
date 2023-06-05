# 云原生应用开发：Operator原理与实践

## 2. Operator原理

### 2.2 client-go原理

client-go主要用在Kubernetes的Controller中，包括内置Controller（如kube-controller-manager）和CRD控制器；

实现对各类K8s API资源的增删改查操作；

包含Reflector，Informer，Indexr等组件。

#### 2.2.1 client-go介绍

是操作k8s集群资源的编程式交互客户端，利用对kube-apiserver的交互访问，实现对各类K8s API资源的增删改查操作；

client-go不仅被k8s项目本身使用（如kubectl），还在基于k8s的二次开发中被外部用户广泛使用：自定义控制器，Operator等。

**使用**

client-go库抽象封装了与k8s reset api的交互，便于开发者基于k8s做二次开发。利用client-go操作k8s资源的流程基本如下：

1. 通过kubeconfig信息构造Config实例，该实例记录了集群证书，k8s apiserver地址等信息；
2. 根据Config实例携带的信息构建特定的客户端（clientset，dynamicset等）；
3. 利用客户端向k8s apiserver发起请求，操作k8s资源。

以下是使用client-go获取pod的代码清单：

```golang
func main() {
    var kubernetes *string
    if home := homeDir(); home != "" {
        kubeconfig := flag.String(
        	"kubeconfig",
            filePath.Join(home, ".kube", "config"),
            "(optional) absolute path to the kubeconfig file",
        )
    } else {
        kubeconfig := flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
    }
    flag.Parse()
    
    // use the current context in kubeconfig
    config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
    if err != nil {
        panic(err.Error())
    }
    
    // create the clientset
    clientset, err := kubernetes.NewForConfig(config)
    if err != nil {
        panic(err.Error())
    }
    for {
        pods, err := clientset.CoreV1().Pods("").List(context.TODO(), metav1.ListOptions{})
        if err != nil {
            panic(err.Error)
        }
        
        // ...
    }
}

func homeDir() string {
    if h := os.Getenv("HOME"); h != "" {
        return h
    }
    return os.Getenv("USERPROFILE") // windows
}
```

#### 2.2.2 client-go主体结构

client-go支持4种与k8s apiserver交互的客户端：

##### RESTClient

最基础的客户端，主要对HTTP请求进行封装，支持JSON和Protobuf格式数据；

```go
package main

import (
	"context"
    "fmt"
    
    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/client-go/kubernetes/scheme"
    "k8s.io/client-go/reset"
    "k8s.io/client-go/tools/clientcmd"
)

func main() {
    // 加载配置文件，生成config对象
    config, err := clientcmd.BuildConfigFromFlags("", "/root/.kube/config")
    if err != nil {
        panic(err.Error())
    }
    
    // 配置API路径和请求的GV
    config.APIPath = "api"
    config.GroupVersion = &corev1.SchemeGroupVersion
    
    // 配置数据的编解码器
    config.NegotiatedSerializer = scheme.Codecs
    
    // 实例化RESTClient对象
    restclient, err := rest.RESTClientFor(config)
    if err != nil {
        panic(err.Error())
    }

    result := &corev1.PodList{}
    
    err = restclient.Get().
    	Namespace("default").
    	Resource("pods").
    	VersionedParams(&metav1.ListOptions{Limit: 100}, scheme.ParameterCodec).
    	Do(context.TODO()).Into(result)
	}
    
    if err != nil {
        panic(err.Error)
    }
    
    for _, d := range result.Items {
        fmt.Printf(
            "NAMESPACE: %v \t NAME: %v \t STATUS: %v\n",
            d.Namespace,
            d.Name,
            d.Status.Phase,
        )
    }
}
```

##### Clientset

k8s自身内置资源的客户端集合，仅能操作已知类型的内置资源，如Pod，Service等；

```go
```

##### DynamicClient

动态客户端，可以对任意k8s资源执行通用操作，包括CRD。

通过动态指定GVR操作任意k8s资源，以`map[string]interface{}`结构存储k8s apiserver的返回数据，再利用反射机制在运行时进行数据绑定。这种松耦合的方式意味着更高的灵活性，但与此同时，也无法获取强数据类型检查和验证的好处。

理解DynamicClient，你可能需要对这`Object.runtime`接口和`Unstructured`结构体有所了解：

- Object.runtime：k8s中所有资源都实现了该接口，包括`DeepCopyObject`和`GetObjectKind`方法：
- Unstructured：包含

```go
```

##### DiscoveryClient

发现客户端，发现apiserver支持的资源组，资源版本和资源信息（GVR），使用`kubectl api-versions`可以获取支持的资源；

