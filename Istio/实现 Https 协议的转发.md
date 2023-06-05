# 实现 Https 协议的转发

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: demo
spec:
  http:
  - headers:
      request:
        set:
          X-Forwarded-Proto: https
    match:
    - uri:
        prefix: /
    name: demo.default
```

