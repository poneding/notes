# Golang 发布类库 - 2

![golang](https://pding.oss-cn-hangzhou.aliyuncs.com/images/golang.png)

本页介绍如何在 Github 上升级我们已发布的 Golang 类库。

## Go 类库版本规则

go 类库版本的规则：`主版本号.次版本号.修订号`，其中：

- 主版本号：类库进行了不可向下兼容的修改，例如功能重构，这时候主版本号往上追加；
- 次版本号：类库进行了可向下兼容的修改，例如新增功能，这时候次版本号往上追加；
- 修订号：类库进行了可向下兼容的修改（修改的规模更小），例如修复或优化功能，这时候修订好往上追加。

## Go 类库发版示例

同样以 `github.com/poneding/common-go` 类库为示例。

### 小版本升级

> 主版本不升级，次版本或修订版本升级。
>
> `v0.x.x` 版本升级至 `v1.x.x` 也是可以直接升级的。

当前版本是 `v1.0.0`，现对该类库进行了功能修改，发布 `v1.0.1` 版本：

**1、切换至 `v1` 分支**

```bash
git checkout v1
```

**2、修改类库代码**

*hello/hello.go*

```go
package hello

import "fmt"

func Say(name string) {
    fmt.Printf("Hello, %s\n", name)
    fmt.Println("common-go version: v1.0.1")
}
```

**3、提交代码并发布**

```bash
git add .
git commit -m "update hello"
git push
git tag v1.0.1
git push --tags 
```

**4、使用 `demo-go` 测试，升级版本**

升级类库方式：

- 使用 `go get -u github.com/poneding/common-go` 或 `go get github.com/poneding/common-go@latest` 升级至该主版本号下最新版本；
- 使用 `go get github.com/poneding/common-go@v1.0.0` 升级至指定版本。

```bash
$ go get - u github.com/poneding/common-go
go: downloading github.com/poneding/common-go v1.0.1
go: found github.com/poneding/common-go/hello in github.com/poneding/common-go v1.0.1
go: github.com/poneding/common-go upgrade => v1.0.1
```

查看 `demo-go` 下的 `go.mod` 文件，确实升级到了新版本：

*go.mod*

```go
module demo-go

go 1.16

require github.com/poneding/common-go v1.0.1
```

**5、运行测试**

```bash
$ go run main.go
Hello, Jay
common-go version: v1.0.1
```

### 大版本升级

> 主版本升级。
>
> 值得注意的是，使用 `go get -u github.com/poneding/common-go` 升级类库版本时，无法跨主版本升级，只能升级至当前主版本下最新版本；
>
> v0.x.x 升级至 v1.x.x 是个例外，可以直接使用 `go get -u github.com/poneding/common-go` 命令升级。

当前版本是 `v1.0.1`，现对该类库进行了功能重构，发布 `v2.0.0` 版本：

**1、继续按照最佳实践，创建 `v2` 版本的分支**

```bash
git checkout -b v2
```

**2、修改 module 名称至新版**

```bash
go mod edit -module github.com/poneding/common-go/v2
```

**3、v2 版本重构功能**

*hello/hello.go*

```go
package hello

import "fmt"

func Say(firstname, lastname string) {
    fmt.Printf("Hello, %s %s\n", firstname, lastname)
    fmt.Println("common-go version: v2.0.0")
}
```

**4、提交代码并发布**

```bash
git add .
git commit -m "refacte hello"
git push -u origin v2
git tag v2.0.0
git push --tags
```

**5、使用 `demo-go` 测试，升级版本**

注意，此时无法通过 `go get -u github.com/poneding/common-go` 升级至不同于当前主版本的最新版本，需要使用 `go get github.com/poneding/common-go/v2` 升级：

```bash
go get github.com/poneding/common-go/v2
```

查看 `go.mod` 文件，已经添加了 `v2` 版本依赖包

*go.mod*

```go
module demo-go

go 1.16

require github.com/poneding/common-go v1.0.1
require github.com/poneding/common-go/v2 v2.0.0
```

**6、修改测试代码**

同时使用 `v1` 版本和 `v2` 版本的包函数：

*main.go*

```go
package main

import (
    "github.com/poneding/common-go/hello"
    hellov2 "github.com/poneding/common-go/v2/hello"
)

func main() {
    hello.Say("Jay")
    hellov2.Say("Jay Chou")
}
```

**8、运行测试**

```bash
$ go run main.go
test hello:
Hello, Jay
common-go version: v1.0.1
Hello, Jay Chou
common-go version: v2.0.0
```

## 使用本地 go 类库

如果本地的 go 类库暂未维护到远端，如何引用本地类库的包呢？

在 go.mod 文件中使用 replace 引用本地 go 类库，这个方式有时候更方便于开发。

> common-go 的 module 名称为 `github.com/poneding/common-go`
>
> replace 使用 go 类库相对路径替换 module 的引用

以下示例将 go 类库的引用切换为本地引用。

*go.mod*

```go
module demo-go

go 1.16

require (
    github.com/poneding/common-go v1.0.1
    github.com/poneding/common-go/v2 v2.0.0
)

replace (
    github.com/poneding/common-go/v2 => ../common-go
)
```

由于是本地引用，版本号只需在主版本号的范围内即可。

## 结束语

主版本升级会给代码的维护和版本的维护增加难度，并且需要下游用户迁移版本。最好是当存在令人信服的原因时才对类库主版本进行升级，例如为了优化代码大规模重构。
