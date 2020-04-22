# Thread-Per-Message模式：最简单实用的分工方法

## 1 解决分工问题的多线程并发模式

并发编程领域的三个核心问题：分工、同步和互斥。

- 同步和互斥相关问题更多地源自微观。
- 分工问题则是源自宏观。

我们解决问题，往往是从宏观入手，在编程领域，软件的设计过程也是先从概要设计开始，而后才进行详细设计。同样，解决并发编程问题，首要问题也是解决宏观的分工问题。

并发编程领域里，解决分工问题也有一系列的设计模式，比较常用的主要有：Thread-Per-Message 模式、Worker Thread 模式、生产者-消费者模式等。

## 2 Thread-Per-Message 模式

什么是 Thread-Per-Message 模式，比如我们写一个 HTTP Server，很显然只能在主线程中接收请求，而不能处理 HTTP 请求，因为如果在主线程中处理 HTTP 请求的话，那同一时间只能处理一个请求，太慢了！此时我们需要创建一个子线程，委托子线程去处理 HTTP 请求。这种委托其他线程进行任务处理的方式，在并发编程领域被总结为一种设计模式，叫做 Thread-Per-Message 模式，简言之就是为每个任务分配一个独立的线程。这是一种最简单的分工方法

## 3 用 Thread 实现 Thread-Per-Message 模式

Thread-Per-Message 模式的一个最经典的应用场景是网络编程里服务端的实现，服务端为每个客户端请求创建一个独立的线程，当线程处理完请求后，自动销毁，这是一种最简单的并发处理网络请求的方法。

```java
final ServerSocketChannel ssc =  ServerSocketChannel.open().bind(new InetSocketAddress(8080));

//处理请求
try {
  while (true) {
    // 接收请求
    SocketChannel sc = ssc.accept();
    // 每个请求都创建一个线程
    new Thread(()->{
      try {
        // 读Socket
        ByteBuffer rb = ByteBuffer.allocateDirect(1024);
        sc.read(rb);
        //模拟处理请求
        Thread.sleep(2000);
        // 写Socket
        ByteBuffer wb = (ByteBuffer)rb.flip();
        sc.write(wb);
        // 关闭Socket
        sc.close();
      }catch(Exception e){
        throw new UncheckedIOException(e);
      }
    }).start();
  }
} finally {
  ssc.close();
}
```

上面这个 echo 服务的实现方案是不具备可行性的。原因在于 Java 中的线程是一个重量级的对象，创建成本很高，一方面创建线程比较耗时，另一方面线程占用的内存也比较大。所以，为每个请求创建一个新的线程并不适合高并发场景。对此，我们一般会想到引入线程池，但是这会增加程序的复杂度。

**是方案的问题，还是 Java 语言本身的问题**？

1. 语言、工具、框架本身应该是帮助我们更敏捷地实现方案的，而不是用来否定方案的，Thread-Per-Message 模式作为一种最简单的分工方案，Java 语言支持不了，显然是 Java 语言本身的问题。
2. Java 对线程的实现：Java 线程是和操作系统线程一一对应的，这种做法本质上是将 Java 线程的调度权完全委托给操作系统，而操作系统在这方面非常成熟，所以这种做法的好处是稳定、可靠，但是也继承了操作系统线程的缺点：创建成本高。为了解决这个缺点，Java 并发包里提供了线程池等工具类。

**轻量级线程**：业界还有另外一种方案，叫做轻量级线程，这种轻量级线程，Java SDK 本身并不支持，但是其他一些语言却又很好的支持，比如 Go 语言、Lua 语言里的协程本质上就是一种轻量级的线程。轻量级的线程，创建的成本很低，基本上和创建一个普通对象的成本相似；并且创建的速度和内存占用相比操作系统线程至少有一个数量级的提升，**所以基于轻量级线程实现 Thread-Per-Message 模式就完全没有问题了**。

