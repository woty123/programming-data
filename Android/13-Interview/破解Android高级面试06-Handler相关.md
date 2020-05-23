>[大厂资深面试官 带你破解Android高级面试](https://coding.imooc.com/class/317.html) 笔记

# 6 Handler 相关

---
## 6.1 Android 中为什么非 UI 线程不能更新 UI？

### 考察什么？

- 是否理解线程安全的概念（中级）
- 是否能理解 UI 线程的工作机制（高级）
- 是否熟悉 SurfaceVIew 实现高帧率的原理（高级）

### 题目剖析

- UI 线程的工作机制
- 为什么 UI 设计成线程不安全的
- 非 UI 线程就一定不能更新 UI 吗？

**UI 线程是什么**：

- zygote --> app --> `ActivityThread.main` --> `Looper.loop`

**UI 线程如何工作**：

- Looper 就是引擎，app 的驱动力。
- 百变不离其宗：任何 UI 模型都是`生产者消费者模型`
  
**如何把 UI 线程设计成线程安全的**：

- 加锁

**为什么 UI 设计成线程不安全的**：

- UI 的可变性是高频的
- UI 对响应时间非常敏感，要求必须高效

**非 UI 线程就一定不能更新 UI 吗？**

- 在 View 树没有构建完成时
- post、postInvalidate 等方法
- SurfaceView 可以
- GLSurfaceView：GLThread
- TextureView

**SurfaceView**：

- lockCanvas
- draw
- unlockCanvasAndPost
- GLSurfaceView：GLThread
- TextureView

---
## 6.2 Handler 发送消息的 Delay 靠谱吗？

### 考察什么？

- 是否清除 UI 时间相关的任务，如动画的设计实现原理（高级）
- 是否对 Looper 的消息机制有深刻理解（高级）
- 是否做过 UI 过度绘制或其他消息机制的优化（高级）

### 题目剖析

- 大于 Handler Looper 的周期时基本可靠（>50ms）
- Looper 负载越高，任务越容易积压，进而导致卡顿
- 不要用 Handler 的 delay 作为计时的依据
- HandlerThread 的 delay 可以认为是可靠的

**MessageQueue 如何处理消息**：

- MessageQueue：enquequeMessage --> next
- Native：wake --> pollOnce --> epoll_wait

**队列优化**：

- 相同类型消息的取消
- 互斥消息的取消
- 消息复用：`Message.obtain()`
- idleHandler
- HandlerThread

---
## 6.3 主线程的 Looper 为什么不会导致应用 ANR ？

### 考察什么？

- 是否了解 ANR 的产生条件
- 是否对 Android APP 的进程允许机制有深入理解（高级)
- 是否对 Looper 的消息机制有深刻理解（高级）
- 是否对 IO 多路复用有一定的认识（高级)

### 题目剖析

- ANR 如何产生？
- Looper 工作机制？
- Looper 不会导致应用 ANR 的本质原因？
- Looper 为什么不会导致 CPU 占用率高？

**ANR 类型**

- Service Timeout
  - 前台服务 20s
  - 后台服务 200s
- Broadcast Timeout
  - 前台 10s
  - 后台 60s
- ContentProvider Timeout：10s
- InputDispatrching Timeout：5s

**Service Timeout 的产生**

- startServiceLocked
- startServiceInnerLocked
- birngUpServiceLocked
- realStartServiceLocked
- bumpServiceExecutingLocked
- `scheduleServiceTimeoutLocked` 买了一个定时炸弹，规定时间内没有拆除则会引爆
- 定时炸弹的移除：`serviceDoneExecutingLocked` 内部会 `removeMesage(ActivityManagerService.SERVICE_TIMEOUT_MSG)`

```java
private final void realStartServiceLocked(ServiceRecord r, ProcessRecord ap, boolean execInFg) throw RemoteExecetion{
    ...
    bumpServiceExecutingLocked(r,execInFg,"create");
    ...
    app.thread.scheduleCrateService(...)
    ...
    serviceDoneExecutingLocked(r, isDestroying, isDestroying)
    ...
}
```

**主线程究竟在干什么**？

- Looper 是一个进程上的概念
- ANR 只是 Looper 中的一小部分，只是对某一个环节中开发者占用时间的健康

**Looper 为什么不会导致 CPU 暂用率高**

- Looper 不会空转
- epool_wait 函数
- io 多路复用

---
## 6.4 如何自己实现一个简单的 Handler - Looper 框架？

### 考察什么？

- 是否对 Looper 的消息机制有深刻的理解（高级）
- 是否对 Java 并发包中提供的队列有较为清晰的认识（高级）
- 是否能够允许所学知识设计出一套类似的框架（高级）

### 题目剖析

- 简单：表面可以运用 Java 标准库当中的组件
- 覆盖关键路径即可，突出重点
- 分析 Android 为什么要单独实现一套
- 仍然着眼于阐述 Handler-Looper 的原理

**Handler 的核心能力**：

- 线程间通信
- 消息的延迟执行

**Looper 的核心能力**：

- 核心动力，转起来
- 死循环

**MessageQueue**：

- 持有消息
- 消息按时间排序
- 队列为空时阻塞读取
- 头阶段有延时可以定时阻塞

**Android 为什么不使用 DelayQueue**：

- 没有提供合适的 remove 机制
- 自己实现，更大的自由度，特别是与 native 层交互
- 有加锁机制，没有针对单线程做优化
