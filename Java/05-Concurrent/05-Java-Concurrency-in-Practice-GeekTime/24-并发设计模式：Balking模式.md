# Balking 模式

## 1 Balking 模式简介

Guarded Suspension 模式中实现了多线程版本的 if，只有等待条件满足才会继续执行，但是并不是所有的场景都需要这么“执着”地等待，对于有些场景，**当不满足条件时，我们还需要快速放弃**。

比如各种编辑器提供的自动保存功能。自动保存功能的实现逻辑一般都是隔一定时间自动执行存盘操作，存盘操作的前提是文件做过修改，如果文件没有执行过修改操作，就需要快速放弃存盘操作。

参考下面实现代码：

```java
class AutoSaveEditor{

  //文件是否被修改过
  boolean changed=false;

  //定时任务线程池
  ScheduledExecutorService ses = Executors.newSingleThreadScheduledExecutor();

  //定时执行自动保存
  void startAutoSave(){
    ses.scheduleWithFixedDelay(()->{
      autoSave();
    }, 5, 5, TimeUnit.SECONDS);  
  }

  //自动存盘操作
  void autoSave(){
    //不满足条件就放弃操作
    if (!changed) {
      return;
    }
    changed = false;
    //执行存盘操作
    //省略且实现
    this.execSave();
  }

  //编辑操作
  void edit(){
    //省略编辑逻辑
    ......
    changed = true;
  }

}
```

上面实现因为对共享变量 changed 的读写没有使用同步，那如何保证 AutoSaveEditor 的线程安全性呢？加锁即可，但是需要注意的是，考虑到性能问题，我们应该尽可能地减少锁的范围，只在读写共享变量 changed 的地方加锁即可：

```java
//自动存盘操作
void autoSave(){

  synchronized(this){
    if (!changed) {
      return;
    }
    changed = false;
  }
  //执行存盘操作
  //省略且实现
  this.execSave();
}

//编辑操作
void edit(){
  //省略编辑逻辑
  ......
  synchronized(this){
    changed = true;
  }
}  
```

总结：类似这种场景，本质就是当状态满足某个条件时，执行某个业务逻辑，只不过是将这个条件放在多线程的环境中，这种“多线程版本的 if”的应用场景还是很多的，所以也有人把它总结成了一种设计模式，叫做 **Balking 模式**。

## 2 Balking 模式的经典实现

Balking 模式本质上是一种规范化地解决“多线程版本的 if”的方案，只需要将修改和访问共享变量的代码抽取到一个单独的方法中即可：

```java
boolean changed=false;

//自动存盘操作
void autoSave(){
  synchronized(this){
    if (!changed) {
      return;
    }
    changed = false;
  }
  //执行存盘操作
  //省略且实现
  this.execSave();
}

//编辑操作
void edit(){
  //省略编辑逻辑
  ......
  change();
}

//改变状态
void change(){
  synchronized(this){
    changed = true;
  }
}
```

## 3 用 volatile 实现 Balking 模式

1. 用 synchronized 实现了 Balking 模式，这种实现方式最为稳妥，建议实际工作中使用这个方案。
2. 在某些特定场景下，也可以使用 volatile 来实现，但使用 volatile 的前提是对原子性没有要求。

**场景**：在 Copy-on-Write 模式中，有一个 RPC 框架路由表的案例，在 RPC 框架中，本地路由表是要和注册中心进行信息同步的，应用启动的时候，会将应用依赖服务的路由表从注册中心同步到本地路由表中，如果应用重启的时候注册中心宕机，那么会导致该应用依赖的服务均不可用，因为找不到依赖服务的路由表。为了防止这种极端情况出现，RPC 框架可以将本地路由表自动保存到本地文件中，如果重启的时候注册中心宕机，那么就从本地文件中恢复重启前的路由表。这其实也是一种降级的方案。

将路由表保存到本地也可以用 Balking 模式实现，这里我们可以使用 volatile 来实现，因为对共享变量 changed 和 rt 的写操作不存在原子性的要求，而且采用 scheduleWithFixedDelay() 这种调度方式能保证同一时刻只有一个线程执行 autoSave() 方法。

```java
//路由表信息
public class RouterTable {

  //Key:接口名
  //Value:路由集合
  ConcurrentHashMap<String, CopyOnWriteArraySet<Router>> rt = new ConcurrentHashMap<>();
  
  //路由表是否发生变化
  volatile boolean changed;

  //将路由表写入本地文件的线程池
  ScheduledExecutorService ses = Executors.newSingleThreadScheduledExecutor();
  
  //启动定时任务
  //将变更后的路由表写入本地文件
  public void startLocalSaver(){
    ses.scheduleWithFixedDelay(()->{
      autoSave();
    }, 1, 1, MINUTES);
  }

  //保存路由表到本地文件
  void autoSave() {
    if (!changed) {
      return;
    }
    changed = false;
    //将路由表写入本地文件
    //省略其方法实现
    this.save2Local();
  }

  //删除路由
  public void remove(Router router) {
    Set<Router> set=rt.get(router.iface);
    if (set != null) {
      set.remove(router);
      //路由表已发生变化
      changed = true;
    }
  }

  //增加路由
  public void add(Router router) {
    Set<Router> set = rt.computeIfAbsent(
      route.iface, r -> new CopyOnWriteArraySet<>());
    set.add(router);
    //路由表已发生变化
    changed = true;
  }

}
```

>这里使用 volatile 会有纪律导致无法保存到最新的路由表，但是由于路由表的更新其实不是很频繁，所有可以允许这种情况。

### 4 Balking 模式典型的应用场景：单次初始化

Balking 模式有一个非常典型的应用场景就是单次初始化：

```java
class Singleton{
  private static Singleton singleton;

  //构造方法私有化  
  private Singleton(){}

  //获取实例（单例）
  public synchronized static Singleton getInstance(){
    if(singleton == null){
      singleton=new Singleton();
    }
    return singleton;
  }

}
```

当然处于性能考虑，我们会使用双检锁进行优化：

```java
class Singleton{
  private static volatile Singleton singleton;

  //构造方法私有化  
  private Singleton() {}

  //获取实例（单例）
  public static Singleton getInstance() {
    //第一次检查
    if(singleton==null){
      synchronize{Singleton.class){
        //获取锁后二次检查
        if(singleton==null){
          singleton=new Singleton();
        }
      }
    }
    return singleton;
  }
}
```

## 5 思考题

下面的示例代码中，`init()` 方法的本意是：仅需计算一次 count 的值，采用了 Balking 模式的 volatile 实现方式，你觉得这个实现是否有问题呢？

```java
class Test{

  volatile boolean inited = false;

  int count = 0;

  void init(){
    if(inited){
      return;
    }
    inited = true;
    //计算count的值
    count = calc();
  }

}  
```

答：无法实现，volatile 不能保证对 inited 操作的原子性。

## 6 其他参考

- [《图解Java多线程设计模式》之五：Balking 模式](https://www.cnblogs.com/inspred/p/9385897.html)
