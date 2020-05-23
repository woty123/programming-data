# NDK 学习

## 1 学习资料

### 前置知识

- C/C++ 语言
- [JNI笔记1](JNI笔记-1.md)
- [JNI笔记2](JNI笔记-2.md)

### 官方文档

- [NDK 入门指南](https://developer.android.com/ndk/guides/index.html)
- [NDK WIKI](https://github.com/android/ndk)
- [NDK 版本修订记录](https://developer.android.com/ndk/downloads/revision_history)
- [向您的项目添加 C 和 C++ 代码](https://developer.android.com/studio/projects/add-native-code.html)

### NDK 入门教程

- [JNI/NDK开发指南](https://blog.csdn.net/xyang81/column/info/blogjnindk)
- [Android NDK——必知必会](https://blog.csdn.net/CrazyMo_/article/details/82345001)
- [Android NDK 从入门到精通](https://blog.csdn.net/afei__/article/details/81290711)

比较老的教程：

- [Mastering Android NDK Build System - Part 1: Techniques with ndk-build](http://web.guohuiwang.com/technical-notes/androidndk1)
- [Mastering Android NDK Build System - Part 2: Standalone toolchain](http://web.guohuiwang.com/technical-notes/androidndk2)

### 示例代码

- [googlesamples/android-ndk](https://github.com/googlesamples/android-ndk)：作为 Google 官方 NDK 开发 Samples，该项目非常重要，注意：该项目包含多个分支。

### 书籍

《Android C++高级编程：使用NDK》

### 库

- [xHook](https://github.com/iqiyi/xHook/blob/master/README.zh-CN.md)：xHook 是一个针对 Android 平台 ELF (可执行文件和动态库) 的 PLT (Procedure Linkage Table) hook 库。
- [JNA](https://github.com/java-native-access/jna)：可以帮助 Java 方便快速的访问 native 层代码。
- [NDK Maping](http://cdn2.jianshu.io/p/bdce346aef85)

### 高级教程

菜鸟窝（付费）：

- [Android 音视频高级开发工程师-菜鸟窝](https://www.cniao5.com/class/android/ysp)
- [JNI与NDK全面剖析与实战-菜鸟窝](https://www.cniao5.com/course/10284)

### NDK应用

- [OpenCV教程](http://c.biancheng.net/opencv/)

## 2 学习路径

1. C/C++ 语言
2. 编译：`gcc`、`clang`
3. JNI
4. Android NDK 开发
   1. ndk-build、cmake 构建方式
   2. 原生 API
5. 第三方库集成与开发
