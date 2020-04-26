# 并发模型：Actor模型

## 1 什么是演员模型

像 C++、Java 这些面向对象的语言，对象之间通信，依靠的是对象方法。对象方法和过程语言里的函数本质上没有区别，有入参、有出参，思维方式很相似，使用起来都很简单。那**面向对象理论里的消息是否就等价于面向对象语言里的对象方法呢**？如果掌握了 Actor 模型，机会明白消息不是这个实现法。

>在计算机科学中，演员模型（英语：Actor model）是一种并发运算上的模型。“演员”是一种程序上的抽象概念，被视为并发运算的基本单元：当一个演员接收到一则消息，它可以做出一些决策、创建更多的演员、发送更多的消息、决定要如何回答接下来的消息。演员模型在1973年于Carl Hewitt、Peter Bishop及Richard Steiger的论文中提出。——[《维基百科》](https://zh.wikipedia.org/wiki/%E6%BC%94%E5%91%98%E6%A8%A1%E5%9E%8B)

Actor 模型本质上是一种计算模型，基本的计算单元称为 Actor，换言之，在 Actor 模型中，所有的计算都是在 Actor 中执行的。

- 在面向对象编程里面，一切都是对象；
- 在 Actor 模型里，一切都是 Actor，并且 Actor 之间是完全隔离的，不会共享任何变量。因为其不共享变量，很多人就把 Actor 模型定义为一种并发计算模型。

随着计算机硬件飞速发展，特别是多核 CPU 的发展，Actor 模型又重新活跃起来。Java 语言本身并不支持 Actor 模型，所以如果你想在 Java 语言里使用 Actor 模型，就需要借助第三方类库，目前能完备地支持 Actor 模型而且比较成熟的类库就是 Akka。

下面演示 Akka Actor：

依赖：

```groovy
compile 'com.typesafe.akka:akka-actor_2.11:2.4.9'
```

实例：

```java
public class HelloMain {

    public static void main(String[] args) {
        //创建Actor系统
        ActorSystem system = ActorSystem.create("HelloSystem");
        //创建HelloActor
        ActorRef helloActor = system.actorOf(Props.create(HelloActor.class));
        //发送消息给HelloActor
        helloActor.tell("Actor", ActorRef.noSender());
        //关闭系统
        system.shutdown();
    }

    static class HelloActor extends UntypedActor {
        @Override
        public void onReceive(Object message) {
            System.out.println("Hello " + message);
        }
    }

}
```

Actor 模型和面向对象编程契合度非常高，完全可以用 Actor 类比面向对象编程里面的对象，而且 Actor 之间的通信方式完美地遵守了消息机制，而不是通过对象方法来实现对象之间的通信。

## 2 消息和对象方法的区别

**Actor 中的消息机制**：可以类比现实世界里的写信。Actor 内部有一个邮箱（Mailbox），接收到的消息都是先放到邮箱里，如果邮箱里有积压的消息，那么新收到的消息就不会马上得到处理，也正是因为 Actor 使用单线程处理消息，所以不会出现并发问题。可以把 Actor 内部的工作模式想象成只有一个消费者线程的生产者-消费者模式。

**Actor 的消息机制是异步的**：在 Actor 模型里，发送消息仅仅是把消息发出去而已，接收消息的 Actor 在接收到消息后，也不一定会立即处理，也就是说 Actor 中的消息机制完全是异步的。而调用对象方法，实际上是同步的，对象方法 return 之前，调用方会一直等待。

**Actor 的调用支持话进程、机器**：调用对象方法，需要持有对象的引用，所有的对象必须在同一个进程中。而在 Actor 中发送消息，类似于现实中的写信，只需要知道对方的地址就可以，发送消息和接收消息的 Actor 可以不在一个进程中，也可以不在同一台机器上。因此，Actor 模型不但适用于并发计算，还适用于分布式计算。

## 3 Actor 的规范化定义

Actor 是一种基础的计算单元，具体来讲包括三部分能力，分别是：

1. 处理能力，处理接收到的消息。
2. 存储能力，Actor 可以存储自己的内部状态，并且内部状态在不同 Actor 之间是绝对隔离的。
3. 通信能力，Actor 可以和其他 Actor 之间通信。

当一个 Actor 接收的一条消息之后，这个 Actor 可以做以下三件事：

1. 创建更多的 Actor。
2. 发消息给其他 Actor。
3. 确定如何处理下一条消息：把 Actor 看作一个状态机，把 Actor 处理消息看作是触发状态机的状态变化；而状态机的变化往往要基于上一个状态，触发状态机发生变化的时刻，上一个状态必须是确定的，所以确定如何处理下一条消息，本质上不过是改变内部状态。

## 4 用 Actor 实现累加器

支持并发的累加器可能是最简单并且有代表性的并发问题了，可以基于互斥锁方案实现，也可以基于原子类实现，这里用 Actor 来实现。下面代码启动了 4 个线程来执行累加操作。整个程序没有锁，也没有 CAS，但是程序是线程安全的。

```java
public class CounterMain {

    //累加器
    static class CounterActor extends UntypedActor {

        private int counter = 0;

        @Override
        public void onReceive(Object message) {
            //如果接收到的消息是数字类型，执行累加操作，
            //否则打印counter的值
            if (message instanceof Number) {
                counter += ((Number) message).intValue();
            } else {
                System.out.println(counter);
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
        //创建Actor系统
        ActorSystem system = ActorSystem.create("HelloSystem");
        //4个线程生产消息
        ExecutorService es = Executors.newFixedThreadPool(4);
        //创建CounterActor
        ActorRef counterActor = system.actorOf(Props.create(CounterActor.class));
        //生产4*100000个消息
        for (int i = 0; i < 4; i++) {
            es.execute(() -> {
                for (int j = 0; j < 100000; j++) {
                    counterActor.tell(1, ActorRef.noSender());
                }
            });
        }
        //关闭线程池
        es.shutdown();
        //等待CounterActor处理完所有消息
        Thread.sleep(1000);
        //打印结果
        counterActor.tell("", ActorRef.noSender());
        //关闭Actor系统
        system.shutdown();
    }

}
```

## 5 总结

Actor 模型是一种非常简单的计算模型，其中 **Actor 是最基本的计算单元**，Actor 之间是通过消息进行通信。Actor 与面向对象编程（OOP）中的对象匹配度非常高，在面向对象编程里，系统由类似于生物细胞那样的对象构成，对象之间也是通过消息进行通信，所以在面向对象语言里使用 Actor 模型基本上不会有违和感。

**Vert.x，另一种 Actor 模型实现**： 在 Java 领域，除了可以使用 Akka 来支持 Actor 模型外，还可以使用 Vert.x，不过相对来说 Vert.x 更像是 Actor 模型的隐式实现，对应关系不像 Akka 那样明显，不过本质上也是一种 Actor 模型。

**Actor 模型存在的一些问题**：Actor 可以创建新的 Actor，这些 Actor 最终会呈现出一个树状结构，非常像现实世界里的组织结构，所以利用 Actor 模型来对程序进行建模，和现实世界的匹配度非常高。Actor 模型和现实世界一样都是异步模型，理论上不保证消息百分百送达，也不保证消息送达的顺序和发送的顺序是一致的，甚至无法保证消息会被百分百处理。虽然实现 Actor 模型的厂商都在试图解决这些问题，但遗憾的是解决得并不完美，所以使用 Actor 模型也是有成本的。

## 6 参考资料

- [Actor模型原理](https://www.cnblogs.com/MOBIN/p/7236893.html)
- [akka actor doc](https://akka.io/docs/)
- [Building Reactive Applications with Akka Actors and Java 8](https://www.infoq.com/articles/Building-Reactive-Applications-with-Akka/)
- [一个非常好的akka教程](https://www.cnblogs.com/guazi/p/7053924.html)
- 《响应式架构 消息模式Actor实现与Scala.Akka应用集成》
