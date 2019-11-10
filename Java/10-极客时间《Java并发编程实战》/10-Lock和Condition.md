# Lock 和 Condition

## 1 Lock/Condition 简介

回顾，并发编程的两大问题：

- 一个是互斥，即同一时刻只允许一个线程访问共享资源。
- 一个是同步，即线程之间如何通信、协作。

这两个问题管程都可以解决。JDK1.5 中引入了 juc，Java SDK 并发包通过 Lock 和 Condition 两个接口来实现管程，其中 Lock 用于解决互斥问题，Condition 用于解决同步问题。

## 2 有了 synchronized，为什么还要 Lock/Condition

### 不是因为性能问题

在 Java 的 1.5 版本中，synchronized 性能不如 SDK 里面的 Lock，但 1.6 版本之后，synchronized 做了很多优化，将性能追了上来，所以 1.6 之后的版本又有人推荐使用 synchronized 了。如果仅仅是性能问题，优化一下就可以，没有必要再造轮子。

### Lock/Condition 更灵活

[解决死锁](04-解决死锁.md)中提到，避免死锁的方法：

1. 对于“占用且等待”这个条件，我们可以一次性申请所有的资源，这样就不存在等待了。
2. 对于“不可抢占”这个条件，占用部分资源的线程进一步申请其他资源时，如果申请不到，可以主动释放它占有的资源，这样不可抢占这个条件就破坏掉了。
3. 对于“循环等待”这个条件，可以靠按序申请资源来预防。所谓按序申请，是指资源是有线性顺序的，申请的时候可以先申请资源序号小的，再申请资源序号大的，这样线性化后自然就不存在循环了。

其中“不可抢占”，synchronized 是无法实现的，当 synchronized 申请资源时，如果申请不到，线程就会阻塞，无法再执行任何指令。

**怎样的互斥锁可以实现“破坏不可抢占条件”方案呢？**

1. 能够响应中断。synchronized 的问题是，持有锁 A 后，如果尝试获取锁 B 失败，那么线程就进入阻塞状态，一旦发生死锁，就没有任何机会来唤醒阻塞的线程。但如果阻塞状态的线程能够响应中断信号，也就是说当我们给阻塞的线程发送中断信号的时候，能够唤醒它，那它就有机会释放曾经持有的锁 A。这样就破坏了不可抢占条件了。
2. 支持超时。如果线程在一段时间之内没有获取到锁，不是进入阻塞状态，而是返回一个错误，那这个线程也有机会释放曾经持有的锁。这样也能破坏不可抢占条件。
3. 非阻塞地获取锁。如果尝试获取锁失败，并不进入阻塞状态，而是直接返回，那这个线程也有机会释放曾经持有的锁。这样也能破坏不可抢占条件。

这三种方案可以全面弥补 synchronized 的问题。**这三个方案就是“重复造轮子”的主要原因**，体现在 API 上，就是 Lock 接口的三个方法。详情如下：

```java
// 支持中断的API
void lockInterruptibly() throws InterruptedException;

// 支持超时的API
boolean tryLock(long time, TimeUnit unit) throws InterruptedException;

// 支持非阻塞获取锁的API
boolean tryLock();
```

## 3 Lock/Condition 如果保证可见性

Lock 的使用模板：

```java
class X {
  private final Lock rtl =
  new ReentrantLock();
  int value;
  public void addOne() {
    // 获取锁
    rtl.lock();  
    try {
      value+=1;
    } finally {
      // 保证锁能释放
      rtl.unlock();
    }
  }
}
```

那么在 finally 中释放锁后，能保证对 value++ 的可见性么？比如线程 T1 对 value 进行了 +=1 操作，那后续的线程 T2 能够看到 value 的正确结果吗？

是可以的，大概的原理是：利用了 volatile 相关的 Happens-Before 规则。Java SDK 里面的 ReentrantLock，内部持有一个 volatile 的成员变量 state，获取锁的时候，会读写 state 的值；解锁的时候，也会读写 state 的值。也就是说，在执行 value+=1 之前，程序先读写了一次 volatile 变量 state，在执行 value+=1 之后，又读写了一次 volatile 变量 state。根据相关的 Happens-Before 规则：

- 顺序性规则：对于线程 T1，value+=1 Happens-Before 释放锁的操作 unlock()；
- volatile 变量规则：由于 state = 1 会先读取 state，所以线程 T1 的 unlock() 操作 Happens-Before 线程 T2 的 lock() 操作；
- 传递性规则：线程 T1 的 value+=1 Happens-Before 线程 T2 的 lock() 操作。

