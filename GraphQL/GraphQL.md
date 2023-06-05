# Graphql

https://graphql.cn/learn/

## 介绍

一种 API 查询语言，也是一种满足使用现有数据完成几乎所有数据查询的运行时。

对 API 数据提供可理解的完整描述，赋予客户端准确获取所需数据，使得 API 的演进更加轻松，也可以使用它来构建强大的开发者工具（LowCode?）。

### 特性

**所得即所取**

请求什么，返回什么，因为总是根据你请求的结构返回可预见的结果。

**单取多得**

单次请求，返回多种结构的数据，不仅对资源属性查询，而且还会沿着资源的引用关系进一步查询。

这也是对比 Restful API 的一种优势，Restful API 对多资源的查询时，往往需要多次访问不同的API，这无疑增加了网络连接的压力。

**类型系统描述所有**

GraphQL API 基于类型和字段的方式进行组织，而非入口端点。你可以通过一个单一入口端点得到你的访问数据的所有能力。GraphQL 使用类型来保证应用只请求可能的数据，否则会提供了明确的有用的错误信息。应用也可以使用类型，而避免编写手动解析代码。

**API无版本**

API 演进只需要往 Graphql 类型系统中添加字段和类型，而不影响现有查询。

**统一共享**

GraphQL 让你的整个应用共享一套 API，而不用被限制于特定存储引擎。GraphQL 引擎已经有多种语言实现，通过 GraphQL API 能够更好利用你的现有数据和代码。你只需要为类型系统的字段编写函数，GraphQL 就能通过优化并发的方式来调用它们。

### 资源定义，请求和响应

**数据描述**

```graphql
type User {
  name: String
  phone: String
  Friends: [User]
}
```

**数据请求**

```graphql
{
  user(name: "dp") {
    phone
  }
}
```

**请求结果**

```json
{
  "user": {
    "phone": "18800001111"
  }
}
```

## 变量

变量前缀必须为 `$`，后跟其类型，例如：`$user User`

变量必须是标量，枚举型或输入对象类型。

如果类型后没有跟 `!`，说明变量是可选的，可以不传入参数，否则必须出传入。

**默认变量**

```graphql
query HeroNameAndFriends($episode: Episode = "JEDI") {
  hero(episode: $episode) {
    name
    friends {
      name
    }
  }
}
```

## GraphQLite

是一个为 GraphQL schema 定义提供基于注释的语法的库。 它与框架无关，可用于 Symfony 和 Laravel。

## Schema

## 文档

learn：https://graphql.cn/learn/

code：https://graphql.org/code/

awesome-graphql：https://github.com/chentsulin/awesome-graphql
