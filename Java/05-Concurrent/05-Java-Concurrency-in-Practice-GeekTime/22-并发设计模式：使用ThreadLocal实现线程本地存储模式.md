# 并发设计模式：ThreadLocal

## 1 ThreadLocal 的使用方法

使用 ThreadLocal 可以实现线程域对象，每个线程可以从 ThreadLocal 获取到该线程独有的对象，即线程之间没有共享，也就没有并发问题。

我们知道，SimpleDateFormat 不是线程安全的，那如果需要在并发场景下使用它，你该怎么办呢？我们可以使用 ThreadLocal：

```java

static class SafeDateFormat {

  //定义ThreadLocal变量
  static final ThreadLocal<DateFormat> tl=ThreadLocal.withInitial(()-> new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"));

  static DateFormat get(){
    return tl.get();
  }

}
//不同线程执行下面代码
//返回的df是不同的
DateFormat df = SafeDateFormat.get()；
```

不同线程调用 SafeDateFormat 的 get() 方法将返回不同的 SimpleDateFormat 对象实例，由于不同线程并不共享 SimpleDateFormat，所以就像局部变量一样，是线程安全的。

## 2 ThreadLocal 的工作原理

如果让你来实现 ThreadLocal 的功能，你会怎么设计呢？ThreadLocal 的目标是让不同的线程有不同的变量 V，那最直接的方法就是创建一个 Map，它的 Key 是线程，Value 是每个线程拥有的变量 V，ThreadLocal 内部持有这样的一个 Map 就可以了。

Java 的实现里面也有一个 Map，叫做 ThreadLocalMap，不过持有 ThreadLocalMap 的不是 ThreadLocal，而是 Thread。Thread 这个类内部有一个私有属性 threadLocals，其类型就是 ThreadLocalMap，ThreadLocalMap 的 Key 是 ThreadLocal。

为什么 Java 要这么设计呢？

1. 在 Java 的实现方案里面，ThreadLocal 仅仅是一个代理工具类，内部并不持有任何与线程相关的数据，所有和线程相关的数据都存储在 Thread 里面，这样的设计容易理解。而从数据的亲缘性上来讲，ThreadLocalMap 属于 Thread 也更加合理。
2. 还有一个更加深层次的原因，那就是不容易产生内存泄露。让线程本身持有 ThreadLocalMap，从而 ThreadLocalMap 可以随着线程的销毁而销毁，其次 Java 的实现中， Thread 所持有的 ThreadLocalMap 里对 ThreadLocal 的引用还是弱引用（WeakReference），所以只要 Thread 对象也不会影响 ThreadLocal 对象的回收。

## 3 ThreadLocal 与内存泄露

**Java 的 ThreadLocal 实现应该称得上深思熟虑了，不过即便如此深思熟虑，还是不能百分百地让程序员避免内存泄露，例如在线程池中使用 ThreadLocal，如果不谨慎就可能导致内存泄露**。

在线程池中使用 ThreadLocal 为什么可能导致内存泄露呢？原因就出在线程池中线程的存活时间太长，往往都是和程序同生共死的，这就意味着 Thread 持有的 ThreadLocalMap 一直都不会被回收，再加上 ThreadLocalMap 中的 Entry 对 ThreadLocal 是弱引用（WeakReference），所以只要 ThreadLocal 结束了自己的生命周期是可以被回收掉的。但是 Entry 中的 Value 却是被 Entry 强引用的，所以即便 Value 的生命周期结束了，Value 也是无法被回收的，从而导致内存泄露。

所以在线程池中使用 ThreadLocal ，我们要注意手动释放资源，比如：

```java
ExecutorService es;
ThreadLocal tl;

es.execute(()->{
  //ThreadLocal增加变量
  tl.set(obj);
  try {
    // 省略业务逻辑代码
  }finally {
    //手动清理ThreadLocal
    tl.remove();
  }
});
```

## 4 InheritableThreadLocal 与继承性

通过 ThreadLocal 创建的线程变量，其子线程是无法继承的。也就是说你在线程中通过 ThreadLocal 创建了线程变量 V，而后该线程创建了子线程，你在子线程中是无法通过 ThreadLocal 来访问父线程的线程变量 V 的。如果你需要子线程继承父线程的线程变量，可以使用 InheritableThreadLocal。

注意：**不建议在线程池中使用 InheritableThreadLocal，不仅仅是因为它具有 ThreadLocal 相同的缺点——可能导致内存泄露，更重要的原因是：线程池中线程的创建是动态的，很容易导致继承关系错乱，如果你的业务逻辑依赖 InheritableThreadLocal，那么很可能导致业务逻辑计算错误，而这个错误往往比内存泄露更要命**。

## 5 总结

线程本地存储模式本质上是一种避免共享的方案，由于没有共享，所以自然也就没有并发问题。如果你需要在并发场景中使用一个线程不安全的工具类，最简单的方案就是避免共享。避免共享有两种方案：

- 将这个工具类作为局部变量使用，局部变量方案的缺点是在高并发场景下会频繁创建对象。
- 使用线程本地存储模式，每个线程只需要创建一个工具类的实例，所以不存在频繁创建对象的问题。

## 6 思考题

实际工作中，有很多平台型的技术方案都是采用 ThreadLocal 来传递一些上下文信息，例如 Spring 使用 ThreadLocal 来传递事务信息。我们曾经说过，异步编程已经很成熟了，那你觉得在异步场景中，是否可以使用 Spring 的事务管理器呢？

其实是不可以的，因为 ThreadLocal 内的变量是线程级别的，而异步编程意味着多个线程出来事务，不同线程的变量不可以共享。
