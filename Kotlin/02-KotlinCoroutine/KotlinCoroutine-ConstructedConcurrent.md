# KotlinCoroutine-ConstructedConcurrent

## 1 并发程序遇到的问题

对于异步编程，始终都存在异步任务管理与协同的问题，比如：

- 这个 task 什么时候开始，什么时候结束，如何精确控制 task 的启动与结束？
- 怎么做到当所有 subtask 都结束，main task再结束？
- 假如某个 subtask 失败，main task 如何cancel 掉其他subtask？
- 如何保证所有 subtask 在某个特定的超时时间内返回，无论它成功还是失败？
- 更进一步，如何保证 main task 在规定的时间内返回，无论其成功还是失败，同时 cancel 掉它产生的所有 subtask？
- main task 已经结束了，subtask 还在 running，是不是存在资源泄漏？

Kotlin Coroutine 也一样：`当我们使用 GlobalScope.launch 时，我们会创建一个顶层协程。虽然它很轻量，但它运行时仍会消耗一些内存资源。如果我们忘记保持对新启动的协程的引用，它还会继续运行。如果协程中的代码挂起了会怎么样（例如，我们错误地延迟了太长时间），如果我们启动了太多的协程并导致内存不足会怎么样？ 必须手动保持对所有已启动协程的引用并 join 之很容易出错。`

Kotlin 采用结构化并发来解决这些问题，具体到 API 就是 CoroutineScope。CoroutineScope 定义创建协程的范围。每个协程构建器（比如 launch、async）都是 CoroutineScope 的扩展，并继承其 coroutineContext 以自动传播上下文元素和取消（取消行为，当 CoroutineScope 被取消，由其发起的协程都将被取消）。即 Kotlin 使用 CoroutineScope 来管理协程。

## 2 什么是结构化并发

[Structured Concurrency Kickoff](https://trio.discourse.group/t/structured-concurrency-kickoff/55) 中，有关于 Structured Concurrency 的讨论：

**结构化并发是结构化编程范式的一个扩展（goto 语句被认为是有害的），被引入到并发编程领域，广义地来说，主要的意思就是屏幕上的程序代码的物理布局应该与它的执行流程相一致（在时间上），当你违背了这个原则，正如 Dijkstra 所说的，你将会获得丑陋的意大利面条样的代码。特别是对结构化并发，它意味着一个线程的一生（这里用线程宽泛地表示进程、协程等概念）是绑定在特定的语法结构上的，通常是一个作用域扩展代码块**。

下面给定一个可能最简单的实例，当一个代码块退出时，一个线程可能自动地被取消。

```kotlin
{
    ...
    go foo()
    ...
} // foo gets canceled here
```

这里有许多不同的方式来说明为什么结构化并发是可取的，最简单的一个就是去注意到，对如正如我们今天所了解到的线程，甚至都不提供最轻量级封装担保，你调用一个方法，然后一旦它返回你会认为它已经完成了，但是你不知道的是它已经启动了一个后台线程，这个线程依然在运行并且在产生危害，因为线程转变的特性，这个问题是特别在糟糕的，对于去找到哪个函数启动了一个线程，仅仅检查这个函数的代码无法满足的，你去要检查每一个的单一的依赖，每一个依赖的依赖等等。[Notes on structured concurrency, or: Go statement considered harmful](https://vorpus.org/blog/notes-on-structured-concurrency-or-go-statement-considered-harmful/) 一文详尽地探讨了结构化并发，如果你对结构化并发不是很了解，而你想去读一篇文章来了解它，这一片文章无疑是最好的选择。

结构化并发的历史：

1. 2016年，ZerMQ 的作者 Martin Sústrik 在他的文章中第一次形式化的提出结构化并发这个概念。
2. 2018 年 Nathaniel J.Smith (njs) 在 Python 中实现了这一范式-trio，并在 Notes on structured concurrency, or: Go statement considered harmful 一文中进一步阐述了 Structured Concurrency。同时期，Roman Elizarov 也提出了相同的理念，并在 Kotlin 中实现了 kotlinx.coroutine。
3. 2019年，OpenJDK loom project 也开始引入 structured concurrency，作为其轻量级线程和协程的一部分。

[解决并发编程之痛的良药--结构化并发编程](https://zhuanlan.zhihu.com/p/108759542) 中说到：**Structured Concurrency 核心在于通过一种 structured 的方法实现并发程序，用具有明确入口点和出口点的控制流结构来封装并发“线程”（可以是系统级线程也可以是用户级线程，也就是协程，甚至可以是进程）的执行，确保所有派生“线程”在出口之前完成**。结合上面 `对结构化并发，它意味着一个线程的一生（这里用线程宽泛地表示进程、协程等概念）是绑定在特定的语法结构上的，通常是一个作用域扩展代码块`，我感觉结构化并发把穿传统的异步、回调的并发实现方式，转换回普通的同步代码一样，每个调用都用明确的开始与结束，不用考虑是否还有其他执行流在后台运行，这样就可以避免很多因为大意或者疏忽而产生的异步 bug，要知道传统的异步任务管理与协同工作是非常复杂的，要不 JDK 也不会在 juc 中整出这么多并发框架来对应各种并发需求。

## 3 如何使用 Kotlin 结构化并发

[在 Android 开发中使用协程 | 上手指南](https://mp.weixin.qq.com/s/kPvWOCkMjYRKJSTX4I5VKg) 一文中，详细介绍了如果正式使用 kotlin coroutine 以实现结构化并发。

## 4 references

- [解决并发编程之痛的良药--结构化并发编程](https://zhuanlan.zhihu.com/p/108759542)
- [Structured Concurrency Kickoff](https://trio.discourse.group/t/structured-concurrency-kickoff/55)
- [Kotlin 结构化的并发](https://www.kotlincn.net/docs/reference/coroutines/basics.html#%E7%BB%93%E6%9E%84%E5%8C%96%E7%9A%84%E5%B9%B6%E5%8F%91)
- [Kotlin 、协程、结构化并发](https://juejin.im/post/5cdfeab0f265da1bb13f0160)
- [Notes on structured concurrency, or: Go statement considered harmful](https://vorpus.org/blog/notes-on-structured-concurrency-or-go-statement-considered-harmful/)

进一步了解各种异步编程实现利弊，参考 [Java 异步编程：从 Future 到 Loom](https://www.jianshu.com/p/5db701a764cb#8088b12f-499f-e7f0-1ac7-4d7b9980cd23)。
