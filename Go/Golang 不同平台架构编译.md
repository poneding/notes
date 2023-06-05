# Golang 不同平台架构编译

**在 MacOS 平台编译成 Windows、Linux 可执行文件**

```bash
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build main.go
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build main.go
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
```

**在 Windows 平台编译成 Linux、MacOS 可执行文件**

```bash
$env:GOOS = "linux";$env:CGO_ENABLED = "0";$env:GOARCH = "amd64";go build carbon/carbon.go
$env:GOOS = "linux";$env:CGO_ENABLED = "0";$env:GOARCH = "arm64";go build carbon/carbon.go
$env:GOOS = "darwin";$env:CGO_ENABLED = "0";$env:GOARCH = "amd64";go build carbon/carbon.go
$env:GOOS = "darwin";$env:CGO_ENABLED = "0";$env:GOARCH = "arm64";go build carbon/carbon.go
```

**在 Linux 平台编译成 Windows、MacOS 可执行文件**

```bash
CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build main.go
CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build main.go
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
CGO_ENABLED=0 GOOS=windows GOARCH=arm64 go build main.go
```

