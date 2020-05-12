# Android NDK开发

---

## 1 NDK开发介绍

### NDK

Native Development Kit（生开发套件 NDK）是一系列工具的集合，让我们能够在 Android 应用中使用 C 和 C++ 代码，并提供了众多平台库。NDK 通过 JNI 技术实现 Java 层和 C/C++ 层的交互。

### JNI

Java Native Interface（JNI）标准是 java 平台的一部分，JNI 是Java 语言提供的 Java 和 C/C++ 相互沟通的机制，Java 可以通过 JNI 调用 C/C++ 代码，C/C++ 的代码也可以调用 java 代码。

### 为什么使用NDK

1. 项目需要调用底层的一些C/C++的一些东西（java无法直接访问到操作系统底层（如系统硬件等）），或者已经在C/C++环境下实现了功能代码（大部分现存的开源库都是用C/C++代码编写的。），直接使用即可。NDK开发常用于驱动开发、无线热点共享、数学运算、实时渲染的游戏、音视频处理、文件压缩、人脸识别、图片处理等。
2. 为了效率更加高效些。将要求高性能的应用逻辑使用C/C++开发，从而提高应用程序的执行效率。但是C/C++代码虽然是高效的，在java与C/C++相互调用时却增大了开销；
3. 基于安全性的考虑。防止代码被反编译，为了安全起见，使用C/C++语言来编写重要的部分以增大系统的安全性，最后生成so库（用过第三方库的应该都不陌生）便于给人提供方便。（任何有效的代码混淆对于会smail语法反编译你apk是分分钟的事，即使你加壳也不能幸免高手的攻击）
4. 便于移植。用C/C++写得库可以方便在其他的嵌入式平台上再次使用。

---

## 2 一些概念

### 编译

把一个源文件 源代码 翻译(编译)成一个二进制文件的过程。

### 链接

把编译生成的二进制，根据操作系统，根据当前处理器的类型．把这个二进制文件转化成一个真正可以执行的二进制文件。

### 交叉编译

使用交叉编译工具链在一个平台下(一种cpu的平台)编译出来另外一个平台(另一种cpu的平台)可以运行的二进制代码。

### 动态库，静态库

- 静态库 文件名.a   包含所有的函数并且函数运行的依赖，体积大，包含所有的API。
- 动态库 文件名.so  包含函数，不包含函数运行的依赖，体积小，运行的时候，去操作系统寻找需要的API。

### make

>维基百科：在软件开发中，make是一个工具程序（Utility software），经由读取叫做“makefile”的文件，自动化建构软件。它是一种转化文件形式的工具，转换的目标称为“target”；与此同时，它也检查文件的依赖关系，如果需要的话，它会调用一些外部软件来完成任务。它的依赖关系检查系统非常简单，主要根据依赖文件的修改时间进行判断。大多数情况下，它被用来编译源代码，生成结果代码，然后把结果代码连接起来生成可执行文件或者库文件。它使用叫做“makefile”的文件来确定一个target文件的依赖关系，然后把生成这个target的相关命令传给shell去执行。

---

## 3 NDK 开发方式

从 Android 初始版本到现在，NDK 的开发构建方式发送了很多变化，且这种变化一直在持续进行，下面列出了 Android 开发历史上出现过的 NDK 开发方式：

1. 使用使用 eclipse 开发。
2. 在AndroidStudio上，徒手编写 `Android.mk` 然后使用 ndk-build 编译，这种方式需要在`gradle.properties`中添加`android.useDeprecatedNdk = true`。
3. 使用 `gradle-experimental` NDK 插件进行开发，这个方式只是一个试验性功能，现在已经被废弃。
4. 使用 AndroidStudio2.2 及更高版本，这个版本增强了 C++ 的开发能力，能够使用 ndk-build 或 CMake 去编译和调试项目里的 C++ 代码，此时 AndroidStudio 用于构建原生库的默认工具是 CMake，但是仍然支持使用 ndkBuild。
   - 在`externalNativeBuild 中配置 ndkBuild`
   - 在`externalNativeBuild 中配置 cmake`
5. 使用独立工具链

### 使用 ndk-build

配置 Android.mk 和 Application.mk 文件，编写好相关代码，然后使用 ndk-build 命令进行编译。

示例：

```shell
ndk-build NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./jni/Application.mk NDK_LIBS_OUT=./jniLibs
```