**Open JDK 的 Fiber 项目**：Java 语言目前也已经意识到轻量级线程的重要性了，OpenJDK 有个 Loom 项目，就是要解决 Java 语言的轻量级线程问题，在这个项目中，轻量级线程被叫做 Fiber。

## 4 用 Fiber 实现 Thread-Per-Message 模式

Loom 项目在设计轻量级线程时，充分考量了当前 Java 线程的使用方式，采取的是尽量兼容的态度，所以使用上还是挺简单的。用 Fiber 实现 echo 服务的示例代码如下所示：

```java
final ServerSocketChannel ssc =  ServerSocketChannel.open().bind(new InetSocketAddress(8080));

//处理请求
try{
  while (true) {
    // 接收请求
    final SocketChannel sc = serverSocketChannel.accept();
    Fiber.schedule(()->{
      try {
        // 读Socket
        ByteBuffer rb = ByteBuffer
          .allocateDirect(1024);
        sc.read(rb);
        //模拟处理请求
        LockSupport.parkNanos(2000*1000000);
        // 写Socket
        ByteBuffer wb = (ByteBuffer)rb.flip()
        sc.write(wb);
        // 关闭Socket
        sc.close();
      } catch(Exception e){
        throw new UncheckedIOException(e);
      }
    });
  }//while
}finally{
  ssc.close();
}
```

性能测试：

1. 首先通过 ulimit -u 512 将用户能创建的最大进程数（包括线程）设置为 512；
2. 启动 Fiber 实现的 echo 程序；
3. 利用压测工具 ab 进行压测：`ab -r -c 20000 -n 200000 http:// 测试机 IP 地址:8080/`

使用 Fiber，在 20000 并发下，该程序依然能够良好运行。同等条件下，Thread 实现的 echo 程序 512 并发都抗不过去，直接就 OOM 了。通过 Linux 命令 `top -Hp pid` 可以查看 Fiber 实现的 echo 程序的进程信息，其会根据 CPU 核数创建合适的线程数，来处理执行轻量级线程。

>要使用 Fiber 需要自行编译 OpenJDK，具体可以参考[project loom](https://wiki.openjdk.java.net/display/loom)。

## 5 总结

并发编程领域的**分工问题，指的是如何高效地拆解任务并分配给线程**。

Future、CompletableFuture 、CompletionService、Fork/Join 计算框架等都是 Java JDK 提供的并发框架，但是它们使用起来都比较复杂。作为 Java 程序员可能觉得这样的复杂度很正常，但是随着技术的发展，很多复杂变得没有必要。比如 Thread-Per-Message 模式如果使用线程池方案就会增加复杂度。

Thread-Per-Message 模式在 Java 领域并不知名，根本原因在于 Java 语言里的线程是一个重量级的对象，为每一个任务创建一个线程成本太高，尤其是在高并发领域，基本就不具备可行性。但是随着 [project loom](https://wiki.openjdk.java.net/display/loom) 项目发展，Java 语言未来一定会提供轻量级线程，这样基于轻量级线程实现 Thread-Per-Message 模式就是一个非常靠谱的选择。

## 6 思考题

使用 Thread-Per-Message 模式会为每一个任务都创建一个线程，在高并发场景中，很容易导致应用 OOM，那有什么办法可以快速解决呢？

1. 改用线程池
2. 服务的限流
3. 修改 JVM 相关参数
4. 使用 NIO/AIO 模式

## 7 扩展参考

- [服务器端限流保护](https://www.cnblogs.com/xianzhedeyu/p/5868024.html)
- [Java并发 -- Thread-Per-Message模式](http://zhongmingmao.me/2019/05/23/java-concurrent-thread-per-message/)
- [Quasar Fiber ，通过 javaagent 技术实现轻量级线程](http://www.paralleluniverse.co/quasar/)
- [Java 异步编程：从 Future 到 Loom](https://www.jianshu.com/p/5db701a764cb#8088b12f-499f-e7f0-1ac7-4d7b9980cd23)
