# Istio 0-1 使用Istio实现Cors

![istio](https://pding.oss-cn-hangzhou.aliyuncs.com/images/istio.jpg)

## Cors

Cors（Cross-Origin Resource Sharing）：跨域资源共享，是一种基于 HTTP Header 的机制，该机制通过允许服务器标示除了它自己以外的其它 origin（域，协议和端口），这样浏览器可以访问加载这些资源。跨源资源共享还通过一种机制来检查服务器是否会允许要发送的真实请求，该机制通过浏览器发起一个到服务器托管的跨源资源的"预检"请求。在预检中，浏览器发送的头中标示有 HTTP 方法和真实请求中会用到的头。

跨源HTTP请求的一个例子：运行在 https://a.com 的JavaScript代码使用[`XMLHttpRequest`](https://developer.mozilla.org/zh-CN/docs/Web/API/XMLHttpRequest)来发起一个到 https://b.com/data.js 的请求。

出于安全性，浏览器限制脚本内发起的跨域 HTTP 请求。 例如，XMLHttpRequest 和 Fetch API 遵循同源策略。 这意味着使用这些 API 的 Web 应用程序只能从加载应用程序的同一个域请求 HTTP 资源，除非响应报文包含了正确 CORS 响应头。

![image-20210524170024751](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20210524170024751.png)

更多 Cors 知识：[跨域资源共享（CORS）](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/CORS)

## Istio 实现

基于 Istio VirtualService 的配置实现。

官方文档：[Istio / Virtual Service#CorsPolicy](https://istio.io/latest/docs/reference/config/networking/virtual-service/#CorsPolicy)

在目标服务上设置允许的请求域 `Hello`：

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: b
spec:
  http:
  - route:
    - destination:
        host: b.default.svc.cluster.local
    corsPolicy:
      allowOrigins:
      - exact: https://a.com
      - exact: https://b.com
      allowMethods:
      - GET
```

> 配置 allowOrigins 以及 allowMethods。

