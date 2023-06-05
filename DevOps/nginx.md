# nginx

## nginx简介

高性能的反向代理工具，负载均衡器；

## nginx配置

### 全局配置

### event配置

### http配置

#### 配置反向代理

**正向代理**

在国内是

配置location:

```
localtion [ = | ~ | ~* | ^~] uri {

}
```

- =：用于不包含正则表达式的url前，要求请求字符串与uri严格匹配；
- ~：用于表示uri包含正则表达式，并且区分大小写；
- ~*：用于表示uri包含正则表达式，并且不区分大小写；
- ^~：用于不包含正则表达式的uri前，要求nginx服务器找到表示ui和请求字符串匹配度最高的location后，立即使用此location处理请求

#### 配置负载均衡

将负载分摊到不同的服务单元，保证服务的快速响应，高可用。

![image-20200216174849571](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200216174849571.png)

```
upstream myserver {
	server	192.168.0.1:8081;
	server	192.168.0.2:8082;
}
server {
	listen	80;
	server_name	192.168.0.1;
	
	location / {
		proxy_pass	http://myserver;
		root		html;
		index		index.html index.htm;
	}
}
```

**均衡策略**

1. **轮询策略**

   nginx默认使用的均衡策略，按请求时间先后顺序逐一分配到后端服务器列表，如果某后端服务器down掉了，则自动剔除服务器列表。

2. **权重策略**

   后端服务器配置weight值，默认值为1，该值配置越大，则均衡到该服务器上的请求越多。

   ```
   upstream myserver {
   	server	192.168.0.1:8081 	weight=1;
   	server	192.168.0.2:8082	weight=2;
   }
   ```

3. **IP-Hash策略**

   根据请求客户端的IP 的hash值给其分配固定的某个服务器，可以解决session问题。

   ```
   upstream myserver {
   	ip_hash;
   	server	192.168.0.1:8081;
   	server	192.168.0.2:8082;
   }
   ```

4. **Fair策略**

   根据后端服务器的响应时间分配，响应时间短的优先分配。

   ```
   upstream myserver {
   	server	192.168.0.1:8081;
   	server	192.168.0.2:8082;
   	fair;
   }
   ```

#### 配置动静分离

静态服务器用于响应html、css、js、图片等静态资源的访问，动态服务器用于响应业务处理等。

```
	location /www/ {
		root		/data/;
		index		index.html index.htm;
	}
	
	location /image/ {
		root		/data/;
		autoindex 	on;			# 列出image目录下的静态文件
	}
```

![image-20200610124408207](https://pding.oss-cn-hangzhou.aliyuncs.com/images/image-20200610124408207.png)

## Nginx常用命令

### 重启

适用于修改了配置文件之后，重新加载

```bash
nginx -s reload
```

### 检查配置文件格式是否正确

```bash
# 检查默认配置文件 /etc/nginx/nginx.conf
nginx -t

# 检查指定配置文件
nginx -t -c /etc/nginx/conf.d/default.conf
```

