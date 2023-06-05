# Jaeger

![presentation](https://pding.oss-cn-hangzhou.aliyuncs.com/images/jaeger-logo.a7093b12.svg)

## 前言

微服务之间的调用关系错综复杂，当你在京东下单时，应用背后的服务调用链可能超你想象。调用链的追踪是微服务绕不过去的技术栈，

## 简介

### 关于

Jaeger，受Dapper和OpenZipkin启发，由Uber开源的一个分布式跟踪系统，用于基于微服务分布式系统的监控和排错，包括：

- 分布式上下文传递
- 分布式事务监控
- 问题根由分析
- 服务依赖分析
- 性能、延迟优化

### 功能

- 兼容OpenTracing数据模型和工具库
- 对每个服务、端点使用一致的抽样概率
- 支持多样的后端数据库：Cassandra，Elasticsearch，Memory
- 追踪数据拓扑图形展示

## 基础概念

![Traces And Spans](https://pding.oss-cn-hangzhou.aliyuncs.com/images/spans-traces.png)

- **Span**

  跨度，是跨服务的一次调用。包含名称，开始时间和截止时间，Span之间可以并列，也可以嵌套。

- **Trace**

  是一次完成的分布式调用链，包含多个Span

### 技术规格

- 后端Go语言实现
- 前端React/Javascript
- 支持的数据库：Cassandra3.4+，Elasticsearch5.x+，Kafka...

### 组件介绍

![Architecture](https://pding.oss-cn-hangzhou.aliyuncs.com/images/architecture-v1.png)

- **jaeger-client**

  jaeger客户端，可以使用多种主流语言实现OpenTracing协议，将调用链数据收集到agent。

- **jaeger-agent**

  jaeger的代理程序，将收集到的client调用链数据上报到collector。

- **jaeger-collector**

  jaeger调用链数据收集器，对收集到的调用链数据进行校验，处理，存储到后端数据库。

- **jaeger-query**

  jaeger调用链数据查询服务，有独立UI。

## OpenTracing

分布式的追踪系统其实不止Jaeger一种，但是它们的核心原理都大相径庭，都是从入侵到代码中埋点，然后像追踪系统上报数据信息，最终我们在追踪系统得到数据，从而实现追踪分析。

为了兼容统一各追踪系统API，OpenTracing规范诞生了，它与平台无关，与厂商无关。有了它的存在，你可以方便的切换你想使用的追踪系统。

## 安装

### Docker

```bash
docker run -d --name jaeger \
  -e COLLECTOR_ZIPKIN_HTTP_PORT=9411 \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 14268:14268 \
  -p 14250:14250 \
  -p 9411:9411 \
  jaegertracing/all-in-one:1.20
```

### Kubernetes

**开发环境**

```bash
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-kubernetes/master/all-in-one/jaeger-all-in-one-template.yml
```

> 可能需要将文件下载下来，修改Deployment版本。

**生产环境**

>├── install-jaeger.sh
>├── jaeger-agent.yaml
>├── jaeger-cassandra.yaml
>├── jaeger-collector.yaml
>├── jaeger-configmap.yaml
>├── jaeger-persistent.yaml
>├── jaeger-query.yaml
>└── uninstall-jaeger.sh

## 示例

**DotNet Demo**

```bash
dotnet add package Jaeger --version 0.4.2
dotnet add package OpenTracing.Contrib.NetCore --version 0.6.2
```

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddControllers();
    services.AddOpenTracing();
    var httpOption = new HttpHandlerDiagnosticOptions();
    httpOption.IgnorePatterns.Add(req => req.RequestUri.AbsolutePath.Contains("/api/traces"));
    services.AddSingleton(Options.Create(httpOption));
    
    services.AddSingleton<ITracer>(serviceProvider =>
    {
        string serviceName = serviceProvider.GetRequiredService<IWebHostEnvironment>().ApplicationName;
        ILoggerFactory loggerFactory = serviceProvider.GetRequiredService<ILoggerFactory>();
        Configuration.SenderConfiguration senderConfiguration = new Configuration.SenderConfiguration(loggerFactory)
        .WithSender(new UdpSender("jaeger-agent", 6831, 0));

        var tracer = new Tracer.Builder(serviceName)
            .WithSampler(new ConstSampler(true))
            .WithReporter(new RemoteReporter.Builder().WithSender(senderConfiguration.GetSender()).Build())
             .Build();

        GlobalTracer.Register(tracer);

        return tracer;
    });
}
```

**Golang Demo**

```bash
go get github.com/uber/jaeger-client-go
go get github.com/opentracing/opentracing-go
```

```go
func main() {
	tracer, closer := initJaegerTracer("jaeger-api-go", "jaeger-agent.example.dev:6831")
	defer closer.Close()
	opentracing.InitGlobalTracer(tracer)

	http.HandleFunc("/api/values", TraceHandler(valuesHandler))
	http.ListenAndServe(":8082", nil)
}

func initJaegerTracer(serviceName, jaegerAgentAddr string) (opentracing.Tracer, io.Closer) {
	cfg := config.Configuration{
		Sampler: &config.SamplerConfig{
			Type:  jaeger.SamplerTypeConst,
			Param: 1,
		},
		Reporter: &config.ReporterConfig{
			LogSpans:           true,
			LocalAgentHostPort: jaegerAgentAddr,
		},
	}
	tracer, closer, err := cfg.New(serviceName, config.Logger(jaeger.StdLogger))

	if err != nil {
		log.Printf("ERROR: Could not initialize jaeger tracer: %s", err.Error())
	}

	return tracer, closer
}

func valuesHandler(w http.ResponseWriter, r *http.Request) {
	time.Sleep(2 * time.Second)
	fmt.Fprintf(w, "hello from jaeger-go.")
}

func TraceHandler(handler func(w http.ResponseWriter, r *http.Request)) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		spanName := r.URL.Path
		spanCtx, _ := opentracing.GlobalTracer().Extract(opentracing.HTTPHeaders, opentracing.HTTPHeadersCarrier(r.Header))
		span := opentracing.GlobalTracer().StartSpan(spanName, opentracing.ChildOf(spanCtx))

		span.SetTag(string(ext.Component), spanName)
		defer span.Finish()
		handler(w, r)
	}
}
```

```go
package jaeger_tracer