```java
//伪代码：ReentrantLock 内部保证可见性的原理
class SampleLock {
  volatile int state;
  // 加锁
  lock() {
    // 省略代码无数
    state = 1;
  }
  // 解锁
  unlock() {
    // 省略代码无数
    state = 0;
  }
}
```

所以说，后续线程 T2 能够看到 value 的正确结果。

## 4 可重入锁、可重入函数

ReentrantLock 是 Lock 的一个实现，这个翻译过来叫可重入锁。所谓可重入锁，**指的是已经获取锁的线程可以重复获取同一把锁**。

相关概念还有可重入函数，指的是多个线程可以同时调用该函数，每个线程都能得到正确结果；同时在一个线程内支持线程切换，无论被切换多少次，结果都是正确的。所以可重入函数是线程安全的。一个典型的可重入函数是该函数不访问任何成员变量和任何函数。

## 5 什么是公平锁与非公平锁

ReentrantLock 这个类有两个构造函数，一个是无参构造函数，一个是传入 fair 参数的构造函数。fair 参数代表的是锁的公平策略，如果传入 true 就表示需要构造一个公平锁，反之则表示要构造一个非公平锁。

```java
//无参构造函数：默认非公平锁
public ReentrantLock() {
    sync = new NonfairSync();
}

//根据公平策略参数创建锁
public ReentrantLock(boolean fair){
    sync = fair ? new FairSync(): new NonfairSync();
}
```

**锁都对应着一个等待队列，如果一个线程没有获得锁，就会进入等待队列**，当有线程释放锁的时候，就需要从等待队列中唤醒一个等待的线程。

- 如果是公平锁，唤醒的策略就是谁等待的时间长，就唤醒谁，很公平；
- 如果是非公平锁，则不提供这个公平保证，有可能等待时间短的线程反而先被唤醒。

## 6 用“锁”的最佳实践

用锁虽然能解决很多并发问题，但是风险也是挺高的。可能会导致死锁，也可能影响性能。这方面有是否有相关的最佳实践呢？有，还很多。但是最值得推荐的是并发大师 Doug Lea《Java 并发编程：设计原则与模式》一书中，推荐的三个用锁的最佳实践，它们分别是：

1. 永远只在更新对象的成员变量时加锁
2. 永远只在访问可变的成员变量时加锁
3. 永远不在调用其他对象的方法时加锁：因为调用其他对象的方法，实在是太不安全了，也许“其他”方法里面有线程 `sleep()` 的调用，也可能会有奇慢无比的 I/O 操作，这些都会严重影响性能。更可怕的是，“其他”类的方法可能也会加锁，然后双重加锁就可能导致死锁。

>初次之外，还有：减少锁的持有时间、减小锁的粒度等业界广为人知的规则，其实本质上它们都是相通的，不过是在该加锁的地方加锁而已。

并发问题，本来就难以诊断，所以你一定要让你的代码尽量安全，尽量简单，哪怕有一点可能会出问题，都要努力避免。

## 7 实例：tryLock 使用分析

下面这段关于转账的程序就使用到了 `tryLock()`，它是否存在死锁问题呢？

```java
class Account {
  private int balance;
  private final Lock lock = new ReentrantLock();

  // 转账
  void transfer(Account tar, int amt){
    boolean flag = true;
    while (flag) {
      if(this.lock.tryLock()) {
        try {
          if (tar.lock.tryLock()) {
            try {
              this.balance -= amt;
              tar.balance += amt;
              flag = false;
            } finally {
              tar.lock.unlock();
            }
          }//if
        } finally {
          this.lock.unlock();
        }
      }//if
    }//while
  }//transfer
}
```

解析：死锁问题不会存在，因为都是尝试去获取锁，获取不到会直接返回，但是可能存在**活锁问题**，A，B两账户相互转账，各自持有自己lock的锁，都一直在尝试获取对方的锁，形成了活锁。

## 8 Condition 介绍

Condition 实现了管程模型里面的条件变量。synchronized 仅支持一个条件变量，而 `Lock&Condition` 实现的管程是支持多个条件变量的，这是二者的一个重要区别。在很多并发场景下，支持多个条件变量能够让我们的并发程序可读性更好，实现起来也更容易。例如，实现一个阻塞队列，就需要两个条件变量。

### 使用 lock 和 condition 实现简单的阻塞队列

