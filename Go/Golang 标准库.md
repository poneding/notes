# Golang 标准库

## fmt

格式化打印

```tex
%v	原样输出
%T	打印类型
%t	bool
%s	string
%f	float
%d	10进制整数
%b	2进制整数
%o	8进制整数
%x	16进制整数 0-9，a-f
%X	16进制整数 0-9，A-F
%c	char
%p	pointer

%.2f	float 保留两位
```

## path

```go
file := "./logs/2021-01-25/error.log"
fileName := path.Base(file) # 返回文件名：error.log
fileExt := path.Ext(file)	# 返回文件后缀：.log
fileDir := path.Dir(file)	# 返回文件路径： ./logs/2021-01-25
```

## os/exec

Golang语言有一个包叫做 `os/exec`，使用该包可以直接在程序中调用主机的命令，使用示例如下：

```go
func OsExecUsage() error {
	fmt.Println("docker build...")
	cmd := exec.Command("docker", "build", "." ,"-t" ,"demo")
	// 实时打印输出
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Println("cmd.Output: ", err)
		return err
	}
	return nil
}
```
