# 使用 docker manifest 命令构建多架构镜像

```bash
# 创建
docker manifest create poneding/ash:v1 poneding/ash-amd:v1 poneding/ash-arm:v1

# 注解
docker manifest annotate poneding/ash:v1 poneding/ash-amd:v1 --arch amd64
docker manifest annotate poneding/ash:v1 poneding/ash-arm:v1 --arch arm64

# 检查
docker manifest inspect poneding/ash:v1

# 推送
docker manifest push poneding/ash:v1
```