import (
	"github.com/opentracing/opentracing-go/ext"
	"io"
	"log"
	"net/http"

	"github.com/opentracing/opentracing-go"
	"github.com/uber/jaeger-client-go"
	"github.com/uber/jaeger-client-go/config"
)

type TraceHandler struct {
	OriginalHandler http.Handler
}

func (handler TraceHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	//spanName := runtime.FuncForPC(reflect.ValueOf(handler.OriginalHandler).Pointer()).Name()
	spanName := r.URL.Path
	spanCtx, _ := opentracing.GlobalTracer().Extract(opentracing.HTTPHeaders, opentracing.HTTPHeadersCarrier(r.Header))
	span := opentracing.GlobalTracer().StartSpan(spanName,opentracing.ChildOf(spanCtx))
	span.SetTag(string(ext.Component), spanName)
	defer span.Finish()

	handler.OriginalHandler.ServeHTTP(w, r)
}

func InitJaegerTracer(serviceName, jaegerAgentAddr string) (opentracing.Tracer, io.Closer) {
	cfg := config.Configuration{
		ServiceName: serviceName,
		Sampler: &config.SamplerConfig{
			Type:  jaeger.SamplerTypeConst,
			Param: 1,
		},
		Reporter: &config.ReporterConfig{
			LogSpans:           true,
			LocalAgentHostPort: jaegerAgentAddr,
		},
	}
	tracer, closer, err := cfg.NewTracer(config.Logger(jaeger.StdLogger))

	if err != nil {
		log.Printf("ERROR: Could not initialize jaeger tracer: %s", err.Error())
	}
	return tracer, closer
}

func TracerHandler(handler http.Handler) http.Handler {
	return jaeger_tracer.TraceHandler{
		OriginalHandler: handler,
	}
}
```

## 使用

