# 3 FFmpeg开发必备C语言回顾

## vim讲解

vim 的理念，尽量将手放在键盘上。

## c语言

c语言内存管理

![](images/04-c-memory.png)

c语言指针

![](images/04-c-pointer.png)

## 编译器

- gcc
- clang

```shell
gcc -g -O2 -o test test.c -I... -L.... -l
```

- -g 输出文件的调试信息
- -O 优化级别
- -o 输出文件
- -I 指定头文件位置，可以指定多个
- -L 指定库文件位置
- -l 指定使用哪个库

## 调试器

linux下使用 gdb。

1. 编译输出带调试信息的程序
2. 调试信息包含：指令地址、对于源代码和行号
3. 指令完成、回调

![](images/04-c-gdb.png)
