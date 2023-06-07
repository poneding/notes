# VPA

## 安装

```bash
git clone https://github.com/kubernetes/autoscaler.git
cd ./autoscaler/vertical-pod-autoscaler

./hack/vpa-up.sh
```

卸载：

```bash
./hack/vpa-down.sh
```

### VPA运行模式

- **Auto（默认模式）**：VPA在pod创建时分配资源请求，并使用首选的更新机制在现有的pod上更新它们。目前，这相当于“重建”(见下文)。一旦pod请求的免费重启(“原位”)更新可用，它就可以被“Auto”模式用作首选的更新机制。注意:VPA的这个特性是实验性的，可能会导致您的应用程序停机。

- **Recreate**：VPA在pod创建时分配资源请求，并在现有pod上更新它们，当请求的资源与新建议有显著差异时(如果定义了pod中断预算，则考虑到它们)，将它们赶出现有pod。这种模式应该很少使用，只有当您需要确保在资源请求更改时重新启动pods时才会使用。否则更喜欢“自动”模式，这可能会利用重新启动免费更新，一旦他们可用。注意:VPA的这个特性是实验性的，可能会导致您的应用程序停机。

- **Initial**：VPA只在pod创建时分配资源请求，以后不会更改它们。
- **Off**：VPA不会自动更改pods的资源需求。计算并可以在VPA对象中检查建议。

## 示例

