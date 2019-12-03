# Feture

## 1 如何获取任务执行结果

Java 通过 ThreadPoolExecutor 提供的 3 个 submit() 方法和 1 个 FutureTask 工具类来支持获得任务执行结果的需求。这 3 个方法的方法签名如下。

```java
// 提交Runnable任务
Future<?> submit(Runnable task);

// 提交Callable任务
<T> Future<T> submit(Callable<T> task);

// 提交Runnable任务及结果引用  
<T> Future<T> submit(Runnable task, T result);
```

### Future 接口

它们的返回值都是 Future 接口，Future 接口有 5 个方法，它们分别是

- 取消任务的方法 cancel()
- 判断任务是否已取消的方法 isCancelled()
- 判断任务是否已结束的方法 isDone()
- 2 个获得任务执行结果的 get() 和 get(timeout, unit)


### submit 方法详解

### FutureTask 工具类

## 2 实现最优的“烧水泡茶”程序

## 3 总结

## 4 思考
