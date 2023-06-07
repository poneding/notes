# 使用 docker manifest 命令构建多架构镜像

```bash
# 创建
docker manifest create poneding/myimage:v1 poneding/myimage-amd64:v1 poneding/myimage-arm64:v1

# 注解
docker manifest annotate poneding/myimage:v1 poneding/myimage-amd64:v1 --arch amd64
docker manifest annotate poneding/myimage:v1 poneding/asmyimageh-arm64:v1 --arch arm64

# 检查
docker manifest inspect poneding/myimage:v1

# 推送
docker manifest push poneding/myimage:v1
```
