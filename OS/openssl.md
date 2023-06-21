# openssl

openssl 常用于生成证书、签名、加密等操作。它是一个开源的工具，可以在 Linux、Windows、MacOS 等操作系统上运行。

包含三个组件：

- openssl：命令行工具
- libcrypto：加密算法库
- libssl：加密模块应用库，实现了 SSL 和 TLS 协议

## 对称加密

```bash
echo test > test.txt
# 加密
openssl enc -e -des3 -a -salt -in test.txt -out test.txt.enc
# 解密
openssl enc -d -des3 -a -salt -in test.txt.enc -out test.txt.dec
```

> -salt：加盐，增加破解难度，使用 openssl 默认盐值
> -S [salt]：指定盐值

## 非对称加密

生成密钥对

```bash
openssl genrsa -out rsa_private_key.pem 2048
openssl rsa -in rsa_private_key.pem -pubout -out rsa_public_key.pem
```

加密（公钥加密，私钥解密）

```bash
echo test > test.txt
# 加密
openssl rsautl -encrypt -inkey rsa_public_key.pem -pubin -in test.txt -out test.txt.enc

# 解密
openssl rsautl -decrypt -inkey rsa_private_key.pem -in test.txt.enc -out test.txt.dec
```

数字签名（私钥签名，公钥验证）

```bash
echo test > test.txt
# 签名
openssl dgst -sha256 -sign rsa_private_key.pem -out test.txt.sign test.txt

# 验证
openssl dgst -sha256 -verify rsa_public_key.pem -signature test.txt.sign test.txt
```

## CA 证书 & 颁发证书

生成 CA 私钥和证书

```bash
# 至少需要输入 4 位密码口令
openssl req -new -x509 -days 3650 -keyout ca.key -out ca.crt
```

生成服务端私钥和证书

```bash
# 服务端私钥
openssl genrsa -out server.key 2048

# 服务端证书签署请求（csr）
openssl req -new -key server.key -out server.csr

# 服务端证书
openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
```

查看证书信息

```bash
# 查看 CA 证书
openssl x509 -in ca.crt -noout -text

# 查看服务端证书
openssl x509 -in server.crt -noout -text
```
