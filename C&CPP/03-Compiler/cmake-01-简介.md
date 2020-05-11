# CMake简要学习

---

## 1 什么是 CMake

GNU Make、qmake 等Make 工具遵循着不同的规范和标准，所执行的 Makefile 格式也是不同的。所以如果软件想跨平台，必须要保证能够在不同平台编译。而如果使用这类 Make 工具，就得为每一种标准写一次 Makefile。这显然很低效，而 CMake 就是针对这个问题所设计的工具：它允许开发者编写一种平台无关的 CMakeList.txt 文件来定制整个编译流程，然后再根据目标用户的平台进一步生成所需的本地化 Makefile 和工程文件，从而做到“Write once, run everywhere”，所以 CMake 是一个比上述几种 Make 更高级的编译配置工具。总结 **CMake是一个开源，跨平台的工具系列，旨在构建，测试和打包软件**。

具体参考[make makefile cmake qmake 都是什么，有什么区别？](https://www.zhihu.com/question/27455963)。

---

## 2 示例与笔记

- 开发工具：Clion。
- Sample01：最简单的 Cmake 示例。
- Sample02：编译多个文件。
- Sample03：编译不同目录下的多个文件。
- Sample04：自定义编译选项。
- Sample05：构建时检查系统环境。

参考 [github](../Code/cmake-samples/README.md) 仓库

---

## 3 引用

### 官方文档

- [CMake官网教程](https://cmake.org/documentation/)
- [CMake Wiki](https://gitlab.kitware.com/cmake/community/-/wikis/home)
- [CMake_Useful_Variables](https://gitlab.kitware.com/cmake/community/-/wikis/doc/cmake/Useful-Variables)

### 学习资料

博客：

- 官方入门教程翻译：[CMake 入门实战](http://hahack.com/codes/cmake/)
- [cmake使用系列教程](https://juejin.im/post/5a6f32e86fb9a01ca6031230)
- [cmake 的正确打开方式](https://segmentfault.com/a/1190000015113987)
- [Android NDK 开发之 CMake 必知必会](https://juejin.im/post/5b9879976fb9a05d330aa206)

C/C++ 依赖管理：

- [Tutorial: Easy dependency management for C++ with CMake and Git](https://foonathan.net/blog/2016/07/07/cmake-dependency-handling.html)
- [C/C++ 依赖管理](http://www.oolap.com/cxx-dependency-management)
