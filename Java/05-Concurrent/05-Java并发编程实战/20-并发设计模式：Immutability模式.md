# 并发设计模式：Immutability模式

## 1 什么是 Immutability 模式

解决并发问题，其实最简单的办法就是让共享变量只有读操作，即对象具有不变性。根据这个想法，便**产生了不变性（Immutability）模式**。所谓不变性，简单来讲，就是对象一旦被创建之后，状态就不再发生变化。

## 2 实现具备不可变性的类

1. 将一个类所有的属性都设置成 final 的，并且只允许存在只读方法，那么这个类基本上就具备不可变性了。更严格的做法是这个类本身也是 final 的，也就是不允许继承。对此，可以参考 JDK 中 String 的实现。
2. 如果对象提供了一些修改对象自身内容的方法，比如 String.replace 方法，应该从自身内容创建一个新的不可变对象，修改之后返回。

## 3 利用享元模式避免创建重复对象

享元模式（Flyweight Pattern）。利用享元模式可以减少创建对象的数量，从而减少内存占用。Java 语言里面 Long、Integer、Short、Byte 等这些基本数据类型的包装类都用到了享元模式。享元模式本质上其实就是一个对象池。

**注意：使用了享元模式的对象不适合做锁**。

## 4 使用 Immutability 模式的注意事项

在使用 Immutability 模式的时候，需要注意以下两点：

1. 对象的所有属性都是 final 的，并不能保证不可变性；
2. 不可变对象也需要正确发布。
   1. 避免 final 字段在对象被构造前向外暴露。
   2. 在使用 Immutability 模式的时候一定要确认保持不变性的边界在哪里，是否要求属性对象也具备不可变性。

如果只要求字段具有可见性，可以使用 volatile，如果要求字段必须具有原子性，则应该使用相关工具实现，比如下面的库存类就使用原子类实现了原子性：

```java

public class SafeWM {

  class WMRange{
    final int upper;
    final int lower;
    WMRange(int upper,int lower){
    //省略构造函数实现
    }
  }

  final AtomicReference<WMRange> rf = new AtomicReference<>(new WMRange(0,0));

  // 设置库存上限
  void setUpper(int v){
    while(true){
      WMRange or = rf.get();
      // 检查参数合法性
      if(v < or.lower){
        throw new IllegalArgumentException();
      }
      WMRange nr = new WMRange(v, or.lower);
      if(rf.compareAndSet(or, nr)){
        return;
      }
    }
  }

  // 设置库存下限
  void setLower(int v){
    while(true){
      WMRange or = rf.get();
      // 检查参数合法性
      if(v > or.upper){
        throw new IllegalArgumentException();
      }
      WMRange nr = new WMRange(upper.lower,v);
      if(rf.compareAndSet(or, nr)){
        return;
      }
    }
  }

}
```

## 5 总结

Immutability 模式是最简单的解决并发问题的方法，建议当你试图解决一个并发问题时，可以首先尝试一下 Immutability 模式，看是否能够快速解决。

## 6 思考题

Account 的属性是 final 的，并且只有 get 方法，那这个类是不是具备不可变性呢？

```java
public final class Account{

  private final StringBuffer user;

  public Account(String user){
    this.user = new StringBuffer(user);
  }
  
  public StringBuffer getUser(){
    return this.user;
  }

  public String toString(){
    return "user"+user;
  }
}
```

这显然不是一个不可变对象，因其熟悉 user 是可以的，在其他地方可能又该对象的引用，从而对其进行可以修改。
