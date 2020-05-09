# GCC 学习

---

## 1 GCC 简介

GNU 编译器套装（英语：GNU Compiler Collection，缩写为GCC），指一套编程语言编译器，以 GPL 及 LGPL 许可证所发行的自由软件，也是 GNU 项目的关键部分，也是 GNU 工具链的主要组成部分之一。GCC（特别是其中的 C 语言编译器）也常被认为是跨平台编译器的事实标准。1985 年由理查德·马修·斯托曼开始发展，现在由自由软件基金会负责维护工作。原名为 GNU C 语言编译器（GNU C Compiler），因为它原本只能处理 C 语言。GCC 在发布后很快地得到扩展，变得可处理 C++。之后也变得可处理`Fortran、Pascal、Objective-C、Java、Ada，Go`与其他语言。

许多操作系统，包括许多类 Unix 系统，如 Linux 及 BSD 家族都采用 GCC 作为标准编译器。苹果电脑预装的 Mac OS X 操作系统也采用这个编译器。GCC 原本用 C 开发，后来因为 LLVM、Clang 的崛起，它更快地将开发语言转换为 C++。许多 C 的爱好者在对 C++ 一知半解的情况下主观认定 C++ 的性能一定会输给 C，但是 Taylor 给出了不同的意见，并表明 C++ 不但性能不输给C，而且能设计出更好，更容易维护的程序（GCC's move to C++）。

