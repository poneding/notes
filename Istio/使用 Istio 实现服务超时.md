# 使用 Istio 实现服务超时

## 参考

- https://www.servicemesher.com/blog/circuit-breaking-and-outlier-detection-in-istio/

## 超时

为了防止无限期的等待服务，一般都会给服务设置超时时间，AWS 的 LoadBalancer 默认的超时时间是 60s。但是不同的服务，可能需要不同的超时设置，例如 DocumentApi 超时时间可能需要设置的长一点。

LoadBalancer 的超时是全局的，我们基于 Istio 服务网格集成了针对单个服务的超时功能。

## 重试

重试也是一个服务很常用的功能，例如某次请求分配到了一个问题节点，请求失败，则自动重试特定次数。

## 熔断/限流

为了防止大量涌入请求使得服务崩溃，引入熔断功能。熔断，可以限制当前请求连接数在一个特定范围内。

配置服务 VirtualService 既可实现：

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp
  http:
  - route:
    - destination:
        host: myapp
        subset: v1
    timeout: 1s
```

> timeout：请求超过设定的超时时间，响应返回 504 请求超时。
