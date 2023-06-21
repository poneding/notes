# Golang 密钥对、数字签名和证书管理

1. Golang 实现密钥对升成

相当于使用 `openssl` 生成私钥和公钥：

```bash
openssl genrsa -out pri.key 2048
openssl rsa -in pri.key -pubout -out pub.key
```

```go
package main

import (
	"crypto/rand"
	"crypto/rsa"
)

func GenerateKeyPair() (*rsa.PrivateKey, *rsa.PublicKey, error) {
	prikey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		return nil, nil, err
	}
	return prikey, &prikey.PublicKey, nil
}
```

2. 实现加密和解密

加密解密：公钥加密，私钥解密

```go
package main

import (
	"crypto/rand"
	"crypto/rsa"
)

func Encrypt(data []byte, publicKey *rsa.PublicKey) ([]byte, error) {
	return rsa.EncryptPKCS1v15(rand.Reader, publicKey, data)
}

func Decrypt(data []byte, privateKey *rsa.PrivateKey) ([]byte, error) {
	return rsa.DecryptPKCS1v15(rand.Reader, privateKey, data)
}
```

3. 实现数字签名

数字签名：私钥签名，公钥验证

```go
package main

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
)

func Sign(data []byte, privateKey *rsa.PrivateKey) ([]byte, error) {
	hash := sha256.New()
	hash.Write(data)
	return rsa.SignPKCS1v15(rand.Reader, privateKey, crypto.SHA256, hash.Sum(nil))
}

func Verify(data []byte, sig []byte, publicKey *rsa.PublicKey) error {
	hash := sha256.New()
	hash.Write(data)
	return rsa.VerifyPKCS1v15(publicKey, crypto.SHA256, hash.Sum(nil), sig)
}
```
