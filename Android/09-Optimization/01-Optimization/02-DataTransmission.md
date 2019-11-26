# 数据传输优化

数据的序列化是程序代码里面必不可少的组成部分，当我们讨论到数据序列化的性能的时候，需要了解有哪些候选的方案，它们各自的优缺点是什么。数据序列化的行为可能发生在数据传递过程中的任何阶段，例如网络传输，不同进程间数据传递，不同类之间的参数传递，把数据存储到磁盘上等等。

数据传输方案：

- **xml**：使用标签和熟悉描述数据，数据比较冗余。
- **Json**：目前移动端广泛采用的数据传输方式，使用字符串作为载体，操作方便。性能较差。
- **Protocal Buffers**：强大，灵活，但是对内存的消耗会比较大，并不是移动终端上的最佳选择。
- **Nano-Proto-Buffers**：基于 Protocal，为移动终端做了特殊的优化，代码执行效率更高，内存使用效率更佳。
- **FlatBuffers**：这个开源库最开始是由Google研发的，专注于提供更优秀的性能。

## 1 Json

Json 是目前使用最广泛的数据传输格式，移动端一般使用 Gson 作为 Json 的序列化和反序列工具。

具体参考：

- [gson 官方Examples](https://sites.google.com/site/gson/gson-user-guide#TOC-Primitives-Examples)
- [你真的会用Gson吗?Gson使用指南（一）](http://www.jianshu.com/p/e740196225a4)
- [你真的会用Gson吗?Gson使用指南（二）](http://www.jianshu.com/p/c88260adaf5e)
- [你真的会用Gson吗?Gson使用指南（三）](http://www.jianshu.com/p/0e40a52c0063)
- [你真的会用Gson吗?Gson使用指南（四）](http://www.jianshu.com/p/3108f1e44155)

## 2 Protobuf

Protobuf 是 google 开源项目。序列化数据结构的方案，通常用于编写需要数据交换或者需要存储数据的程序。这套方案包含一种用于描述数据结构的接口描述语言（Interface Description Language）和一个生成器，用于生成描述该数据结构的不同编程语言的源代码。

具体参考：

- [protobuf-GitHub](https://github.com/google/protobuf)
- [Google_developers_protocol-buffers](https://developers.google.com/protocol-buffers/)

## 3 FlatBuffers

FlatBuffers 是一个开源的跨平台数据序列化库，可以应用到几乎任何语言（C++, C#, Go, Java, JavaScript, PHP, Python），最开始是 Google 为游戏或者其他对性能要求很高的应用开发的。相对于 Protocol Buffers（简称PB），FB不需要解析，只通过序列化后的二进制 buffer 即可完成数据访问。

### 优点

1. 直接读取序列化数据，而不需要解析（Parsing）或者解包（Unpacking）：FlatBuffer 把数据层级结构保存在一个扁平化的二进制缓存（一维数组）中，同时能够保持直接获取里面的结构化数据，而不需要解析，并且还能保证数据结构变化的前后向兼容。
2. 高效的内存使用和速度：FlatBuffer 使用过程中，不需要额外的内存，几乎接近原始数据在内存中的大小。
3. 灵活：数据能够前后向兼容，并且能够灵活控制你的数据结构。
4. 很少的代码侵入性：使用少量的自动生成的代码即可实现。
5. 强数据类性，易于使用，跨平台，几乎语言无关。

### 与JSON对比

JSON是目前常用的数据序列化技术，可读性强，但是序列化和反序列化性能却相对较差，由于使用字符串作为数据载体，从序列化到反序列化需要经历很多个步骤。解析的时候，容易**造成 Java 虚拟机的 GC 和内存抖动**。而FlatBUffers直接使用二进制作为数据载体，避免了很多转换的步骤。

### 缺点

1. FlatBuffers需要生成代码，对代码有一定的侵入性
2. 数据序列化后是二进制的，没有可读性
3. 构建FlatBuffers对象比较麻烦

### 引用

- [flatbuffers-GitHub](https://github.com/google/flatbuffers)
- [FlatBuffers 体验](http://www.race604.com/flatbuffers-intro/)
- [FlatBuffers使用简介](http://www.jianshu.com/p/6eb04a149cd8)
- [FlatBuffers 介绍](https://github.com/xitu/gold-miner/blob/master/TODO/flatbuffers-in-android-introdution.md)

## 4 xml

XML 一开始就不是为网络传输设计的，现在 xml 也较少用于数据传输，解析 xml 的框架有很多，比如 [XStream](http://x-stream.github.io/)。
