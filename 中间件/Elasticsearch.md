# Elasticsearch

全文搜索

## API

题外话：

幂等性：多次执行同样的请求，资源只能创建或修改一次

POST 请求不是幂等性的，同样的数据请求，会造成不同的影响

PUT 是幂等性的，同样的请求造成的影响是一样的

### 创建索引

```elasticsearch
PUT
/users
```

### 查询索引

获取单个索引

```elasticsearch
GET
/users
```

获取所有索引

```elasticsearch
GET
/_cat/indices?v
```

### 删除索引

```elasticsearch
DELETE
/users
```

### 创建文档

这个操作是在单个索引下的

```elasticsearch
POST
/users/_doc
# 一定需要body，否则报错
body:
{
  "name": "dp",
  "age": 18
}
```

上面这个文档创建时会生成随机 ID（返回结果中的 _id），不便维护，使用下面的方法自定义文档 ID，此时由于 ID 自定义了，就要求幂等，所以可以使用 PUT 方法

```elasticsearch
POST | PUT
/users/_doc/1002
PUT
/users/_create/1003
# 一定需要body，否则报错
body:
{
  "name": "dp",
  "age": 18
}
```

### 查询文档

获取单个文档

```elasticsearch
GET
/users/_doc/1001
```

获取所有文档

```elasticsearch
GET
/users/_search
```

### 修改文档

```elasticsearch
PUT
/users/_doc/1001
body:
{
  "name": "dp",
  "age": 28
}
```

你可能发现了，PUT 既可以创建也可以修改。

修改特定字段（非幂等）

```elasticsearch
POST
/users/_update/1001
body:
{
  "doc": {
    "age": 29
  }
}
```

### 删除文档

```elasticsearch
DELETE
/users/_doc/1001
```

## 复杂查询

### 条件查询

```elasticsearch
GET
/users/_search?q=name:dp
```

或者通过请求体查询

```elasticsearch
GET
/users/_search
{
	"query": {
		// "match": {
		// 	"name": "dp"
		// }
		// 查询所有
		"match_all": {
			
		}
	}
	// 分页
	"from": 0,
	"size": 10,
	// 过滤字段
	"_source": ["name", "age"]
	// 排序
	"sort": {
		"age": {
			"order": "asc|desc"
		}
	},
	"highlight": {
		"fields": {
			"name": {}
		}
	}
}
```

> 使用 match，如果查询条件是 "name": "Hello World"，查询结果会是 Hello，World 分别查询的结果集合，因为 ES 会将查询关键词拆解，每个单词都单独匹配索引。
>
> 如果香要完全匹配，使用 match_phrase。

### 多条件查询

```elasticsearch
GET
/users/_search
{
	"query": {
		"bool": {
			// must => and; should => or
			"must": [
				{
					"match": {
						"name": "dp"
					}
				},
				{
					"match": {
						"age": 28
					}
				}
			],
			"filter": {
				"range": {
					"age": {
						"gt": 18
					}
				}
			}
		}
	}
}
```

### 聚合查询

```elasticsearch
{
	"aggs": {	// 聚合操作
		"age_group": {	// 名称，随意命名
			"terms": {	// 分组
				"field": "age"	// 分组字段
			},
			"avg": {	// 平均值
				"field": "age"	// 分组字段
			}
			// 此外还有 max, min
		}
	},
	"size": 0 //不显示原始数据
}
```

## 设置

### 设置集群最大索引数

如果遇到错误：

```elasticsearch
Validation Failed: 1: this action would add [2] total shards, but this cluster currently has [3000]/[3000] maximum shards open;
```

那么导致该问题的原因可能是由于现创建的 index 太多，已经达到了 `cluster.max_shards_per_node` 的限制，需要计划清除一些无用的 index 或者增加es集群节点 index 限制：

```elasticsearch
PUT /_cluster/settings
{
  "transient":
  {
    "cluster.max_shards_per_node":5000
  }
}
```

或者使用 curl 调用集群设置的 api

```bash
curl -XPUT $CLUSTER_URL/_cluster/settings -H 'Content-type: application/json' --data-binary $'{"transient":{"cluster.max_shards_per_node":5000}}'
```

### 设置删除权限

删除权限需要

```elasticsearch
PUT /_cluster/settings
{
  "persistent" : {
    "action.destructive_requires_name" : "false"
  }
}
```

或者使用 curl 调用集群设置的 api

```bash
curl -XPUT $CLUSTER_URL/_cluster/settings -H 'Content-type: application/json' --data-binary $'{"persistent":{"action.destructive_requires_name":"false"}}'
```
