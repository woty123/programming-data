# CompletionService 批量执行异步任务

## 1 如何优化一个询价应用的核心代码

[Futrue与FutureTask](15-Futrue与FutureTask.md)中有如何优化一个询价应用的核心代码的思考题？如果采用“ThreadPoolExecutor+Future”的方案，优化结果很可能是下面示例代码这样：用三个线程异步执行询价，通过三次调用 Future 的 get() 方法获取询价结果，之后将询价结果保存在数据库中。

```java
        // 创建线程池
        ExecutorService executor = Executors.newFixedThreadPool(3);

        // 异步向电商S1询价
        Future<Integer> f1 = executor.submit(() -> getPriceByS1());
        // 异步向电商S2询价
        Future<Integer> f2 = executor.submit(() -> getPriceByS2());
        // 异步向电商S3询价
        Future<Integer> f3 = executor.submit(() -> getPriceByS3());

        // 获取电商S1报价并保存
        r = f1.get();
        executor.execute(() -> save(r));

        // 获取电商S2报价并保存
        r = f2.get();
        executor.execute(() -> save(r));

        // 获取电商S3报价并保存
        r = f3.get();
        executor.execute(() -> save(r));
```

这种优化方案有一个问题：如果获取电商 S1 报价的耗时很长，那么即便获取电商 S2 报价的耗时很短，也无法让保存 S2 报价的操作先执行，因为这个主线程都阻塞在了 f1.get() 操作上。

优化这一点可以使用阻塞队列：获取到 S1、S2、S3 的报价都进入阻塞队列，然后在主线程中消费阻塞队列，这样就能保证先获取到的报价先保存到数据库了。

```java
        // 创建线程池
        ExecutorService executor = Executors.newFixedThreadPool(3);
        // 异步向电商S1询价
        Future<String> f1 = executor.submit(CompletionServiceMain::getPriceByS1);
        // 异步向电商S2询价
        Future<String> f2 = executor.submit(CompletionServiceMain::getPriceByS2);
        // 异步向电商S3询价
        Future<String> f3 = executor.submit(CompletionServiceMain::getPriceByS3);
        // 创建阻塞队列
        BlockingQueue<String> bq = new LinkedBlockingQueue<>();
        //电商S1报价异步进入阻塞队列
        executor.execute(() -> {
            try {
                bq.put(f1.get());
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }
        });
        //电商S2报价异步进入阻塞队列
        executor.execute(() -> {
            try {
                bq.put(f2.get());
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }
        });
        //电商S3报价异步进入阻塞队列
        executor.execute(() -> {
            try {
                bq.put(f3.get());
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }
        });

        //异步保存所有报价
        for (int i = 0; i < 3; i++) {
            String r = bq.take();
            executor.execute(() -> save(r));
        }
```

## 2 使用 CompletionService 实现询价系统

针对上面使用阻塞队列的优化，在实际项目中，是不建议的，因为 Java SDK 并发包里已经提供了设计精良的 CompletionService。利用 CompletionService 不但能帮你解决先获取到的报价先保存到数据库的问题，而且还能让代码更简练。

CompletionService 的实现原理也是内部维护了一个阻塞队列，当任务执行结束就把任务的执行结果加入到阻塞队列中，不同的是 CompletionService 是把任务执行结果的 Future 对象加入到阻塞队列中，而上面的示例代码是把任务最终的执行结果放入了阻塞队列中。

### 使用 CompletionService

CompletionService 接口的实现类是 ExecutorCompletionService，这个实现类的构造方法有两个，分别是：

```java
ExecutorCompletionService(Executor executor)；

ExecutorCompletionService(Executor executor, BlockingQueue> completionQueue)。
```

## 3 CompletionService 详解

## 4 利用 CompletionService 实现 Dubbo 中的 Forking Cluster

## 5 总结

## 6 思考题

