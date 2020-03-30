# 《趣谈 Linux 系统》

对于服务器端，Unix-Like OS 占的比例近 70%，Android 内核基于 Linux，在编程世界中，Linux 就是主流，不会 Linux 你就会格格不入。

## 0 带着问题去学习

![it00_questions1](images/it00_questions1.jfif)
![it00_questions2](images/it00_questions2.jfif)
![it00_questions3](images/it00_questions3.jfif)
![it00_questions4](images/it00_questions4.jfif)

## 0 学习 Linux 的 6 个阶段

1. 抛弃旧的思维习惯，熟练使用 Linux 命令行，从 Windows 的思维习惯，切换成 Linux 的“命令行 + 文件”使用模式。
   1. 《鸟哥的 Linux 私房菜》
   2. 《Linux 系统管理技术手册》
2. 通过系统调用或者 glibc，学会自己进行程序设计。
   1. 《UNIX 环境高级编程》
3. 了解 Linux 内核机制，反复研习重点突破
   1. 《深入理解 LINUX 内核》
4. 阅读 Linux 内核代码，聚焦核心逻辑和场景
   1. 《LINUX 内核源代码情景分析》
5. 实验定制化 Linux 组件
6. 面向真实场景的开发

![it00_steps](images/it00_steps.jfif)

相关学习资料：

- 第一步：
  - [别出心裁的Linux命令学习法](https://www.cnblogs.com/rocedu/p/4902411.html)
- 第二步：
  - 先读《Unix/Linux编程实践教程》，再读 《UNIX 环境高级编程》。
  - [别出心裁的Linux系统调用学习法](https://www.cnblogs.com/rocedu/p/6016880.html)
- 第三步：
  - 《庖丁解牛Linux内核分析》

## 1 把Linux内核当成一家软件外包公司的老板

操作系统其实就像一个软件外包公司，其内核就相当于这家外包公司的老板。

- **计算机硬件**：包括 CPU、主板、网卡、显卡、硬盘、鼠标、键盘、显示器等，但是光有这些还不够，还需要操作系统。
- 操作系统究竟是如何把这么多套复杂的东西管理起来？这其中包括：
  - **文件管理子系统**：硬盘是个物理设备，要按照规定格式化成为文件系统，才能存放这些程序。文件系统需要一个系统进行统一管理，称为文件管理子系统（File Management Subsystem）。
  - **系统调用**：打印机的直接操作是放在操作系统内核里面的，进程不能随便操作。但是操作系统也提供一个办事大厅，也就是系统调用（System Call）。
  - **进程管理子系统**：在操作系统中，进程的执行也需要分配 CPU 进行执行，也就是按照程序里面的二进制代码一行一行地执行。于是，为了管理进程，我们还需要一个进程管理子系统（Process Management Subsystem）。如果运行的进程很多，则一个 CPU 会并发运行多个进程，也就需要 CPU 的调度能力了。
  - **内存管理子系统**：在操作系统中，不同的进程有不同的内存空间，但是整个电脑内存就这么点儿，所以需要统一的管理和分配，这就需要内存管理子系统（Memory Management Subsystem）。
- 程序的的二进制文件是静态的，称为程序（Program），而运行起来的程序，是不断进行的，称为进程（Process）。

外包公司与操作系统对应理解：

![subsystem](images/it01-os-subsystem.jfif)

操作系统全貌：

![subsystem](images/it01-whole-subsystem.jfif)

## 2 命令行

![it02-command](images/it02-command.jfif)

## 3 系统调用
