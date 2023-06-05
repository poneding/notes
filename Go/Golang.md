# Golang

## 资料

- [Go 安全指南](https://github.com/Tencent/secguide/blob/main/Go%E5%AE%89%E5%85%A8%E6%8C%87%E5%8D%97.md)
- [Go 语言编程规范](https://github.com/xxjwxc/uber_go_guide_cn)

## Golang channel

golang 实现并发是通过通信共享内存，channel 是 go 语言中goroutine 的通信管道，通过 channel 将值从一个 goroutine 发送到另一个 goroutine。

### 语法

**创建 channel**

使用 `make()` 函数创建：

```go
ch := make(chan int)
```

> 默认创建一个无缓存 channel。

**发送数据到 channel**

```go
ch <- x
```

**从 channel 读取数据**

```go
x := <-ch
```

**关闭 channel**

使用 `close()` 函数关闭：

```go
close(ch)
```

> 当你的程序不再需要往 channel 中发送数据时，可以关闭 channel。
>
> 如果往已经关闭的 channal 发送数据，程序发生异常。

### 无缓冲 channel

如果当前没有一个 goroutine 对无缓冲 channel 接收数据，那么无缓冲 channel 会阻止发送数据。

### 有缓冲 channel

类似队列机制，创建时需要设定缓冲大小。

**创建一个有缓冲 channel**

```go
ch := make(chan int ch, 10)
```

> 在有 goroutine 接收 channel 数据之前，可以先向 channel 中发送10个数据。

### 无缓冲 channel 与有缓冲 channel的区别

现在，你可能想知道何时使用这两种类型。 这完全取决于你希望 goroutine 之间的通信如何进行。 无缓冲 channel 同步通信。 它们保证每次发送数据时，程序都会被阻止，直到有人从 channel 中读取数据。

相反，有缓冲 channel 将发送和接收操作解耦。 它们不会阻止程序，但你必须小心使用，因为可能最终会导致死锁（如前文所述）。 使用无缓冲 channel 时，可以控制可并发运行的 goroutine 的数量。 例如，你可能要对 API 进行调用，并且想要控制每秒执行的调用次数。 否则，你可能会被阻止。

## 读取文件

### 一次性全读

```golang
package main

import (
	"fmt"
	"io/ioutil"
)

func main() {
	bytes, e := ioutil.ReadFile("/Users/dp/tmp/0811/03/file.txt")
	if e != nil {
		panic("read file error.")
	}
	fmt.Println(string(bytes))
}

```

### 按行读取

```golang
package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

func main() {
	f, e := os.Open("C:/Users/dp/go/src/0811/03/file.txt")
	if e != nil {
		panic("read file error.")
	}
	defer f.Close()
	r := bufio.NewReader(f)

	for {
		line, _, eof := r.ReadLine()
		if eof == io.EOF {
			break // read last line.
		}
		fmt.Println(string(line))
	}
}
```

## 优雅退出

### 不处理优雅退出

```golang
package main

import (
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()
	router.GET("/", func(c *gin.Context) {
		time.Sleep(5 * time.Second)
		c.String(http.StatusOK, "Welcome Gin Server")
	})

	server := &http.Server{
		Addr:    ":8080",
		Handler: router,
	}

	quit := make(chan os.Signal)
	signal.Notify(quit, os.Interrupt)

	go func() {
		<-quit
		log.Println("receive interrupt signal")
		if err := server.Close(); err != nil {
			log.Fatal("Server Close:", err)
		}
	}()

	if err := server.ListenAndServe(); err != nil {
		if err == http.ErrServerClosed {
			log.Println("Server closed under request")
		} else {
			log.Fatal("Server closed unexpect")
		}
	}

	log.Println("Server exiting")
}
```

### 优雅退出 1（with context）

```golang
package main

import (
	"context"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	// Create context that listens for the interrupt signal from the OS.
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	router := gin.Default()
	router.GET("/", func(c *gin.Context) {
		time.Sleep(10 * time.Second)
		c.String(http.StatusOK, "Welcome Gin Server")
	})

	srv := &http.Server{
		Addr:    ":8080",
		Handler: router,
	}

	// Initializing the server in a goroutine so that
	// it won't block the graceful shutdown handling below
	go func() {
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %s\n", err)
		}
	}()

	// Listen for the interrupt signal.
	<-ctx.Done()

	// Restore default behavior on the interrupt signal and notify user of shutdown.
	stop()
	log.Println("shutting down gracefully, press Ctrl+C again to force")

	// The context is used to inform the server it has 5 seconds to finish
	// the request it is currently handling
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("Server forced to shutdown: ", err)
	}

	log.Println("Server exiting")
}
```

### 优雅退出 2（without context）

```golang
package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()
	router.GET("/", func(c *gin.Context) {
		time.Sleep(5 * time.Second)
		c.String(http.StatusOK, "Welcome Gin Server")
	})

	srv := &http.Server{
		Addr:    ":8080",
		Handler: router,
	}

	// Initializing the server in a goroutine so that
	// it won't block the graceful shutdown handling below
	go func() {
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %s\n", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server with
	// a timeout of 5 seconds.
	quit := make(chan os.Signal, 1)
	// kill (no param) default send syscall.SIGTERM
	// kill -2 is syscall.SIGINT
	// kill -9 is syscall.SIGKILL but can't be catch, so don't need add it
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")

	// The context is used to inform the server it has 5 seconds to finish
	// the request it is currently handling
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("Server forced to shutdown: ", err)
	}

	log.Println("Server exiting")
}
```

## 函数式选项模式

函数式选项模式：Functional Options Pattern，是 Golang 中一种常用的设计模式，用于解决构造函数参数过多的问题。

示例：

```go
package main

func main() {
	NewServer("test", SetHost("localhost"), SetPort(8081))
}

type Server struct {
	Label string
	Host  string
	Port  int32
}

func NewServer(label string, opts ...func(s *Server)) *Server {
	s := &Server{
		Label: label,
	}

	for _, opt := range opts {
		opt(s)
	}

	return s
}

type Option func(s *Server)

func SetHost(host string) Option {
	return func(s *Server) {
		s.Host = host
	}
}

func SetPort(port int32) Option {
	return func(s *Server) {
		s.Port = port
	}
}
```

## 调用 API

使用 Golang 调用 API 代码示例：

### Get

```golang
func GetApi() {
	resp, err := http.Get("https://baidu.com")
	if err != nil {
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	defer resp.Body.Close()
	fmt.Printf("Status: %s\n", resp.Status)
	fmt.Printf("StatusCode: %d\n", resp.StatusCode)

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	fmt.Printf("StatusCode: %s\n", string(body))
}
```

### Post

**1 简单 Post**

```go
func PostApi1() {
	json := `{"id":"u-001","name":"Jay","age":18}`
	resp, err := http.Post("https://example.com/user", "application/json", bytes.NewBuffer([]byte(json)))
	defer resp.Body.Close()
	
	fmt.Printf("Status: %s\n", resp.Status)
	fmt.Printf("StatusCode: %d\n", resp.StatusCode)
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	fmt.Printf("StatusCode: %s\n", string(body))
}
```

**2 附带 Header**

```go
func PostApi2() {
	// 1. json
	//json := `{"id":"u-001","name":"Jay","age":18}`
	//req, _ := http.NewRequest(http.MethodPost, "https://example.com/user", bytes.NewBuffer([]byte(json)))

	// 2. map
	reqBody, _ := json.Marshal(map[string]string{
		"id":   "u-001",
		"name": "Jay",
		"age":  "18",
	})
	req, _ := http.NewRequest(http.MethodPost, "https://example.com/user", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("My_Custom_Header", "Value")

	client := http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	defer resp.Body.Close()

	fmt.Printf("Status: %s\n", resp.Status)
	fmt.Printf("StatusCode: %d\n", resp.StatusCode)
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	fmt.Printf("StatusCode: %s\n", string(body))
}
```

**3 构造请求对象**

```go
type User struct {
	Id   string `json:"id"`
	Name string `json:"name"`
	Age  int    `json:"age"`
}

func PostApi3() {
	user := User{
		Id:   "u-001",
		Name: "Jay",
		Age:  18,
	}
	buf := new(bytes.Buffer)
	json.NewEncoder(buf).Encode(user)
	resp, err := http.Post("https://example.com/user", "application/json", buf)
	defer resp.Body.Close()

	fmt.Printf("Status: %s\n", resp.Status)
	fmt.Printf("StatusCode: %d\n", resp.StatusCode)
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	fmt.Printf("StatusCode: %s\n", string(body))
}
```

**4 OAuth2**

```go
// go get golang.org/x/oauth2
func getAccessToken()string{
	var authCfg = &clientcredentials.Config{
		ClientID:     "xxx",
		ClientSecret: "xxx",
		TokenURL:     "https://example.com/connect/token",
		EndpointParams: url.Values{
			"grant_type": {"client_credentials"},
		},
	}
	token, err := authCfg.TokenSource(context.Background()).Token()
	if err != nil {
		fmt.Errorf("get access token failed. ERROR: %s\n", err.Error())
	}
	return token.AccessToken
}
func OAuth2Api(){
	json := `{"id":"u-001","name":"Jay","age":18}`
	req, _ := http.NewRequest(http.MethodPost, "https://example.com/user", bytes.NewBuffer([]byte(json)))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Bearer", getAccessToken())

	client := http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	defer resp.Body.Close()

	fmt.Printf("Status: %s\n", resp.Status)
	fmt.Printf("StatusCode: %d\n", resp.StatusCode)
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	fmt.Printf("StatusCode: %s\n", string(body))
}
```

**5 上传文件**

```go
func FileApi(){
	file,err:=os.Open("hello.txt")
	if err!=nil{
		fmt.Errorf("ERROR: %s\n", err.Error())
	}

	defer file.Close()

	var reqBody bytes.Buffer
	multiPartWriter:=multipart.NewWriter(&reqBody)
	fileWriter,err:=multiPartWriter.CreateFormFile("file_field","hello.txt")
	if err!=nil{
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	
	_,err=io.Copy(fileWriter,file)
	if err!=nil{
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	
	fieldWriter,err:=multiPartWriter.CreateFormField("normal_field")
	if err!=nil{
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	
	_,err=fieldWriter.Write([]byte("value"))
	if err!=nil{
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	
	multiPartWriter.Close()
	
	req,err:=http.NewRequest(http.MethodPost,"http://example.com/file",&reqBody)
	if err!=nil{
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	req.Header.Set("Content-Type",multiPartWriter.FormDataContentType())
	
	client:=http.Client{}
	resp,err:=client.Do(req)
	if err!=nil{
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	defer resp.Body.Close()

	fmt.Printf("Status: %s\n", resp.Status)
	fmt.Printf("StatusCode: %d\n", resp.StatusCode)
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
	fmt.Printf("StatusCode: %s\n", string(body))
}
```

## 调用 Jenkins API

```go
package main

import (
	"fmt"
	"net/http"
	"strings"
)

type JenkinsConfig struct {
	User  string `json:"user"`
	Token string `json:"token"`
}

var jenkinsConf *JenkinsConfig

func main() {
    jenkinsConf := &JenkinsConfig{
        User: "xxx",
        Token: "xxxxxx"
    }
    job := "jenkins-job-1"
    disableJenkins(job)
}

func disableJenkins(job string) {
	// disabled jenkins job
	r, err := http.NewRequest(http.MethodPost, fmt.Sprintf("https://jenkins.example.com/job/%s/disable", job), nil)
	if err != nil {
		log.Errorf("new jenkins request failed: %s", err)
	}
	r.SetBasicAuth(jenkinsConf.User, jenkinsConf.Token)
	client := &http.Client{}
	resp, err := client.Do(r)
	if err != nil {
		log.Errorf("request failed: %s", err)
	}

	if resp.StatusCode == http.StatusOK {
		log.Healthf("disable jenkins job [%s] successfully", job)
	} else {
		log.Warnf("disable jenkins job [%s] status [%d]", job, resp.StatusCode)
	}
}
```

## 位运算

```go
package main

import "fmt"

func main() {
	/*
	位运算符：
		将数值，转为二进制后，按位操作
	按位&：
		对应位的值如果都为 1 才为 1，有一个为 0 就为 0
	按位|：
		对应位的值如果都是 0 才为 0，有一个为 1 就为 1
	异或^：
		二元：a^b
			对应位的值不同为 1，相同为 0
		一元：^a
			按位取反：
				1--->0
				0--->1
	位清空：&^
			对于 a &^ b
				对于 b 上的每个数值
				如果为 0，则取 a 对应位上的数值
				如果为 1，则结果位就取 0

	位移运算符：
	<<：按位左移，将 a 转为二进制，向左移动 b 位
		a << b
	>>: 按位右移，将 a 转为二进制，向右移动 b 位
		a >> b
	 */

	a := 60
	b := 13
	/*
	a: 60 0011 1100
	b: 13 0000 1101
	&     0000 1100
	|     0011 1101
	^	  0011 0001
	&^    0011 0000

	a : 0000 0000 ... 0011 1100
	^   1111 1111 ... 1100 0011
	 */
	fmt.Printf("a:%d, %b\n",a,a)
	fmt.Printf("b:%d, %b\n",b,b)

	res1 := a & b
	fmt.Println(res1) // 12

	res2 := a | b
	fmt.Println(res2) // 61

	res3 := a ^ b
	fmt.Println(res3) // 49

	res4 := a &^ b
	fmt.Println(res4) // 48

	res5 := ^a
	fmt.Println(res5)

	c:=8
	/*
	c : ... 0000 1000
	      0000 100000
	>>        0000 10
	 */
	res6 := c << 2
	fmt.Println(res6)

	res7 := c >> 2
	fmt.Println(res7)
}
```

## 实现简易网络连接客户端

实现类似 nc 的客户端命令工具：

```bash
$ nc www.baidu.com 80
GET / HTTP/1.1 
```

> 注意：需要连续两次回车，才会连接

废话少说，上代码：

*main.go*

```go
package main

import (
	"io"
	"log"
	"net"
	"os"
)

func main() {
	if len(os.Args) != 3 {
		log.Fatalln("Usage: nc [host] [port]")
	}

	host, port := os.Args[1], os.Args[2]

	c, err := net.Dial("tcp", host+":"+port)
	if err != nil {
		log.Fatalln(err)
	}

	go func() {
		io.Copy(c, os.Stdin)
	}()
	io.Copy(os.Stdout, c)
}
```

测试：

```bash
$ go build -o nc main.go
$ ./nc www.baidu.com 80
GET / HTTP/1.1
```

## git

```go
package gitutil

import (
	"fmt"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/transport/http"
	"os"
)

func Clone() {
    _, err := git.PlainClone("/var/app/ash", false, &git.CloneOptions{
        URL:           "https://github.com/poneding/ash.git",
		ReferenceName: plumbing.NewBranchReferenceName("master"),
		Auth: &http.BasicAuth{
			Username: "poneding",
			Password: "xxxxxx",
		},
		Progress: os.Stdout,
	})

	if err != nil {
		fmt.Errorf("ERROR: %s\n", err.Error())
	}
}
```

## elasticsearch

```go
package esutil

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/elastic/go-elasticsearch/v7"
	"strings"
)

func NewESClient2(esAddress []string) (*elasticsearch.Client, error) {
	if len(esAddress) == 0 {
		panic("Invalid parameters: esAddress.")
	}
	esConfig := elasticsearch.Config{Addresses: esAddress}
	esClient, err := elasticsearch.NewClient(esConfig)
	if err != nil {
		fmt.Errorf("GetESClient ERROR: %s\n", err)
		panic(err)
	}
	return esClient, nil
}

func QueryLogs2(esClient *elasticsearch.Client, query QueryLogModel) ([]LogModel, error) {
	var (
		buf bytes.Buffer
		r   map[string]interface{}
	)
	index := query.App + "-*"

	q := map[string]interface{}{
		"query": map[string]interface{}{
			"match_phrase": map[string]interface{}{
				"kubernetes.labels.app": query.App,
			},
		},
	}

	if err := json.NewEncoder(&buf).Encode(q); err != nil {
		fmt.Errorf("QueryLogs ERROR: %s\n", err)
		return nil, err
	}

	searchRes, err := esClient.Search(
		esClient.Search.WithIndex(index),
		esClient.Search.WithBody(&buf),
		esClient.Search.WithQuery(query.Filter),
		esClient.Search.WithFilterPath("hits.hits"),
		esClient.Search.WithSize(query.Size),
		esClient.Search.WithSort("@timestamp:desc"),
		esClient.Search.WithSource("@timestamp","level","log","msg"),
	)

	defer searchRes.Body.Close()
	if err != nil || searchRes.IsError() {
		fmt.Errorf("QueryLogs ERROR: %s\n", err.Error())
		return nil, errors.New(strings.Join([]string{"es.Search ERROR:", searchRes.Status(), err.Error()}, " "))
	}
	if err := json.NewDecoder(searchRes.Body).Decode(&r); err != nil {
		fmt.Errorf("QueryLogs ERROR: %s\n", err.Error())
		return nil, err
	}
	res := make([]LogModel, 0)

	for _, hit := range r["hits"].(map[string]interface{})["hits"].([]interface{}) {
		source := hit.(map[string]interface{})["_source"].(map[string]interface{})
		logModel := LogModel{
			Timestamp: source["@timestamp"].(string),
			Log:       source["log"].(string),
		}
		level, ok := source["level"]
		if ok {
			logModel.Level = level.(string)
		}
		log, ok := source["msg"]
		if ok {
			logModel.Log = log.(string)
		}
		res = append(res, logModel)
	}
	return res, nil
}
```

```go
package es

import (
	"context"
	"fmt"
	"github.com/olivere/elastic/v7"
	"reflect"
	"time"
)

func NewESClient(esAddresses []string) (*elastic.Client, error) {
	client, err := elastic.NewClient(elastic.SetSniff(false), elastic.SetURL(esAddresses...))

	if err != nil {
		fmt.Errorf("NewESClient ERROR: %s\n", err)
		panic(err)
	}

	return client, nil
}

func QueryLogs(esClient *elastic.Client, queryModel QueryLogModel) ([]LogModel, error) {
	res := make([]LogModel, 0)
	boolQuery := elastic.NewBoolQuery()
	index := queryModel.App + "-*"
	query := esClient.Search(index).FilterPath("hits.hits").Sort("@timestamp", false)

	if len(queryModel.Filter) > 0 {
		boolQuery.Filter(elastic.NewQueryStringQuery(queryModel.Filter))
	}

	if len(queryModel.Level) > 0 {
		boolQuery.Filter(elastic.NewMatchPhraseQuery("level", queryModel.Level))
	}

	if queryModel.Page <= 0 {
		queryModel.Page = 1
	}
	if queryModel.Size <= 0 {
		queryModel.Size = 50
	}
	query = query.From((queryModel.Page-1)*queryModel.Size + 1).Size(queryModel.Size)

	if queryModel.StartAt == (time.Time{}) {
		queryModel.StartAt = time.Now().Add(-15 * time.Minute).UTC()
	}
	if queryModel.EndAt == (time.Time{}) {
		queryModel.EndAt = time.Now().UTC()
	}
	boolQuery.Filter(elastic.NewRangeQuery("@timestamp").Gte(queryModel.StartAt).Lte(queryModel.EndAt))
	query = query.Query(boolQuery)

	queryRes, err := query.Do(context.Background())
	if err != nil {
		fmt.Errorf("QueryLogs ERROR: %s\n", err.Error())
		return res, err
	}

	for _, item := range queryRes.Each(reflect.TypeOf(LogModel{})) {
		if t, ok := item.(LogModel); ok {
			res = append(res, LogModel{
				Timestamp: t.Timestamp,
				Level:     t.Level,
				// Msg storing source log here.
				Log: t.Msg,
				Msg: t.Log,
				App: t.Kubernetes.Labels.App,
			})
		}
	}

	return res, nil
}

func QueryErrorLogs(esClient *elastic.Client) error {
	query := esClient.Search("dev-core-*").FilterPath("hits.hits").Sort("@timestamp", false).Size(100).Query(elastic.NewMatchPhraseQuery("level", "error"))

	queryRes, err := query.Do(context.Background())
	if err != nil {
		fmt.Errorf("QueryLogs ERROR: %s\n", err.Error())
	}

	for _, item := range queryRes.Each(reflect.TypeOf(LogModel{})) {
		if t, ok := item.(LogModel); ok {
			fmt.Println(t.Log)
		}
	}
	return nil
}
```
