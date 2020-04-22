# 并发设计模式：WorkerThread 模式

## 1 Worker Thread 模式及其实现

**什么是 Worker Thread 模式**：将线程类比工人，创建固定数量的工作线程（ Worker thread ）专门用于处理异步任务，工作线程会从任务池中获取工作任务并进行处理，当所有工作全部完成后，工作线程会阻塞停下来等待新的工作到来。对应到 Java 中，就是我们非常熟悉的线程池了：**用阻塞队列做任务池，然后创建固定数量的线程消费阻塞队列中的任务**。

线程池有很多优点，例如能够避免重复创建、销毁线程，同时能够限制创建线程的上限等等，以 Java 现有的技术实现 Thread-Per-Message 模式，无法应对高并发场景，很容易造成 OOM，原因就在于频繁创建、销毁 Java 线程的成本有点高，而且无限制地创建线程还可能导致应用 OOM。线程池，则恰好能解决这些问题。

echo 实例：

```java
ExecutorService es = Executors.newFixedThreadPool(500);

final ServerSocketChannel ssc = ServerSocketChannel.open().bind(new InetSocketAddress(8080));

//处理请求
try {
  while (true) {
    // 接收请求
    SocketChannel sc = ssc.accept();
    // 将请求处理任务提交给线程池
    es.execute(()->{
      try {
        // 读Socket
        ByteBuffer rb = ByteBuffer.allocateDirect(1024);
        sc.read(rb);
        //模拟处理请求
        Thread.sleep(2000);
        // 写Socket
        ByteBuffer wb =(ByteBuffer)rb.flip();
        sc.write(wb);
        // 关闭Socket
        sc.close();
      }catch(Exception e){
        throw new UncheckedIOException(e);
      }
    });
  }
} finally {
  ssc.close();
  es.shutdown();
}
```

## 2 正确地创建线程池

线程池的两个特点：

1. 能够避免无限制地创建线程导致 OOM。（通过限制创建线程池数量）
2. 也能避免无限制地接收任务导致 OOM。（用创建有界的队列来接收任务）

使用注意：

1. **合理地拒绝请求**：当请求量大于有界队列的容量时，就需要合理地拒绝请求。如何合理地拒绝呢？这需要你结合具体的业务场景来制定，即便线程池默认的拒绝策略能够满足你的需求，也同样建议你在创建线程池时，清晰地指明拒绝策略。
2. 在实际工作中给线程赋予线程业务相关的名字。

根据以上要点，修改 echo 程序如下：

```java
ExecutorService es = new ThreadPoolExecutor(
  50, 500,
  60L, TimeUnit.SECONDS,
  //注意要创建有界队列
  new LinkedBlockingQueue<Runnable>(2000),

  //建议根据业务需求实现ThreadFactory
  r->{
    return new Thread(r, "echo-"+ r.hashCode());
  },
  //建议根据业务需求实现RejectedExecutionHandler
  new ThreadPoolExecutor.CallerRunsPolicy());
```

## 3 避免线程死锁

使用线程池时，如果提交到相同线程池的任务不是相互独立的，而是有依赖关系的，那么就有可能导致线程死锁。

比如这样的一个场景：将一个大型的计算任务分成两个阶段，第一个阶段的任务会等待第二阶段的子任务完成。在这个应用里，每一个阶段都使用了线程池，而且**两个阶段使用的还是同一个线程池**。参考下面示例代码：永远执行不到最后一行。执行过程中没有任何异常，但是应用已经停止响应了。

```java
//L1、L2阶段共用的线程池
ExecutorService es = Executors.newFixedThreadPool(2);
//L1阶段的闭锁
CountDownLatch l1=new CountDownLatch(2);

for (int i=0; i<2; i++){
  System.out.println("L1");
  //执行L1阶段任务
  es.execute(()->{

    //L2阶段的闭锁
    CountDownLatch l2=new CountDownLatch(2);
    //执行L2阶段子任务
    for (int j=0; j<2; j++){
      es.execute(()->{
        System.out.println("L2");
        l2.countDown();
      });
    }

    //等待L2阶段任务执行完
    l2.await();
    l1.countDown();
  });
}

//等着L1阶段任务执行完
l1.await();
System.out.println("end");
```

当应用出现类似问题时，首选的诊断方法是查看线程栈。解决方案：

1. 如果能够确定任务的数量不是非常多的话：将线程池的最大线程数调大，这个办法也是可行的。
2. 通用的解决方案是为不同的任务创建不同的线程池。

总结：**提交到相同线程池中的任务一定是相互独立的，否则就一定要慎重**。

## 4 总结

解决并发编程里的分工问题，最好的办法是和现实世界做对比。对比现实世界构建编程领域的模型，能够让模型更容易理解。

1. Thread-Per-Message 模式，类似于现实世界里的委托他人办理
2. Worker Thread 模式则类似于车间里工人的工作模式。

Worker Thread 模式和 Thread-Per-Message 模式的区别有哪些？

1. 从现实世界的角度看，你委托代办人做事，往往是和代办人直接沟通的；对应到编程领域，其实现也是主线程直接创建了一个子线程，主子线程之间是可以直接通信的。
2. 车间工人的工作方式则是完全围绕任务展开的，一个具体的任务被哪个工人执行，预先是无法知道的；对应到编程领域，则是主线程提交任务到线程池，但主线程并不关心任务被哪个线程执行。

由于 Java 语言本身的限制，不会使用 Thread-Per-Message 模式，而使用线程池实现 Worker Thread 模式，有一些坑需要注意：

1. 正确创建线程池，包括配置线程池数量和阻塞队列的容量。
2. 避免线程死锁问题。
3. 避免 ThreadLocal 内存泄露问题。
4. 做好任务执行的异常处理。

## 5 思考题

下面代码本义是异步地打印字符串“QQ”，实现是否有问题呢？

```java
ExecutorService pool = Executors.newSingleThreadExecutor();
pool.submit(() -> {
  try {
    String qq=pool.submit(()->"QQ").get();
    System.out.println(qq);
  } catch (Exception e) {
  }
});
```

答：该程序将会卡死。
