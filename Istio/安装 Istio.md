# 安装 Istio

## 安装istioctl

**Step 1 下载**

> 以下操作步骤默认会安装最新版 istioctl。

```bash
curl -L https://istio.io/downloadIstio | sh -
```

以上命令默认会安装最新版 istioctl，如果需要安装指定版本例如 `1.6.8`，使用以下命令。

```bash
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.6.8 TARGET_ARCH=x86_64 sh -
```

**Step 2 配置**

step 1会下载istio包，目录`istio-{ISTIO_VERSION}`，进入目录

```bash
cd istio-{ISTIO_VERSION}
```

拷贝bin目录下的istioctl二进制文件到PATH目录下：

```bash
cp bin/istio /usr/local/bin
```