——[WIKI百科](https://zh.wikipedia.org/zh/GCC)

---

## 2 GCC命令简介

gcc 的语法为`gcc(选项)(参数)`，选项包括的类型非常多，比如：控制输出类型、警告压制类型、编译优化类型等等。

当调用 gcc 时，通常会进行**预处理，编译，汇编和链接**，使用 options（参数）可以在中间阶段停止这个过程。例如，`-c`选项表示不运行链接器。然后输出由汇编器输出的目标文件组成。选项被传递到一个或多个处理阶段，一些 options 控制预处理器，而其他的则控制编译器本身。还有其他选项控制汇编器和链接器。大多数可以与 gcc 一起使用的命令行选项对 C 程序很有用；但有些选项只对另一种语言有用。

运行 gcc 的通常方法是在交叉编译时运行名为 `gcc` 的可执行文件或者 `machine-gcc`，或者运行特定版本的GCC的 `machine-gcc` 版本。gcc 程序接受选项和文件名作为操作数。许多选项有多个字母的名字；因此多个单字母选项可能不会分组：`-dv`与`-d -v`是不同的。可以混合选项和其他参数。大多数情况下，参数使用的顺序无关紧要。当使用相同种类的多个选项时，顺序很重要，例如，如果多次指定`-L`，则按指定的顺序搜索目录。另外，`-l`选项的位置也很重要。很多选项都以`-f`或`-W`开头，例如，`-fmove-loop-invariants，-Wformat`等等。这些大多数都有正面和负面的形式; `-ffoo`的否定形式是`-fno-foo`。

具体的 GCC 命令可以参考相关文档：

- [gcc 手册](https://gcc.gnu.org/onlinedocs/)
- [gcc 手册-cn](http://www.shanghai.ws/gnu/gcc_1.htm)
- [gcc 手册-cn-pdf](http://www.mcu118.com/filedownload/5426)

### 2.1 示例：分解编译过程

一个C/C++文件要经过预处理(preprocessing)、编译(compilation)、汇编(assembly)、和连接(linking)才能变成可执行文件。

```shell
# 1、预处理
#   `-E`的作用是让gcc在预处理结束后停止编译。
#   预处理阶段主要处理 include 和 define 等。它把 #include 包含进来的 .h 文件插入到 #include 所在的位置，把源程序中使用到的用 #define 定义的宏用实际的字符串代替

​gcc -E main.c  -o main.i

# 2、**编译阶段**
#   `-S`的作用是编译后结束，编译生成了汇编文件。
#   在这个阶段中，gcc首先要检查代码的规范性、是否有语法错误等，以确定代码的实际要做的工作，在检查无误后，gcc把代码翻译成汇编语言。

gcc -S main.i -o main.s

# 3、**汇编阶段**
#   汇编阶段把 .s文件翻译成二进制机器指令文件.o,这个阶段接收.c, .i, .s的文件都没有问题。

gcc -c main.s -o main.o

# 4、**链接阶段**
#   链接阶段，链接的是**函数库**。在main.c中并没有定义”printf”的函数实现，且在预编译中包含进的”stdio.h”中也只有该函数的声明。系统把这些函数实现都被做到名为`libc.so`的动态库。

gcc -o main main.s
```

在 linux 系统中，在没有特别指定时，gcc 编译器只会使用 `/lib` 和  `/usr/lib` 这两个目录下的库文件。如果存在一个 so 不在这两个目录，在编译时候就会出现找不到的情况。`/etc/ld.so.conf`文件中可以指定额外的编译链接库路径。格式如下:

```shell
include /etc/ld.so.conf.d/*.conf #引入其他的conf文件
#增加库搜索目录
/usr/local/lib
```

编辑完成后，需要执行 `ldconfig` 命令更新。

### 2.2 示例：编译可执行文件

```Shell
#编译出一个名为 a.out 或 a.exe 的可执行程序
gcc test.c

#将 test.c 预处理、汇编、编译并链接形成可执行文件 test。-o选 项用来指定输出文件的文件名。
gcc test.c -o test
```

## 3 相关概念

### 静态库和动态库

- 静态库是指编译链接时，把库文件的代码全部加入到可执行文件中，因此生成的文件比较大，但在运行时也就不再需要库文件了。Linux中后缀名为 `.a`。
- 动态库与之相反，在编译链接时并没有把库文件的代码加入到可执行文件中，而是在程序执行时由运行时链接文件加载库。Linux中 后缀名为 `.so`。gcc在编译时默认使用动态库。

## 4 常用 options 说明

>JNI 中，Java 在不经过封装的情况下只能直接使用动态库。

### 4.1 常用选项

#### -o

`-o`：指定生成的输出文件。

#### -O

`-O`参数：程序优化参数

```Shell
#使用编译优化级别2编译程序。级别为1~3，级别越大优化效果越好，但编译时间越长
gcc test.c -O2
```

#### -g

`-g`：在编译时要加上`-g`选项，生成的可执行文件才能用gdb进行源码级调试，`-g`选项的作用是在可执行文件中加入源代码的信息，比如可执行文件中第几条机器指令对应源代码的第几行，但并不是把整个源文件嵌入到可执行文件中，所以在调试时必须保证gdb能找到源文件。

#### 使用c99标准编译

```shell
gcc -std=c99 hello.c
```

### 4.2 指定编译阶段

#### -c

`-c`：仅执行编译操作，不进行连接操作

```Shell
#将汇编输出文件 test.s 编译输出 test.o 文件
gcc -c test.s
#无选项链接，将编译输出文件 test.o 链接成最终可执行文件test
gcc test.o -o test
```

#### -E

`-E`：仅执行编译预处理

```Shell
#将test.c预处理输出test.i文件
gcc -E test.c -o test.i
```

#### -S

`-S`：将C代码转换为汇编代码

```Shell
#将预原文件test.c汇编成test.s文件
gcc -S test.c -o test.s
```

### 4.3 警告控制

#### -wall

`-wall`：允许发出 GCC 能够提供的所有有用的警告。也可以用 `-W{warning}` 来标记指定的警告

#### -Werror

`-Werror`：把所有警告转换为错误，以在警告发生时中止编译过程

#### -w

`-w` 关闭所有警告，建议不要使用此项(w是小写字母）

#### -Wl

`-Wl`：告诉编译器将后面的参数传递给链接器。

### 4.4 指定编译时，依赖的头文件与库链接位置

- `-l`和`-L`参数：用来指定程序要链接的库
  - `-l`参数紧接着就是库名，加入库名是`libA.so`，那么命令就是`-lA`
  - `-l`和`-L`的区别是，如果需要连接的第三方库在`/lib、/usr/lib、/usr/local/lib`下，那么只需要使用`-l`命令，如果不在这三个目录，就需要使用`-L`命令来指定全路径，比如`L/aaa/bbb/ccc -lA`。
- `-include`和`-I`参数：用来指定包含的头文件
  - `-include`用来包含头文件，但一般情况下包含头文件都在源码里用`#include`引入了，所以`-include`参数很少用。
  - `-I`参数是用来指定头文件目录，`/usr/include`目录一般是不用指定的，gcc可以找到，但是如果头文件不在`/usr/include`里就要用`-I`参数指定了，比如头文件放在`/myinclude`目录里，那编译命令行就要加上`-I/myinclude`参数，参数可以用相对路径，比如头文件在当前目录，可以用`-I.`来指定。
- `--sysroot=dir`：指定编译的头文件与库文件的查找目录，Linux 上默认在 `usr/include` 目录下查找，指定 dir 后，在 `dir/usr/include` 目录下查找。
- `-isysroot`，用于覆盖 `--sysroot=dir` 指令指定的头文件查找目录。

```shell
# 头文件查找目录
gcc -IXX

# 指定库文件查找目录
gcc -LXX -lxx.so
```

具体参考：

- [gcc：Directory-Options](https://gcc.gnu.org/onlinedocs/gcc/Directory-Options.html#Directory-Options)

### 4.5 动态库与静态库相关选项

#### -fPIC

`-fPIC`：属于“Options for Code Generation Conventions”类选项：`-fPIC`作用于编译阶段，告诉编译器产生与位置无关代码(Position-Independent Code)，则产生的代码中，没有绝对地址，全部使用相对地址，故而代码可以被加载器加载到内存的任意位置，都可以正确的执行。这正是共享库所要求的，共享库被加载时，在内存的位置不是固定的。

#### -shared

`-shared`参数，用于编译动态链接库。

```Shell
#将test.c 编译成动态链接库
`gcc -fPIC -shared test.c -o libTest.so`

#或者
gcc -fPIC -c test.c  #生成.o
gcc -shared test.o -o libTest.so
```

打包 .a 到 so：

```Shell
#--whole-archive: 将未使用的静态库符号(函数实现)也链接进动态库。
#--no-whole-archive : 默认，未使用不链接进入动态库。
gcc -shared -o libMain.so -Wl,--whole-archive libMain.a -Wl,--no-whole-archive
```

使用库：

```shell
#默认优先使用动态库
gcc main.c -L. -lTest -o main

#强制使用静态库
#最后的 -Bdynamic 表示默认仍然使用动态库
gcc main.c -L. -Wl,-Bstatic  -lTest -Wl,-Bdynamic -o main
# 使用动态库链接的程序，linux 运行需要将动态库路径加入 /etc/ld.so.conf
# mac(dylib) 和 windows(dll) 可以将动态库和程序(main)放在一起
# mac 中 gcc 会被默认链接到 xcode 的 llvm，不支持上面的指定链接动态库
```

### 4.6 多源文件的编译方法

- 1 多个文件一起编译：

```Shell
gcc testA.c testB.c -o test`
```

- 2 分开编译后再连接：

```Shell
#将testA.c编译成testA.o
gcc -c testA.c
#将testB.c编译成testB.o
gcc -c testB.c
#将testA.o和testB.o链接成test
gcc -o testA.o testB.o -o test
```

>关于多文件编译，推荐使用 makefile 或 cmake 等工具，这里只作演示。

### 4.7 C++ 相关

#### `-fno-elide-constructors`

适用于g++。C++语言因为各种临时对象的问题，所以编译器通常会自行进行优化，比如NRV优化（O0已存在该优化），会减少几次拷贝构造函数的调用过程。如果你想关闭这个优化，则可以使用该参数：

```shell
g++ -fno-elide-constructors hello.cpp
```

### 4.8 windows 相关

`-Wl,--add-stdcall-alias` 说明：

- `Wl`用于传递参数给连接器。
- `--add-stdcall-alias` 表示具有 stdcall 后缀的符号将按原样导出，并且也将删除后缀。因为 `dll` 中导出的函数签名与 VC 生成的不一致，需要加上编译参数。

windows 上编译

```Shell
#用于编译c代码生成.o库
gcc -c HelloC.c -I "H:\dev_tools\java8\include" -I "H:\dev_tools\java8\include\win32"

#把 .o 库转换成 windows平台的 dll库
gcc -Wl,--add-stdcall-alias -shared -o HelloC.dll HelloC.o

#直接生成 windows 平台的 .dll 库（等于上述两条命令）
gcc -Wl,--add-stdcall-alias -I "H:\dev_tools\java8\include" -I "H:\dev_tools\java8\include\win32" -shared -o helloC.dll HelloC.c
```

---

## 5 常见错误

`undefined reference to 'xxxxx'`：这是链接错误，不是编译错误，也就是说如果只有这个错误，说明程序源码本身没有问题，是用编译器编译时参数用得不对，没有指定链接程序要用到得库，比如程序里用到了某个函数属于`libm.so`库，那么就要在编译参数里指定程序要链接数学库，方法是在编译命令行里加入`-lm`

---

## 6 相关命令

`nm` 命令：显示二进制目标文件的符号表。

```shell
nm a.out

0000000000201010 B __bss_start
                 w __cxa_finalize@@GLIBC_2.2.5
0000000000201000 D __data_start
0000000000000680 t __do_global_dtors_aux
0000000000200db0 t __do_global_dtors_aux_fini_array_entry
0000000000201008 D __dso_handle
...
```
