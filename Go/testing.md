# testing

## 命令

测试

```bash
go test -run=TestCompare -v .
```

> 运行测试，测试函数名称中仅包含 `TestCompare` 前缀。

列出包内测试文件

```bash
go list -f={{.GoTestFiles}} .
```

列出包外测试文件

```bash
go list -f={{.XTestGoFiles}} .
```

> 包内测试：测试文件的包名称与被测包一致，可以访问被测包内所有成员，相当于白盒测试；
>
> 包外测试：测试文件的包名称与被测包不一致，一般在被测包名称后面添加 `_test` 后缀，只能访问被测包内公开成员，相当于黑盒测试。
