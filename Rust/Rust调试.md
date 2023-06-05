# Rust 0-1 调试

**VSCode**

```json
{
    "version":"0.2.0",
    "configurations":[
        {
            "type":"lldb",
            "request":"launch",
            "name":"Custom launch",
            "program":"${workspaceRoot}/target/debug/xxx",
            "cwd":"${workspaceRoot}"
        }
    ]
}
```

> `xxx` 替换成程序编译后的文件名。