- `NDK_PROJECT_PATH` 指定项目路径, 会自动读取这个目录下的 jni/Android.mk 文件
- `NDK_APPLICATION_MK` 指定 Application.mk 的位置
- `NDK_LIBS_OUT` 指定将生成的 .so 文件放到哪个目录，默认 Android Studio 会读取 jniLibs 目录下的 .so 文件, 所以我们把 .so 文件生成到这

关于 ndk-build 的命令选项可以通过`ndk-build -h`获取。

### 使用 cmake

这是目前默认的 NDK 开发方式，具体可参考官方文档。

### 关于 gcc 与 clang

- Android NDK从 r11 开始建议大家切换到 clang。并且把 GCC 标记为 deprecated，将 GCC 版本锁定在 GCC4.9 不再更新。
- Android NDK从 r13 起，默认使用 Clang 进行编译。

---

## 4 NDK工具包说明与示例

要对包含 C/C++ 代码的应用进行编译和调试原生代码，需要以下组件：

- Android 原生开发套件 (NDK)：这套工具使我们能在 Android 应用中使用 C 和 C++ 代码。（高版本的 NDK 已经默认包含了 CMake）
- CMake：一款外部编译工具，可与 Gradle 搭配使用来编译原生库。如果使用 ndk-build，则不需要此组件。（我们可以单独指定 Cmake 目录，也可以使用 NDK 工具包中自带的 Cmake 工具）
- LLDB：Android Studio 用于调试原生代码的调试程序。

下载 NDK，解压后发现其包含众多工具，下面是简要说明：

```shell
D:\dev_tools\android-ndk-r20-windows-x86_64\android-ndk-r20
λ ls
build/        ndk-build.cmd  ndk-which.cmd     platforms/        README.md      source.properties  toolchains/
CHANGELOG.md  ndk-gdb.cmd    NOTICE            prebuilt/         shader-tools/  sources/           wrap.sh/
meta/         ndk-stack.cmd  NOTICE.toolchain  python-packages/  simpleperf/    sysroot/
```

1. ndk-build: 该 Shell 脚本是 Android NDK 构建系统的起始点，一般在项目中仅仅执行这一个命令就可以编译出对应的动态链接库了。
2. ndk-gdb: 该 Shell 脚本允许用 GUN 调试器调试 Native 代码，并且可以配置到 AS 中，可以做到像调试 Java 代码一样调试 Native 代码。
3. ndk-stack: 该 Shell 脚本可以帮组分析 Native 代码崩溃时的堆栈信息。
4. build: 该目录包含 NDK 构建系统的所有模块。
5. platforms: 该目录包含支持不同 Android 目标版本的头文件和库文件， NDK 构建系统会根据具体的配置来引用指定平台下的头文件和库文件。
6. toolchains: 该目录包含目前 NDK 所支持的不同平台下的交叉编译器，包含 ARM 、X86、MIPS ，目前比较常用的是 ARM 。构建系统会根据具体的配置选择不同的交叉编译器。
7. sysroot：在比较老的 ndk 版本没有 sysroot 目录，这个目录存放的是系统库依赖的头文件，而老的版本则是在各平台下 usr 目录下有 include 目录。到后面比较新的版本就移到了 sysroot。

下面尝试在 Windows 平台徒手交叉编译出可以在 Android 平台运行的程序。

```c
//代码：
#include <stdio.h>
#include <stdlib.h>

int main()
{
    printf("Hello Android\n");
    return 0;
}

// 编译命令
android-sdk\ndk-bundle\toolchains\llvm\prebuilt\windows-x86_64\bin\clang.exe  --target=aarch64-none-linux-android21 --gcc-toolchain=D:/dev_tools/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/windows-x86_64 --sysroot=D:/dev_tools/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/windows-x86_64/sysroot C:\Users\Lenovo\Desktop\test.c
```

运行该命令后得到 a.out，将其 push 到 Android 设备上，添加可执行权限，然后运行即可输出"Hello Android"。

---

## 5 NDK开发学习内容

- c 与 c++ 语言
- 构建方式
  - ndk-build 方式
  - cmake 方式
- android 平台提供的本地 api
- native 异常分析与调试
- native 异常收集
- 引入第三方的本地库，例如 ffmpeg、opencv 机器应用。
