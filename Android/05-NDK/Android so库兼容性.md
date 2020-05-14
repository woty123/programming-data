# Android 的 .so 文件

## cpu架构

Android系统目前支持以下七种不同的CPU架构：

- ARMv5，ARMv7 `从2010年起`
- x86 `从2011年起`
- MIPS `从2012年起`
- ARMv8，MIPS64和x86_64 `从2014年起`

每一种CPU架构都关联着一种ABI`application binary interface`，分别是：`armeabi，armeabi-v7a，x86，mips，arm64-v8a，mips64，x86_64`。

## 加载abi的方案

1. 静态加载：根据目前世面的 cpu 架构和各种架构之间的兼容情况，可以只使用一种 abi 架构，比如`arm-v7`
2. 动态加载 so 库

## 引用

- [为何大厂APP如微信、支付宝等只适配了armeabi-v7a/armeabi？](https://mp.weixin.qq.com/s/jnZpgaRFQT5ULk9tHWMAGg)
- [关于Android的.so文件你所需要知道的](http://www.jianshu.com/p/cb05698a1968)
- [Android的.so文件、ABI和CPU的关系](http://blog.csdn.net/xx326664162/article/details/51163905)
- [让APK只包含指定的ABI](http://blog.csdn.net/justfwd/article/details/49308199)
- [UnsatisfiedLinkError X.so is 64-bit instead of 32-bit之Android 64 bit SO加载机制](http://blog.csdn.net/canney_chen/article/details/50633982)
- [一个关于so库的大坑](https://zhuanlan.zhihu.com/p/21359984)
- [lib/arm64, /vendor/lib64 couldn't find " .so"](http://blog.csdn.net/qq_35599978/article/details/72722146)
