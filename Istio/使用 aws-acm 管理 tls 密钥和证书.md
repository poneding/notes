# 使用 aws-acm 管理 tls 密钥和证书

参考：https://medium.com/faun/managing-tls-keys-and-certs-in-istio-using-amazons-acm-8ff9a0b99033

在Ingressgateway service的annotation中添加:

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-ingressgateway
  namespace: istio-system
  labels:
    app: my-ingressgateway
  annotations:
  	# external-dns.alpha.kubernetes.io/hostname: example.com
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
    service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: '3600'
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: >-
      arn:aws:acm:ap-southeast-1:xxxxxxxxxxxx:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: https
....
```

service.yaml:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-api
  labels:
    app: demop-api
spec:
  ports:
    - name: http
      port: 80
      targetPort: 80
  selector:
    app: demo-api
```

> pod 所在的 namespace 需要开启 istio-injection，例如：`kubectl label namespace default istio-injection=enabled`

gateway.yaml

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: demo-api-gateway
  annotations:
    ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: "istio-gateway"
spec:
  selector:
    istio: hpa-ingressgateway # use istio default controller
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - "example.com"
      tls:
        httpsRedirect: true # sends 301 redirect for http requests
    - port:
        number: 443
        name: https
        protocol: HTTP
      hosts:
        - "example.com"
```

> example.com 替换成你访问服务的域名；
>
> tls 设置自动跳转 https；
>
> 将 443 端口设置成 HTTP 协议，作为负载均衡器的 HTTPS 流量的目标端。

virtual-service.yaml:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: demo-api
spec:
  hosts:
    # - "demo-api-01.example.dev"
    - "example.com"
  gateways:
    - demo-api-gateway
  http:
    - match:
        - uri:
            prefix: /api/demo
      route:
        - destination:
            port:
              number: 80
            host: demo-api
```

> example.com 替换成你访问服务的域名。
