# 04-ndk调试与崩溃分析

## 0 参考文档

官方文档

1. [AndroidStudio：调试应用](https://developer.android.com/studio/debug?hl=zh-cn)
2. [NDK：调试项目](https://developer.android.com/ndk/guides/debug)
3. [调试 Android 平台原生代码](https://source.android.com/devices/tech/debug)

相关博客

1. [gityuan debug 原理分析](https://gityuan.com/tags/#debug)

## 1 调试

### 1.1 调试工具

- ndk-gdb：ndk 中提供的调试工具，用于进行源码调试，支持使用 ndk-build 方式构建的项目，现在普遍使用 cmake，所以推荐使用 lldb。
- lldb：AndroidStudio 中自带的调试，用于进行源码调试，使用比较简单。
- ndk-stack：根据日志信息分析出 c/c++ 代码的错误点。（支持开发阶段调试也支持线上使用日志上报后进行调试）
- Sanitizer：google 官方提供的用于检测 C/C++ 代码的 memory error 的工具。
- Native Tracing：对 C++ 代码进行跟踪分析，比如执行时间和效率等等。使用非常简单，仅需要依赖Android的 `#include <android/trace.h>` 头文件即可。但仅在 `Android API Level>=23` 才支持。用于在开发阶段优化代码逻辑，提升算法质量等。

### 1.2 lldb 和 ndk-gdb 的使用

- [ndk-gdb](https://developer.android.com/ndk/guides/ndk-gdb?hl=zh-cn) 参考
- [lldb](https://developer.android.com/studio/debug?hl=zh-cn) 参考

### 1.3 ndk-stack 、addr2line 等工具的使用

相关参考资料：

- [AndroidStudio：获取并阅读错误报告](https://developer.android.com/studio/debug/bug-report)：关于 adb bugreport 命令的使用。
- [NDK：ndk-stack工具](https://developer.android.com/ndk/guides/ndk-stack?hl=zh-cn)：关于 ndk-stack 工具的使用。
- [调试 Android 平台原生代码](https://source.android.com/devices/tech/debug)：关于 tombstone 文件结构。
- [Android NDK墓碑/崩溃分析](https://blog.csdn.net/lxb00321/article/details/74668383)

#### 1.3.1 日志变迁

1. 在旧版本的系统中，ndk 错误日志能完整地打印在控制台上，此时直接使用 `adb logcat` 命令重定向到 `ndk-stack` 即可进行分析，高版本系统中只会展示很少的日志信息，取而代之的是日志保存到 tombstone 文件，这类似 Linux 的信号处理函数会将崩溃的现场信息记录到核心文件一样。
2. tombstone 文件的路径为：`/data/tombstones/`，里面对应着不同序号的文件。在一些手机上可以直接将文件 pull 到 pc 上进行分析，而有一些手机却会展示权限不足，此时可以使用 `adb bugreport` 命令。

#### 1.3.2 使用示例

##### 获取 tombstone 文件

1：一段引发异常的代码

```c
JNIEXPORT void JNICALL Java_com_ztiany_jni_sample_JniBridge_triggerSignal(JNIEnv *jniEnv, jobject thiz) {
    int *a;
    *a = 10;
    LOGI("a = %d", *a);
}
```

2：触发异常后仅能从控制台得到部分信息：`com.ztiany.jni.sample A/libc: Fatal signal 11 (SIGSEGV) at 0x00000000 (code=1), thread 5244 (iany.jni.sample)`

3：尝试拉取 tombstone 文件，发现权限不足，于是使用`adb bugreport`命令获取日志

```shell
adb bugreport D:\android
```

4：获取到压缩文件后，解压得到日志文件：

```shell
#  tombstone 文件
│  ├─data
│  │  ├─anr
│  │  │      anr_xxx
│  │  │
│  │  └─tombstones
│  │          tombstone_00
│  │          tombstone_01
│  │          tombstone_02
│  │          tombstone_03
│  │          tombstone_04
│  │          tombstone_05
│  │          tombstone_06
│  │          tombstone_07
│  │          tombstone_08
│  │          tombstone_09
│  │

# 有很多 tombstone 文件，可以根据包名信息来确定是哪个文件，最终确定 tombstone_07 中报错了调试应用的奔溃信息

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
Build fingerprint: 'Xiaomi/umi/umi:10/QKQ1.191117.002/V11.0.20.0.QJBCNXM:user/release-keys'
Revision: '0'
ABI: 'arm64'
Timestamp: 2020-04-10 15:26:29+0800
pid: 24258, tid: 24258, name: iany.jni.sample  >>> com.ztiany.jni.sample <<<
uid: 10355
signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x10040140100401
    x0  4010040140100401  x1  0000007ff70628d4  x2  0000000000000000  x3  0000007e66571000
    x4  0000007ff7062d10  x5  0000007dd4c98b37  x6  685465766974616e  x7  0000000000000000
    x8  000000000000000a  x9  c592ca4408b3c4f0  x10 0000000000430000  x11 0000000000000060
    x12 0000000012d239d0  x13 000000000048ed40  x14 0000000000000006  x15 ffffffffffffffff
    x16 0000007e62ec58f0  x17 0000007dcfde35c8  x18 0000007e66c28000  x19 0000007e66571000
    x20 0000007de048b490  x21 0000007e66571000  x22 0000007ff7062b10  x23 0000007dd4c98b37
    x24 0000000000000004  x25 0000007e66726020  x26 0000007e665710b0  x27 0000000000000001
    x28 0000000000000000  x29 0000007ff70628b0
    sp  0000007ff7062890  lr  0000007dd4ad2990  pc  0000007dcfde35e4

backtrace:
      #00 pc 00000000000015e4  /data/app/com.ztiany.jni.sample-wOIiYmbC4_CKeOVbR0JGng==/lib/arm64/libnative-lib.so (Java_com_ztiany_jni_sample_JniBridge_triggerSignal+28) (BuildId: 5334d84cae79820b0b614eb21cf076c0465304f5)
      #01 pc 000000000000998c  /data/app/com.ztiany.jni.sample-wOIiYmbC4_CKeOVbR0JGng==/oat/arm64/base.odex (art_jni_trampoline+124)
      #02 pc 0000000000137334  /apex/com.android.runtime/lib64/libart.so (art_quick_invoke_stub+548) (BuildId: 112fa750f6a9adbd7b599e735b27a900)
      #03 pc 0000000000145fec  /apex/com.android.runtime/lib64/libart.so (art::ArtMethod::Invoke(art::Thread*, unsigned int*, unsigned int, art::JValue*, char const*)+244) (BuildId: 112fa750f6a9adbd7b599e735b27a900)
      ......

stack:
         0000007ff7062810  0000007de048b490  /apex/com.android.runtime/lib64/libart.so
         0000007ff7062818  0000007e66571000  [anon:libc_malloc]
         0000007ff7062820  0000007ff70628b0  [stack]
         0000007ff7062828  0000007de048b4bc  /apex/com.android.runtime/lib64/libart.so
         0000007ff7062830  0000007e665d9b80  [anon:libc_malloc]
         0000007ff7062838  0000007ff70628d4  [stack]
         0000007ff7062840  0000000000000000
         0000007ff7062848  0000007e66571000  [anon:libc_malloc]
         0000007ff7062850  0000007ff7062d10  [stack]
         0000007ff7062858  0000007dd4c98b37  /data/app/com.ztiany.jni.sample-wOIiYmbC4_CKeOVbR0JGng==/oat/arm64/base.vdex
         0000007ff7062860  685465766974616e
         0000007ff7062868  0000000000000000
         ......
```

找到对应的 tombstone 文件后，可以尝试使用 ndk-stack 或者 addr2line 工具进行分析，不过可以先来认识一下 tombstone 文件结构：

##### tombstone 文件结构

墓碑文件它主要由下面几部分组成：

- 构建指纹
- 崩溃的过程和PID
- 终止信号和故障地址
- CPU寄存器
- 调用堆栈
- 栈信息

构建指纹：

```log
Build fingerprint: 'Xiaomi/umi/umi:10/QKQ1.191117.002/V11.0.20.0.QJBCNXM:user/release-keys'
```

崩溃的过程和PID：

```shell
# pid 为进程id，tid 为线程id，如果pid等于tid，那么就说明这个程序是在主线程中Crash掉的，后面跟着的是进程包名。
pid: 24258, tid: 24258, name: iany.jni.sample  >>> com.ztiany.jni.sample <<<
```

终止信号和故障地址信息：

```shell
# 这里 SIGSEGV 是当一个进程执行了一个无效的内存引用，或发生段错误时发送给它的信号。非法地址为：0x10040140100401。
signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x10040140100401
    # 下面是进程奔溃时各寄存器的值，随着cpu的不同而不同
    x0  4010040140100401  x1  0000007ff70628d4  x2  0000000000000000  x3  0000007e66571000
    x4  0000007ff7062d10  x5  0000007dd4c98b37  x6  685465766974616e  x7  0000000000000000
    x8  000000000000000a  x9  c592ca4408b3c4f0  x10 0000000000430000  x11 0000000000000060
```

崩溃时函数调用堆栈信息：

```shell
# 调用栈信息是分析程序崩溃的非常重要的一个信息，它主要记录了程序在Crash前的函数调用关系以及当前正在执行函数的信息：
#       ## 00，＃01，＃02 ......等表示的都是函数调用栈中栈帧的编号，其中编号越小的栈帧表示着当前最近调用的函数信息，所以栈帧标号＃00表示的就是当前正在执行并导致程序崩溃函数的信息。
#       在栈帧的每一行中，pc后面的16进制数值表示的是当前函数正在执行语句的在共享链接库或者可执行文件中的位置，之后 libnative-lib.so 表示出错的 so。然后括号中展示的是当前栈帧所在函数。

backtrace:
      #00 pc 00000000000015e4  /data/app/com.ztiany.jni.sample-wOIiYmbC4_CKeOVbR0JGng==/lib/arm64/libnative-lib.so (Java_com_ztiany_jni_sample_JniBridge_triggerSignal+28) (BuildId: 5334d84cae79820b0b614eb21cf076c0465304f5)
      #01 pc 000000000000998c  /data/app/com.ztiany.jni.sample-wOIiYmbC4_CKeOVbR0JGng==/oat/arm64/base.odex (art_jni_trampoline+124)
      #02 pc 0000000000137334  /apex/com.android.runtime/lib64/libart.so (art_quick_invoke_stub+548) (BuildId: 112fa750f6a9adbd7b599e735b27a900)
      #03 pc 0000000000145fec  /apex/com.android.runtime/lib64/libart.so (art::ArtMethod::Invoke(art::Thread*, unsigned int*, unsigned int, art::JValue*, char const*)+244) (BuildId: 112fa750f6a9adbd7b599e735b27a900)
```

崩溃时栈信息

```shell
stack:
         #栈地址            栈内容
         0000007ff7062810  0000007de048b490  /apex/com.android.runtime/lib64/libart.so
         0000007ff7062818  0000007e66571000  [anon:libc_malloc]
         0000007ff7062820  0000007ff70628b0  [stack]
         0000007ff7062828  0000007de048b4bc  /apex/com.android.runtime/lib64/libart.so
         0000007ff7062830  0000007e665d9b80  [anon:libc_malloc]
```

##### 使用 addr2line 分析

addr2line 是 NDK 中用来获得指定动态链接库文件或者可执行文件中指定地址对应的源代码信息，它们位于 NDK 工具中的位置为：`$NDK_HOME\toolchains\aarch64-linux-android-4.9\prebuilt\windows-x 86_64\bin\aarch64-linux-android-addr2line.exe`。

使用示例：

```shell
# 这里我的手机 abi 架构是 arm64-v8a，所以选择这个目录下的 so 文件
# 进入交互模式
aarch64-linux-android-addr2line.exe -f -e \app\build\intermediates\cmake\deb ug\obj\arm64-v8a\libnative-lib.so

# 输入地址
00000000000015e4

# 即可得到结果
Java_com_ztiany_jni_sample_JniBridge_triggerSignal
D:\code\ztiany\notes\Android\Code\NDK\JNISample\app\src\main\cpp/native-lib.c:154
```

##### 使用 ndk-stack 分析

Android NDK自从版本 r6 开始，提供了一个工具 ndk-stack。这个工具能自动分析 tombstone 文件，能将崩溃时的调用内存地址和 c++ 代码一行一行对应起来。（ndk-stack 其实是个 python 脚本，且需要 2.x 版本）：

```shell
# 这里我的手机 abi 架构是 arm64-v8a，所以选择这个目录
 ndk-stack -sym .\app\build\intermediates\cmake\debug\obj\arm64-v8a\ -dump D:\linux\bugreport-umi-QKQ1.191117.002-2020-04-10-15-38-44\FS\data\tombstones\tombstone_07 >analysis.txt
```

得到结果，从分析结果后可以看出问题出在`native-lib.c` 文件第 154 行：

```log
********** Crash dump: **********
Build fingerprint: 'xxx/release-keys'
pid: 24258, tid: 24258, name: iany.jni.sample  >>> com.ztiany.jni.sample <<<
signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x10040140100401
Stack frame       #00 pc 00000000000015e4  /data/app/com.ztiany.jni.sample-wOIiYmbC4_CKeOVbR0JGng==/lib/arm64/libnative-lib.so (Java_com_ztiany_jni_sample_JniBridge_triggerSignal+28) (BuildId: 5334d84cae79820b0b614eb21cf076c0465304f5): Routine Java_com_ztiany_jni_sample_JniBridge_triggerSignal at D:\code\ztiany\notes\Android\Code\NDK\JNISample\app\src\main\cpp/native-lib.c:154
Stack frame       #01 pc 000000000000998c  /data/app/com.ztiany.jni.sample-wOIiYmbC4_CKeOVbR0JGng==/oat/arm64/base.odex (art_jni_trampoline+124)
Stack frame       #02 pc 0000000000137334  /apex/com.android.runtime/lib64/libart.so (art_quick_invoke_stub+548) (BuildId: 112fa750f6a9adbd7b599e735b27a900)
Stack frame       #03 pc 0000000000145fec  /apex/com.android.runtime/lib64/libart.so (art::ArtMethod::Invoke(art::Thread*, unsigned int*, unsigned int, art::JValue*, char const*)+244) (BuildId: 112fa750f6a9adbd7b599e735b27a900)
Stack frame       #04 pc 00000000002e37cc  /apex/com.android.runtime/lib64/libart.so (art::interpreter::ArtInterpreterToCompiledCodeBridge(art::Thread*, art::ArtMethod*, art::ShadowFrame*, unsigned short, art::JValue*)+384) (BuildId: 112fa750f6a9adbd7b599e735b27a900)
Stack frame       #05 pc 00000000002dea2c  /apex/com.android.runtime/lib64/libart.so (bool art::interpreter::DoCall<false, false>(art::ArtMethod*, art::Thread*, art::ShadowFrame&, art::Instruction const*, unsigned short, art::JValue*)+892) (BuildId: 112fa750f6a9adbd7b599e735b27a900)
Stack frame       #06 pc 00000000005a681c  /apex/com.android.runtime/lib64/libart.so (MterpInvokeVirtual+648) (BuildId: 112fa750f6a9adbd7b599e735b27a900)
```

##### 其他工具：objdump、IDA Pro

objdump 可以在汇编层对崩溃原因进行分析。当然这要求开发人员了解一些 arm/x86 汇编知识。

### 1.4 Native tracing

参考：

- [原生跟踪](https://developer.android.com/ndk/guides/tracing)

### 1.5 sanitizers

参考：

- [sanitizers](https://github.com/google/sanitizers)
- [NDK：Address Sanitizer](https://developer.android.com/ndk/guides/asan?hl=zh-cn)

## 3 崩溃信息收集

### 3.1 参考资料

- [腾讯Bugly：Android 平台 Native 代码的崩溃捕获机制及实现](https://mp.weixin.qq.com/s/g-WzYF3wWAljok1XjPoo7w)
- [极客时间《Android开发高手课》-崩溃优化](https://time.geekbang.org/column/article/70602)
- [Android Native Crash 收集](https://www.kymjs.com/code/2018/08/22/01/)
- [xCrash](https://github.com/iqiyi/xCrash)
