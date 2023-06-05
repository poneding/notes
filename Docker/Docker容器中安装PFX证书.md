# Docker容器中安装PFX证书

如果正在开发.NetCore项目，并且你的项目需要使用到PFX证书。此时你需要将你的项目发布到Docker容器中，那么你就需要在你的Docker容器中安装PFX证书了。

## 代码中编写

使用X509Store Api编写你的程序

```csharp
using (var certificate = new X509Certificate2(pfxFileBytes, pfxPassword, X509KeyStorageFlags.Exportable | X509KeyStorageFlags.PersistKeySet))
using (var store = new X509Store(storeName, storeLocation, OpenFlags.ReadWrite))
{
    store.Add(certificate);
    store.Close();
}
```

## Dockerfile中编写

使用dotnet-certificate-tool工具安装pfx证书。

首先获取到Pfx文件的Thumbprint，这在dotnet-certificate-tool命令中作为参数被使用。

- 使用Powershell Get-PfxCertificate函数获取Thumbprint

```powershell
Get-PfxCertificate -FilePath C:\Pfx\Hello-to-World.pfx
```

执行以上命令，会要求输入pfx证书密码，输入密码后，你应该可以得到Thumbprint了，输出格式大致如下：

```
Thumbprint                                Subject
----------                                -------
EED5DCA70697648CDFGD7FB1EFDDD683579B436E  CN=Hello-to-World, OU=IT, O=Hello
```

在Dockerfile内容大致如下

```dockerfile
FROM mcr.microsoft.com/dotnet/core/sdk:3.1
WORKDIR /app
COPY Hello-to-World.pfx ./
ENV PATH "$PATH:/root/.dotnet/tools"
RUN dotnet tool install dotnet-certificate-tool -g && certificate-tool add -f ./Hello-to-World.pfx -p Password123 -t EED5DCA70697648CDFGD7FB1EFDDD683579B436E
ENTRYPOINT ["dotnet", "PfxTest.dll"]
```
