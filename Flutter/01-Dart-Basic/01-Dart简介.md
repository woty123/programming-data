# Dart 简介

## 1 Dart 简介

2011 年 10 月，在丹麦召开的 GOTO 大会上，Google 发布了一种新的编程语言 Dart。Dart 的目的是要解决 JavaScript存在的、在语言本质上无法改进的缺陷。

JavaScript 到底有哪些问题和缺陷？JavaScript之父布兰登 · 艾克（Brendan Eich）曾在一次采访中说：“JavaScript“几天就设计出来了”，其设计思路是：

- 借鉴 C 语言的基本语法
- 借鉴 Java 语言的数据类型和内存管理机制
- 借鉴 Scheme 语言，将函数提升到“第一等公民”（firstclass）的地位
- 借鉴 Self 语言，使用基于原型（prototype）的继承机制

因此：JavaScript 实际上是两类编程语言风格的混合产物：（简化的）函数式编程风格，与（简化的）面向对象编程风格。由于设计时间太短，一些细节考虑得不够严谨，导致后来很长一段时间，使用 JavaScript 开发的程序混乱不堪。出于对 JavaScript 的不满，Google 的程序员们决定自己写一个新语言来换掉它，所以 Dart 的最初定位也是一种运行在浏览器中的脚本语言。

>就目前来看，Dart 替换 javascript 的目标并未实现，后期 javascript 的发展超乎意料，Node.js 的出现让它开始有能力运行在服务端，很快手机应用与桌面应用也成为了 JavaScript 的宿主容器，一些明星项目比如 React、React Native、Vue、Electron、NW（node-webkit）等框架如雨后春笋般崛起，迅速扩展了它的边界。于是，JavaScript 成为了前后端通吃的全栈语言，前端的开发模式也因此而改变，进入了一个新的世界。

## 2 Dart 的现状

- Google 推出的移动开发框架 Flutter 使用 dart 语言。
- Google 未来的物联网错做系统 Fuchsia 将 Dart 指定为官方的开发语言。
- 著名的前端框架 Angular，除了常见的 TS 版本外，也在持续迭代对应的 Dart 版本AngularDart。

## 3 Dart 语言特性

- **JIT 与 AOT**：借助于先进的工具链和编译器，Dart 是少数同时支持JIT（Just In Time，即时编译）和 AOT（Ahead ofTime，运行前编译）的语言之一。
  - JIT 在运行时即时编译（比如 JavaScript/Python）
  - AOT 即提前编译（比如 C/C++）
- **内存分配与垃圾回收**：
  - Dart VM 的内存分配策略比较简单，创建对象时只需要在堆上移动指针，内存增长始终是线性的，省去了查找可用内存的过程。
  - 在 Dart 中，并发是通过 Isolate 实现的。Isolate 是类似于线程但不共享内存，独立运行的 worker。这样的机制，就可以让 Dart 实现无锁的快速分配。
  - Dart 的垃圾回收采用了多生代算法。
- **单线程模型**：Dart 中并没有线程，只有 Isolate（隔离区）。Isolates 之间不会共享内存，就像几个运行在不同进程中的worker，通过事件循环（Event Looper）在事件队列（Event Queue）上传递消息通信。

>Dart 新生代在回收内存时采用“半空间”机制（形式上有点类似 Java 的复制回收算法），触发垃圾回收时，Dart 会将当前半空间中的“活跃”对象拷贝到备用空间，然后整体释放当前空间的所有内存。回收过程中，Dart 只需要操作少量的“活跃”对象，没有引用的大量“死亡”对象则被忽略，这样的回收机制很适合 Flutter 框架中大量 Widget 销毁重建的场景。

## 4 Dart 的未来

一门语言是否能成功，不仅仅在于其本身的语言特色，更重要的是该语言的社区活力与生态建设，在 Dart 社区目前最顶级的产品就是 Flutter 和 Fuchsia 了，Dart 是否能够成功，目前来看主要取决于 Flutter 和 Fuchsia 能否成功。而，Flutter 是构建Fuchsia 的 UI 开发框架，因此这个问题也变成了 Flutter能否成功。
