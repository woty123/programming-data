# 5 协程指南概要总结

- [协程指南-en](https://github.com/Kotlin/kotlinx.coroutines)
- [协程指南-zh](https://www.kotlincn.net/docs/reference/coroutines/coroutines-guide.html)

## 1 核心部分

### 1 结构化化并发与显式等待

- 使用 join 可以让一个协程等待另一个协程完成后才继续执行。
- 结构化并发：在协程所在的指定作用域内启动子协程，而不是像通常使用线程（线程总是全局的）那样在 GlobalScope 中启动。那该协程总是会等待所有子协程完成后才会完成。

### 2 协程的取消

- 启动的协程是可以被取消的，通过 `Job.cancel` 方法
- 协程的取消是 **协作** 的。一段协程代码必须协作才能被取消。 所有 `kotlinx.coroutines` 中的挂起函数都是可被取消的。它们检查协程的取消，并在取消时抛出 CancellationException。我们可以不处理 CancellationException，程序不会崩溃，但如果需要在异常时做一些额外的操作，则可以使用 `try/catch` 包装协程代码。
- 在罕见的情况下，需要在取消的协程中挂起，可以使用 `withContext(NonCancellable) {...}`

### 3 协程错误处理

- 协程构建器有两种风格：自动的传播异常（launch 以及 actor） 或者将它们暴露给用户（async 以及 produce）。
  - 自动的传播异常：对待异常是不处理的，类似于 Java 的 Thread.uncaughtExceptionHandler。用户可以不处理这些异常，程序不会崩溃。
  - 暴露给用户：依赖用户来最终消耗异常，比如说，通过 await 或 receive。用户需要处理这些异常，否则程序会奔溃。
- CoroutineExceptionHandler：用于处理协程中的未捕获异常，它和使用 Thread.uncaughtExceptionHandler 很相似。

#### 取消与异常紧密相关

- 取消与异常紧密相关，协程内部使用 CancellationException 来进行取消，这个异常会被所有的处理者忽略，所以那些可以被 catch 代码块捕获的异常仅仅应该被用来作为额外调试信息的资源（即不需要开发者处理）。
- 当一个协程使用 `Job.cancel` 取消的时候，它会被终止，但是它不会取消它的父协程。而父协程使用 `Job.cancel` 时，其子协程都将被取消。
- 如果协程遇到除 CancellationException 以外的异常，它将取消具有该异常的父协程。 这种行为不能被覆盖，且它被用来提供一个稳定的协程层次结构来进行结构化并发而无需依赖 CoroutineExceptionHandler 的实现。且当所有的子协程被终止的时候，原本的异常被父协程所处理。
- 由此可以看出，取消是一种双向机制，在协程的整个层次结构之间传播。

#### 单向取消与 SupervisorJob

- 单向取消需求：此类需求的一个良好示例是可以在其作用域内定义任务的的 UI 组件。如果任何一个 UI 的子任务执行失败了，它并不总是有必要取消（有效地杀死）整个 UI 组件， 但是如果 UI 组件被销毁了（并且它的任务也被取消了），由于它的结果不再被需要了，它有必要使所有的子任务执行失败。
- SupervisorJob：可以被用于实现上面需求。它类似于常规的 Job，唯一不同的是取消异常将只会向下传播。使用 SupervisorJob 的作用是，子协程抛出异常不会导致父协程和其他兄弟协程停止。
- 对于 SupervisorJob，每一个子任务应该通过异常处理机制处理自身的异常，这种差异来自于子任务的执行失败不会传播给它的父任务的事实。
- 相关的函数是 supervisorScope。

### 4 协程上下文与调度器

- 调度器：Coroutine context 包含一个 Dispatchers，它确定对应协程用于执行的线程或线程池。Dispatchers 可以将协程执行限制在一个特定的线程上，将其调度到线程池，或者让其无限制地运行。
- 当调用 `launch { …… }`（或其他协程构造器） 时不传参数，它从启动了它的 CoroutineScope 中承袭了上下文（以及调度器）。
- 全局的协程只能通过 GlobalScope 上面的扩展函数启动，其默认使用 `Dispatchers.Default` 协程调度器。
- 当一个协程被其它协程在 CoroutineScope 中启动的时候， 它将通过 CoroutineScope.coroutineContext 来承袭上下文，并且这个新协程的 Job 将会成为父协程任务的 子任务。当一个父协程被取消的时候，所有它的子协程也会被递归的取消。当 GlobalScope 被用来启动一个协程时，它与作用域无关且是独立被启动的。
- 可以使用 `withContext` 来切换调度器，而仍然驻留在相同的协程中。
- 可以使用 `CoroutineName("main")` 来给协程命名。
- ThreadLocal 的 `asContextElement` 扩展方法用于实现协程域变量。

### 5 协程并发安全

对于协程的调度，底层使用的依然还是线程，所以一样会遇到各种并发安全问题，除了使用常规的处理方式外，协程库也提供了一些解决方案，以下是官方示例中提供的集中解决方案：

- 使用 JUC 中的并发工具，比如 Atomic。
- 限制线程是解决共享可变状态问题的一种方案：对特定共享状态的所有访问权都限制在单个线程中。但是这样的代码运行很慢。
- 使用一个单线程的调度器来调度所有协程，这样就不会有线程安全问题。
- 作为 synchronized 或者 ReentrantLock 的替代，协程提供了 Mutex 。它具有 lock 和 unlock 方法， 可以隔离关键的部分。关键的区别在于 Mutex.lock() 是一个挂起函数，它不会阻塞线程。
- actor 也可以用于解决线程安全问题，在 actor 启动的协程内部，对变量的操作是线程安全的，而外界可以有多个协程同时向 actor 启动的协程发送数据，actor 在高负载下比锁更有效，因为在这种情况下它总是有工作要做，而且根本不需要切换到不同的上下文。