```java

public class BlockedQueue<T>{

  final Lock lock = new ReentrantLock();
  // 条件变量：队列不满  
  final Condition notFull = lock.newCondition();
  // 条件变量：队列不空  
  final Condition notEmpty = lock.newCondition();

  // 入队
  void enq(T x) {
    lock.lock();
    try {
      while (队列已满){
        // 等待队列不满
        notFull.await();
      }  
      // 省略入队操作...
      //入队后,通知可出队
      notEmpty.signal();
    }finally {
      lock.unlock();
    }
  }

  // 出队
  void deq(){
    lock.lock();
    try {
      while (队列已空){
        // 等待队列不空
        notEmpty.await();
      }  
      // 省略出队操作...
      //出队后，通知可入队
      notFull.signal();
    }finally {
      lock.unlock();
    }  
  }

}
```

## 9 同步与异步

同步异步，通俗点来讲就是调用方是否需要等待结果，如果需要等待结果，就是同步；如果不需要等待结果，就是异步。

### 同步与异步举例

比如在下面的代码里：

```java
// 计算圆周率小说点后100万位
String pai1M() {
  //省略代码无数
}

pai1M()
printf("hello world")
```

有一个计算圆周率小数点后 100 万位的方法 pai1M()，这个方法可能需要执行俩礼拜，如果调用 pai1M() 之后，线程一直等着计算结果，等俩礼拜之后结果返回，就可以执行 printf("hello world")了，这个属于同步；如果调用 pai1M() 之后，线程不用等待计算结果，立刻就可以执行  printf("hello world")，这个就属于异步。

同步，是 Java 代码默认的处理方式。如果你想让你的程序支持异步，可以通过下面两种方式来实现：

1. 调用方创建一个子线程，在子线程中执行方法调用，这种调用我们称为异步调用；
2. 方法实现的时候，创建一个新的线程执行主要逻辑，主线程直接 return，这种方法我们一般称为异步方法。

### Dubbo 源码分析

在 TCP 协议层面，发送完 RPC 请求后，线程是不会等待 RPC 的响应结果的。但是平时工作中的 RPC 调用大多数都是同步的啊？这是怎么回事呢？

其实很简单，一定是有人帮你做了异步转同步的事情。例如目前知名的 RPC 框架 Dubbo 就给我们做了异步转同步的事情，那它是怎么做的呢？

对于下面一个简单的 RPC 调用，默认情况下 sayHello() 方法，是个同步方法，也就是说，执行 service.sayHello(“dubbo”) 的时候，线程会停下来等结果。

```java
DemoService service = 初始化部分省略
String message = service.sayHello("dubbo");
System.out.println(message);
```

如果此时你将调用线程 dump 出来的话，会是下图这个样子，你会发现调用线程阻塞了，线程状态是 TIMED_WAITING。本来发送请求是异步的，但是调用线程却阻塞了，说明 Dubbo 帮我们做了异步转同步的事情。通过调用栈，你能看到线程是阻塞在 DefaultFuture.get() 方法上，所以可以推断：Dubbo 异步转同步的功能应该是通过 DefaultFuture 这个类实现的。

精简后的 DefaultFuture 源码，其实就是一个经典的等待-通知机制：

```java
// 创建锁与条件变量
private final Lock lock = new ReentrantLock();
private final Condition done = lock.newCondition();

// 调用方通过该方法等待结果
Object get(int timeout){
  long start = System.nanoTime();
  lock.lock();
  try {
    while (!isDone()) {
        done.await(timeout);
        long cur=System.nanoTime();
        if (isDone() || cur-start > timeout){
            break;
        }
    }
  } finally {
    lock.unlock();
  }
  if (!isDone()) {
    throw new TimeoutException();
  }
  return returnFromResponse();
}

// RPC结果是否已经返回
boolean isDone() {
  return response != null;
}

// 当 RPC 结果返回时，会调用 doReceived() 方法，这个方法里面，调用 lock() 获取锁，在 finally 里面调用 unlock() 释放锁，获取锁后通过调用 signal() 来通知调用线程，结果已经返回，不用继续等待了。
private void doReceived(Response res) {
  lock.lock();
  try {
    response = res;
    if (done != null) {
      done.signal();
    }
  } finally {
    lock.unlock();
  }
}
```

DefaultFuture 里面唤醒等待的线程，用的是 `signal()`，而不是 `signalAll()`，这样做是否合理呢？解析：Dubbo 后面将 `signalAll()` 换成了 `signal()`，`signal()`只能唤醒一个线程，可能会导致其他在等待的线程只能等待超时，而不能提前结束无畏的等待。

## 10 总结

- Lock&Condition 是管程的一种实现，所以能否用好 Lock 和 Condition 要看你对管程模型理解得怎么样。
- Lock&Condition 实现的管程相对于 synchronized 实现的管程来说更加灵活、功能也更丰富。

相关参考资料:

- 《Java 并发编程的艺术》一书的第 5 章《Java 中的锁》介绍了Java SDK 并发包里锁和条件变量是如何实现的。
