# C & CPP Interacting

C 与 C++ 混合编程，如果不做处理，会出现编译通过但链接时找不到函数或者直接编译不通过的情况。原因在于符号兼容性问题。

**符号兼容性**：C++ 支持函数重载，C 不支持函数重载，在编译后，C++ 的函数名会被修改，而 C 的函数名基本上不变，由于两者在编译后函数名的命名策略不同，所以在不处理的情况下，C 调用 C++ 的函数或者 C++ 调用 C 函数，都会在链接阶段报找不到函数的错误。

对于 `func` 函数 被 C 的编译器编译后在函数库中的名字可能为 `func`(无参数符号)，而 C++ 编译器则会产生类似`funcii`之类的名字。

```c
int func(int x,int y){

}

int main(){
    return 0;
}
```

上面代码分别命名为 `main.c / main.cpp`，接着分别进行编译，然后使用 `nm`(显示二进制目标文件的符号表) 命令查看程序的符号表：

```shell
gcc main.c -o mainc.o
gcc main.cpp -o maincpp.o

nm -A mainc.o
nm -A maincpp.o
```

main.c

![图1](images/C_Interact_CPP_mainc.png)

main.cpp

![maincpp](images/C_Interact_CPP_maincpp.png)

问题就在于： c的 .h 头文件中定义了 `func` 函数，则 .c 源文件中实现这个函数符号都是`func`，然后拿到 C++ 中使用，.h 文件中的对应函数符号就被编译成另一种，和库中的符号不匹配，这样就无法正确调用到库中的实现。

## 调用方式：`extern`

```c
//__cplusplus 是由c++编译器定义的宏，用于表示当前处于c++环境
#ifdef __cplusplus
extern "C"{
#endif
void func(int x,int y);
#ifdef __cplusplus
}
#endif
```

extern 关键字可用于变量或者函数之前，表示真实定义在其他文件，编译器遇到此关键字就会去其他模块查找。具体细节参考下面链接。

## 引用

- [NDK开发中C与C++互相调用处理](https://www.jianshu.com/p/49859d267567)
