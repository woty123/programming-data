# [《Linux性能优化实战》](https://time.geekbang.org/column/intro/140) 主要知识点整理

1. [1 如何学习 Linux 性能优化](#1-如何学习Linux性能优化)
2. 基础篇
   1. [2 平均负载](#2-平均负载)
   2. [3 什么是上下文切换](#3-什么是上下文切换)
   3. [4 上下文切换调优](#4-上下文切换调优)
   4. [5 CPU使用率](#5-CPU使用率)

---

## 1-如何学习Linux性能优化

性能问题并没有你想像得那么难，只要你理解了应用程序和系统的少数几个基本原理，再进行大量的实战练习，建立起整体性能的全局观，大多数性能问题的优化就会水到渠成。

1. 性能指标：
   1. 从应用负载的视角来考察性能：“高并发”和“响应快”，对应着性能优化的两个核心指标——“吞吐”和“延时”。
   2. 从系统资源的视角出发的指标：与“吞吐”和“延时”对应，有资源使用率、饱和度等。
2. 解决性能问题的本质：
   1. 性能问题的本质：系统资源已经达到瓶颈，但请求的处理却还不够快，无法支撑更多的请求。
   2. 性能分析：找出应用或系统的瓶颈，并设法去避免或者缓解它们，从而更高效地利用系统资源处理更多的请求。
3. 性能分析的步骤：
   1. 选择指标评估应用程序和系统的性能；
   2. 为应用程序和系统设置性能目标；
   3. 进行性能基准测试；
   4. 性能分析定位瓶颈；
   5. 优化系统和应用程序；
   6. 性能监控和告警。

**掌握必要的性能优化工具**：下面是 Brendan Gregg 制作的 Linux 性能优化工具图谱，通过这个图可以知道在 Linux 不同子系统出现性能问题后，应该用什么样的工具来观测和分析：

![Brendan Gregg](images/lpo01-all-tools.png "http://www.brendangregg.com/Perf/linux_perf_tools_full.png")

建立性能优化全局观：**性能分析和优化所包含的知识**：

![lpo01-all-skills](images/lpo01-all-skills.png)

**学习目标**：建立整体系统性能的全局观

1. 理解最基本的几个系统知识原理——懂得原理才能有的放矢。
2. 掌握必要的性能优化工具——选对工具才能事半功倍，一个正确的选择胜过千百次的努力。
3. 通过实际的场景演练，贯穿不同的组件——不要停留在在理论，实践才能出真知，经验都是通过无数次实战积累出来的。

>性能优化不只是性能优化工具的学习，而是能够理解其背后的原理。

**高效学习**：

1. 技巧一：不要贪图掌握所有细节。在了解到性能问题对应的系统相关原理后，重点放到如何观察和运用这些原理上，比如：
   1. 有哪些指标可以衡量性能？
   2. 使用什么样的性能工具来观察指标？
   3. 导致这些指标变化的因素等。
2. 边学边实践，通过大量的案例演习掌握 Linux 性能的分析和优化。
3. 勤思考，多反思，善总结，多问为什么。

---

## 2-平均负载

### 2.1 什么是平均负载

当系统变慢时，我们通常会使用 `uptime` 和 `top` 命令来了解负载情况。

```shell
# 运行 uptime
uptime
# 结果
15:17:58 up 44 min,  1 user,  load average: 0.00, 0.02, 0.02
```

输出结果说明：

- `15:17:58` 当前时间
- `up 44 min` 系统运行时间
- `1 user` 正在登录用户数
- `load average: 0.00, 0.02, 0.02` 过去 1 分钟、5 分钟、15 分钟的平均负载（LoadAverage）。

**平均负载概念**：指单位时间内，系统处于`可运行状态`和`不可中断状态`的平均进程数，也就是平均活跃进程数。与 CPU 使用率并没有直接关系。

- 可运行状态：正在使用 CPU 或者正在等待 CPU 的进程，用 ps 命令看到的，处于 R 状态（Running 或 Runnable）的进程。
- 不可中断状态：正处于内核态关键流程中的进程，并且这些流程是不可打断的，比如等待硬件设备的 I/O 响应，用 ps 命令看到的，处于 D 状态（Uninterruptible Sleep，也称为 Disk Sleep）的进程。
  - 原因：`不可中断状态实际上是系统对进程和硬件设备的一种保护机制`
  - 距离：`当一个进程向磁盘读写数据时，为了保证数据的一致性，在得到磁盘回复前，它是不能被其他进程或者中断打断的，否自就容易出现磁盘数据与进程数据不一致的问题。`

**平均负载解读**：

- 简单理解：平均活跃进程数。
- 直观理解：单位时间内的活跃进程数。
- 实质上：活跃进程数的指数衰减平均值，简单理解为`活跃进程数的平均值`。

**平均负载指数解读**：要根据 CPU 的核数来解读平均负载数（这里的 CPU 的核数是指逻辑核数），比如当平局负载数为 1 时：

1. 在只有 2 个 CPU 的系统上，意味着所有的 CPU 都刚好被完全占用。
2. 在 4 个 CPU 的系统上，意味着 CPU 有 50% 的空闲。
3. 在只有 1 个 CPU 的系统中，则意味着有一半的进程竞争不到 CPU。

### 2.2 合理的平均负载数

最理想的情况：平均负载是等于 CPU 个数。太高了表示有进程获取不到 CPU 资源，太低了表示 CPU 利用率不高。

**获取CPU 逻辑核数**：

1. `grep 'model name' /proc/cpuinfo | wc -l`
2. top 命令

**系统负载趋势**：平均负载数的三个值都需要关注，以此来判断系统负载变化趋势，从而让我们能更全面、更立体地理解目前的负载状况。

1. 如果三个值相同或者差距不大，表示系统负载平稳。
2. 但如果 1 分钟的值远小于 15 分钟的值，就说明系统最近 1 分钟的负载在减少，而过去15 分钟内却有很大的负载。
3. 如果 1 分钟的值远大于 15 分钟的值，就说明最近 1 分钟的负载在增加，这种增加有可能只是临时性的，也有可能还会持续增加下去，所以就需要持续观察。

**实际生产环境中，如何监控平均负载数**：

1. 当平均负载高于 CPU 数量 70% 的时候，你就应该分析排查负载高的问题了。一旦负载过高，就可能导致进程响应变慢，进而影响服务的正常功能。
2. 最佳做法：把系统的平均负载监控起来，然后根据更多的历史数据，判断负载的变化趋势。当发现负载有明显升高趋势时，比如说负载翻倍了，再去做分析和调查。

### 2.3 平均负载数不等同于 CPU 利用率

原因：平均负载数统计的不仅包括了正在使用 CPU 的进程，还包括等待 CPU 和等待I/O 的进程。

1. CPU 密集型进程，使用大量 CPU 会导致平均负载升高，此时这两者是一致的。
2. I/O 密集型进程，等待 I/O 也会导致平均负载升高，但 CPU 使用率不一定很高。
3. 大量等待 CPU 的进程调度也会导致平均负载升高，此时的 CPU 使用率也会比较高。

### 2.4 案例分析

准备工作：

1. 机器配置：2 CPU，8GB 内存。
2. 使用 `sudo su root` 切换到 root 用户。
3. 预先安装 stress 和 sysstat 包
   1. stress 是一个 Linux 系统压力测试工具
   2. sysstat 包含了常用的 Linux 性能工具，用来监控和分析系统的性能。比如：
      1. `mpstat`：多核 CPU 性能分析工具，用来实时查看每个 CPU 的性能指标，以及所有 CPU 的平均指标。
      2. `pidstat`：进程性能分析工具，用来实时查看进程的 CPU、内存、I/O 以及上下文切换等性能指标。
4. 记录压测前的 `uptime` 数据。

#### CPU 密集型

1 记录压测前的 `uptime` 数据。

```shell
uptime

# 结果
16:47:19 up  2:14,  3 users,  load average: 0.22, 0.12, 0.15
```

2 在第一个终端运行 stress 命令，模拟一个 CPU 使用率 100% 的场景。

```shell
stress --cpu 1 --timeout 600
```

3 在第二个终端运行 uptime 查看平均负载的变化情况。

```shell
# `-d` 参数表示高亮显示变化的区域。
watch -d uptime

# 结果，经过一段时间，平均负载数接近 1
16:49:14 up  2:16,  3 users,  load average: 0.91, 0.42, 0.26
```

4 在第三个终端运行 mpstat 查看 CPU 使用率的变化情况。

```shell
# -P ALL 表示监控所有 CPU，后面数字 5 表示间隔 5 秒后输出一组数据
mpstat -P ALL 5

# 如果有一个进程的 CPU 使用率为很高，但它的 iowait 很低。这说明，平均负载的升高正是由于 CPU 使用率为太高 。
```

5 pidstat 来查询哪个进程导致了 CPU 使用率为 100%。

```shell
# 间隔 5 秒后输出一组数据
pidstat -u 5 1
```

#### IO 密集型

1 记录压测前的 `uptime` 数据。

```shell
uptime
```

2 在第一个终端运行 stress 命令，模拟 I/O 压力，即不停地执行 sync。

```shell
stress -i 1 --timeout 600
```

>stress 模拟 io 密集型任务原理：stress使用的是 `sync()` 系统调用，它的作用是刷新缓冲区内存到磁盘中。对于新安装的虚拟机，缓冲区可能比较小，无法产生大的 IO 压力，这样大部分就都是系统调用的消耗了。所以，你会看到只有系统 CPU 使用率升高。解决方法是使用 stress 的下一代 `stress-ng`，它支持更丰富的选项，比如 `stress-ng -i 1 --hdd 1 --timeout 600`（--hdd表示读写临时文件）。

3 在第二个终端运行 uptime 查看平均负载的变化情况。

```shell
# `-d` 参数表示高亮显示变化的区域。
watch -d uptime

# 经过一段时间，可以发现平均负载数会升高到接近 1
```

4 在第三个终端运行 mpstat 查看 CPU 使用率的变化情况。

```shell
# -P ALL 表示监控所有 CPU，后面数字 5 表示间隔 5 秒后输出一组数据，数字 20 表示观察 20 次。
mpstat -P ALL 5 20

# 分析结果：如果有一个进程的 CPU 使用率较高，而且它的 iowait 也很高。这说明，很有可能平均负载的升高是由于 iowait 的升高引起的。
```

5 pidstat 来查询哪个进程的 io_wait 高。

```shell
# 间隔 5 秒后输出一组数据
pidstat -u 5 1

# 或者直接查看 io 情况
pidstat -d
```

#### 大量进程的场景

1 记录压测前的 `uptime` 数据。

```shell
uptime
```

2 在第一个终端运行 stress 命令，模拟的是 8 个进程。

```shell
stress -c 8 --timeout 600
```

3 在第二个终端运行 uptime 查看平均负载的变化情况。

```shell
# `-d` 参数表示高亮显示变化的区域。
watch -d uptime

# 经过一段时间，可以发现，由于系统中的 8 个进程明显比 CPU 核数要多得多，因而，系统的 CPU 处于严重过载状态
16:54:23 up  2:21,  3 users,  load average: 4.82, 1.53, 0.67
```

4 在第三个终端运行 pidstat 来看一下进程的情况

```shell
# 间隔 5 秒后输出一组数据
pidstat -u 5 1

# 分析结果：8 个进程在争抢 CPU，每个进程等待 CPU 的时间（也就是 %wait 列）会变得很高。这些超出 CPU 计算能力的进程，最终导致 CPU 过载。
```

>如果 pidstat 输出中没有 %wait 项，是因为 CentOS 默认的 sysstat 稍微有点老，源码或者 RPM 升级到 11.5.5 版本以后就可以看到了。而 Ubuntu 的包一般都比较新，没有这个问题。

### 2.5 扩展学习

- 掌握 uptime 和 top 命令使用与分析。
  - [了解你服务器的心情——top命令详解](https://www.jianshu.com/p/aae6ee900d2e)
  - [top命令详解](https://www.jianshu.com/p/078ed7895b0f)
- 掌握 stress 或 [stress-ng](https://kernel.ubuntu.com/~cking/stress-ng/) 工具的使用。
  - [Linux 压力测试软件 Stress 使用指南](https://www.hi-linux.com/posts/59095.html)
  - [压力测试神器stress-ng](https://cloud.tencent.com/developer/article/1513544)
  - 这些工具主要用于模拟系统过载的情况，可用于验证我们的系统过载预警机制是否有效。
- 掌握 sysstat 工具的使用，掌握 mpstat 和 pidstart 命令的使用。
  - [sysstat github](https://github.com/sysstat/sysstat)
  - [sysstat性能监控工具包中20个实用命令](https://linux.cn/article-4028-1.html)
  - [mpstat 使用介绍和输出参数详解](https://wsgzao.github.io/post/mpstat/)
  - [Linux pidstat命令详解](https://www.jellythink.com/archives/444)

其分析法方案：

1. atop 命令
2. htop 命令
3. 一些公司的服务器安全级别较高，无法安装 sysstat 工具，此时可使用 top、ps、lsof 命令分析。

扩展阅读：[Linux Load Averages: Solving the Mystery](http://www.brendangregg.com/blog/2017-08-08/linux-load-averages.html)

---

## 3-什么是上下文切换

大量进程的场景也会导致系统变慢，原因是因为系统需要对大量的进程进行调用，从而导致频繁的上下文切换。

### 3.1 什么是上下文与上下文切换

每个任务运行前，CPU 都需要知道任务从哪里加载、又从哪里开始运行，也就是说，需要系统事先帮它设置好 CPU 寄存器和程序计数器（Program Counter，PC）。

- CPU 寄存器，是 CPU 内置的容量小、但速度极快的内存。
- 程序计数器，是用来存储 CPU 正在执行的指令位置、或者即将执行的下一条指令位置。

**上下文**：CPU 寄存器和程序计数器都是 CPU 运行任何程序前必须依赖的环境，被被统称为上下文。

**上下文切换**：先把前一个任务的 CPU 上下文（也就是 CPU 寄存器和程序计数器）保存起来，然后加载新任务的上下文到这些寄存器和程序计数器，最后再跳转到程序计数器所指的新位置，运行新任务。

根据不同场景上下文切换具体分为：

1. 进程上下文切换
2. 线程上下文切换
3. 中断上下文切换

### 3.2 进程上下文切换、线程上下文切换、中断上下文切换

**特权模式切换**：系统调用过程发生的上下文切换

1. Linxu 将运行空间分为内核空间和用户空间。
2. 进程可以在这两个空间运行，进程在用户空间运行时，被称为进程的用户态，而陷入内核空间的时候，被称为进程的内核态。
3. 当进程在用户空间触发系统调用，就会发生 CPU 上下文的切换。
4. 一次系统调用的过程，发生了两次 CPU 上下文切换，从用户态陷入内核态，然后调用完毕重新回到用户态。
5. 系统调用是发生在单个进程的，没有涉及到进程切换。

**进程上下文切换**：

1. 进程上下文切换，是指从一个进程切换到另一个进程运行。
2. 进程的上下文不仅包括了虚拟内存、栈、全局变量等用户空间的资源，还包括了内核堆栈、寄存器等内核空间的状态。

**线程上下文切换**：线程是调度的基本单位，而进程则是资源拥有的基本单位。

1. 当发生线程切换时，如果前后两个线程属于不同进程。此时，因为资源不共享，所以切换过程就跟进程上下文切换是一样。
2. 当发生线程切换时，如果前后两个线程属于同一个进程。此时，因为虚拟内存是共享的，所以在切换时，虚拟内存这些资源就保持不动，只需要切换线程的私有数据、寄存器等不共享的数据。

**中断上下文切换**：

1. 为了快速响应硬件的事件，中断处理会打断进程的正常调度和执行，转而调用中断处理程序，响应设备事件。
2. 中断上下文切换并不涉及到进程的用户态，不涉及用户态的虚拟内存、全局变量等资源的保存会恢复，中断上下文切换，只包括内核态中断服务程序执行所必需的状态，包括 CPU 寄存器、内核堆栈、硬件中断参数等。
3. 对同一个 CPU 来说，中断处理比进程拥有更高的优先级。中断上下文切换不会与进程上下文切换同时发生。

**进程上下文切换对 CPU 的消耗：**

1. [Tsuna](https://blog.tsunanet.net/2010/11/how-long-does-it-take-to-make-context.html) 报告中说到每次上下文切换都需要几十纳秒到数微秒的 CPU 时间。如果上下文切换次数较多，那么 CPU 的大量时间会消耗在寄存器、内核栈以及虚拟内存等资源的保存和恢复上。而真正的进程运行时间就会变少。
2. Linux 通过 TLB（Translation Lookaside Buffer）来管理虚拟内存到物理内存的映射关系。当虚拟内存更新后，TLB 也需要刷新，内存的访问也会随之变慢。

**触发上下文切换的时机**（排查上下文切换的性能问题的切入点）：

1. 当某个进程的时间片耗尽了，就会被系统挂起，切换到其它正在等待 CPU 的进程运行。
2. 进程在系统资源不足时，需要等待资源满足时才能运行，此时进程被挂起，转而执行其他进程。
3. 进程主动挂起，比如调用 sleep 函数。
4. 有优先级更高的进程需要运行时，系统可能挂起当前进程，转而执行高优先级进程。
5. 发生硬件中断时，CPU 上的进程会被中断挂起，转而执行内核中的中断服务程序。

---

## 4-上下文切换调优

### 4.1 上下文切换查询工具

#### vmstat

vmstat 是一个常用的系统性能分析工具，主要用来分析系统的内存使用情况，也常用来分析 CPU 上下文切换和中断的次数。不过 vmstat 只给出了系统总体的上下文切换情况。

```shell
# 间隔一秒后输出 1 组数据，输出 1 次
vmstat 1 1

# 输出
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  0      0 440116 134892 1178416    0    0    10    21  128  282  1  0 98  0  0
```

- cs（context switch）是每秒上下文切换的次数。
- in（interrupt）则是每秒中断的次数。
- r（Running or Runnable）是就绪队列的长度，也就是正在运行和等待 CPU 的进程数。
- b（Blocked）则是处于不可中断睡眠状态的进程数。
- us（user） + sy（system）表示 CPU 使用率，us 表示用户 CPU 使用率，sy 表示系统 CPU 使用率。

#### pidstat

通过 pidstat 可以查看每个进程的详细情况：

```shell
# 每 5 秒输出一次，-w 表示输出上下文切换，具体查看 man 手册。
pidstat -w 5
Linux 4.15.0-88-generic (VM-0-7-ubuntu) 	04/02/2020 	_x86_64_	(1 CPU)

# 输出结果
03:37:44 PM   UID       PID   cswch/s nvcswch/s  Command
03:37:49 PM     0         7      0.80      0.00  ksoftirqd/0
03:37:49 PM     0         8      8.43      0.00  rcu_sched
03:37:49 PM     0        11      0.40      0.00  watchdog/0
03:37:49 PM     0       317      1.00      0.00  kworker/0:1H
03:37:49 PM     0       336      0.60      0.20  jbd2/vda1-8
03:37:49 PM     0       564      2.21      0.00  kworker/0:2
03:37:49 PM   111      1087      1.00      0.00  ntpd
03:37:49 PM     0      1161      3.41      0.00  YDService
03:37:49 PM     0      1440      0.20      0.00  barad_agent
03:37:49 PM     0      1446      1.41      0.20  barad_agent
03:37:49 PM     0      1487      2.01      0.00  YDLive
03:37:49 PM     0     28605      2.41      0.00  kworker/u2:2
03:37:49 PM     0     31163      3.82      0.00  kworker/u2:1
03:37:49 PM   500     31470      0.20      0.20  pidstat

# 每隔1秒输出一组数据（需要 Ctrl+C 才结束）# -wt 参数表示输出线程的上下文切换指标
pidstat -wt 1

# 输出结果
Linux 4.15.0-88-generic (VM-0-7-ubuntu) 	04/02/2020 	_x86_64_	(1 CPU)

03:43:23 PM   UID      TGID       TID   cswch/s nvcswch/s  Command
03:43:28 PM     0         7         -      0.80      0.00  ksoftirqd/0
03:43:28 PM     0         -         7      0.80      0.00  |__ksoftirqd/0
03:43:28 PM     0         8         -      9.38      0.00  rcu_sched
03:43:28 PM     0         -         8      9.38      0.00  |__rcu_sched
03:43:28 PM     0        11         -      0.20      0.00  watchdog/0
03:43:28 PM     0         -        11      0.20      0.00  |__watchdog/0
03:43:28 PM     0       317         -      1.00      0.00  kworker/0:1H
03:43:28 PM     0         -       317      1.00      0.00  |__kworker/0:1H
03:43:28 PM     0       336         -      0.60      0.20  jbd2/vda1-8
03:43:28 PM     0         -       336      0.60      0.20  |__jbd2/vda1-8
03:43:28 PM     0       564         -      2.20      0.00  kworker/0:2
03:43:28 PM     0         -       564      2.20      0.00  |__kworker/0:2
03:43:28 PM     0         -      1008      0.20      0.00  |__gmain
03:43:28 PM   111      1087         -      1.00      0.00  ntpd
03:43:28 PM   111         -      1087      1.00      0.00  |__ntpd
03:43:28 PM     0      1161         -      3.39      0.00  YDService
03:43:28 PM     0         -      1161      3.39      0.00  |__YDService
03:43:28 PM     0         -      1248      3.39      0.00  |__YDService
03:43:28 PM     0         -      1249     10.18      0.00  |__YDService
03:43:28 PM     0         -      1250      1.00      0.00  |__YDService
03:43:28 PM     0         -      1571      2.00      0.00  |__YDService
03:43:28 PM     0         -      1572      1.00      0.00  |__YDService
03:43:28 PM     0         -      1586      9.98      0.00  |__YDService
03:43:28 PM     0         -      1592      1.00      0.00  |__YDService
03:43:28 PM     0         -      1594      1.00      0.00  |__YDService
03:43:28 PM     0         -      1595      1.40      0.00  |__YDService
```

输出结果说明：

- cswch：**每秒自愿上下文切换**（voluntary context switches）的次数，指进程无法获取所需资源，导致的上下文切换。比如说， I/O、内存等系统资源不足时，就会发生自愿上下文切换。
- nvcswch：**每秒非自愿上下文切换**（non voluntary context switches）的次数，指进程由于时间片已到等原因，被系统强制调度，进而发生的上下文切换。比如说，大量进程都在争抢 CPU 时，就容易发生非自愿上下文切换。

### 4.2 案例分析

准备工作：

1. 机器配置：2 CPU，8GB 内存。
2. 使用 `sudo su root` 切换到 root 用户。
3. 安装 sysbench，sysbench 是一个多线程的基准测试工具，一般用来评估不同系统参数下的数据库负载情况。
4. 安装 sysstat。

1 记录空闲系统的上下文切换次数

```shell
mpstat
```

2 在第一个终端使用 sysbench 模拟多线程抢占 cpu 情况

```shell
# 以10个线程运行5分钟的基准测试，模拟多线程切换的问题
sysbench --threads=10 --max-time=300 threads run
```

>如果在 centos 上，测试程序过快结束，可能是因为 max-requests 太低，可以尝试：`sysbench --num-threads=10 --max-time=300 --max-requests=10000000 --test=threads run`

3 在第二个终端运行 vmstat ，观察上下文切换情况

```shell
# 每隔一秒输出一次
mpstat 1

# 结果
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 8  0      0 420680 135288 1186996    0    0    10    22  128  150  1  0 98  0  0
 8  0      0 420300 135288 1186996    0    0     0     0  334 844335  8 92  0  0  0
 8  0      0 420332 135288 1186996    0    0     0     0  329 843521  3 97  0  0  0
 9  0      0 420356 135288 1186972    0    0     0    40  312 846513  9 91  0  0  0
 8  0      0 420356 135288 1186972    0    0     0     4  324 849790  6 94  0  0  0

#  分析
#
#     r 列：就绪队列的长度已经到了 8，远远超过了系统 CPU 的个数，所以肯定会有大量的 CPU 竞争。
#     us 和 sy列：这两列的 CPU 使用率加起来上升到了 100%，且 sy 列高达 90% 多，说明 CPU 主要是被内核占用了。
#     in 列：中断次数也上升了很多，说明中断处理也是个潜在的问题。
```

4 在第三个终端使用 pidstat 查看 cpu 和上下文切换情况

```shell
# 每隔1秒输出1组数据（需要 Ctrl+C 才结束）
# -w参数表示输出进程切换指标，-u参数则表示输出CPU使用指标
pidstat -w -u 1

# 输出结果
04:07:50 PM   UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
04:07:51 PM   500      3395    8.00   91.00    0.00    0.00   99.00     0  sysbench
04:07:51 PM   500      3418    0.00    1.00    0.00    1.00    1.00     0  pidstat

04:07:50 PM   UID       PID   cswch/s nvcswch/s  Command
04:07:51 PM     0         7      1.00      0.00  ksoftirqd/0
04:07:51 PM     0         8      7.00      0.00  rcu_sched
04:07:51 PM     0       564      2.00      0.00  kworker/0:2
04:07:51 PM   500       620    223.00      1.00  sshd
04:07:51 PM   111      1087      1.00      0.00  ntpd
04:07:51 PM     0      1161      3.00      0.00  YDService
04:07:51 PM     0      1487      2.00      0.00  YDLive
04:07:51 PM   500      3418      1.00    224.00  pidstat
04:07:51 PM     0     28605    230.00      0.00  kworker/u2:2

# 分析
#     sysbench 占用 cpu 接近 100%，而上下文切换次数却来其他进程。
#     上下文切换次数较高的有资源切换的内核线程：kworker 和 sshd，有非自愿切换的 pidstat。
#     但是目前所有上下文切换次数加起来也远远少于 mpstat 统计的几十万次，原因在于：Linux 调度的基本单位实际上是线程，而我们的场景 sysbench 模拟的也是线程的调度问题。
```

5 重新使用 pidstat 查看线程山下文切换次数

```shell
pidstat -wt 1

# 输出
04:09:03 PM     0         -      1595      2.00      0.00  |__YDService
04:09:03 PM     0      1446         -      3.00      0.00  barad_agent
04:09:03 PM     0         -      1446      3.00      0.00  |__barad_agent
04:09:03 PM     0         -      1458     28.00      0.00  |__barad_agent
04:09:03 PM     0         -      1463      2.00      0.00  |__barad_agent
04:09:03 PM     0         -      3590     14.00      5.00  |__barad_agent
04:09:03 PM     0      1487         -      3.00      0.00  YDLive
04:09:03 PM     0         -      1487      3.00      0.00  |__YDLive
04:09:03 PM     0         -      1495      1.00      0.00  |__YDLive
04:09:03 PM     0      2926         -    861.00      0.00  kworker/u2:1
04:09:03 PM     0         -      2926    861.00      0.00  |__kworker/u2:1
04:09:03 PM   500         -      3396  13537.00  66513.00  |__sysbench
04:09:03 PM   500         -      3397  13426.00  69081.00  |__sysbench
04:09:03 PM   500         -      3398  13842.00  68874.00  |__sysbench
04:09:03 PM   500         -      3399   7549.00  76193.00  |__sysbench
04:09:03 PM   500         -      3400  10931.00  66423.00  |__sysbench
04:09:03 PM   500         -      3401  17392.00  64266.00  |__sysbench
04:09:03 PM   500         -      3402  12121.00  66632.00  |__sysbench
04:09:03 PM   500         -      3403  12891.00  69142.00  |__sysbench
04:09:03 PM   500         -      3404  16709.00  65988.00  |__sysbench
04:09:03 PM   500         -      3405  11012.00  71664.00  |__sysbench

# 通过数据可以发现，有多个 __sysbench 线程导致了大量的上下文切换
```

6 分析中断次数为何上升

- 获取中断使用情况：读取`/proc/interrupts`文件，`/proc` 实际上是 Linux 的一个虚拟文件系统，用于内核空间与用户空间之间的通信。`/proc/interrupts` 就是这种通信机制的一部分，提供了一个只读的中断使用情况。

```shell
# -d 参数表示高亮显示变化的区域
watch -d cat /proc/interrupts
```

发现问题：

1. 变化速度最快的是重调度中断（RES）
2. 重调度中断表示：唤醒空闲状态的 CPU 来调度新的任务运行。这是多处理器系统（SMP）中，调度器用来分散任务到不同 CPU 的机制，通常也被称为处理器间中断（Inter-Processor Interrupts，IPI）。**（注意，在单核 CPU 的机器上不会有这种情况）**。
3. 结论：这里的中断升高还是因为过多任务的调度问题，跟前面上下文切换次数的分析结果是一致的。

### 3.3 合理的上下文切换次数

1. 具体数值其实取决于系统本身的 CPU 性能。
2. 系统的上下文切换次数比较稳定，那么从数百到一万以内，都应该算是正常的。
3. 上下文切换次数超过一万次，或者切换次数出现数量级的增长时，就很可能已经出现了性能问题。

根据上下文切换类型，可以出版判断是什么导致了性能问题

1. 自愿上下文切换变多了，说明进程都在等待资源，有可能发生了 I/O 等其他问题。
2. 非自愿上下文切换变多了，说明进程都在被强制调度，也就是都在争抢 CPU，说明 CPU 的确成了瓶颈；
3. 中断次数变多了，说明 CPU 被中断处理程序占用，需要通过查看 `/proc/interrupts` 文件来分析具体的中断类型。

### 3.4 扩展

1. stress基于多进程的，会fork多个进程，导致进程上下文切换，导致us开销很高；
2. sysbench基于多线程的，会创建多个线程，单一进程基于内核线程切换，导致sy的内核开销很高；

---

## 5-CPU使用率

描述系统的 CPU 性能最常用的指标是CPU 使用率，而不是平均负载或者 CPU 上下文切换。

### 5.1 什么是 CPU 使用率

CPU 使用率是单位时间内 CPU 使用情况的统计，以百分比的方式展示。

**内核时钟频率：CONFIG_HZ**：

1. Linux 是一个多任务分时调度系统，即把 CPU 的运行分成若干时间片分别处理不同的运算请求。
2. Linux 通过定义的节拍率（HZ）来维护 CPU 时间，该值在内核中定义为 CONFIG_HZ，表示一秒内触发多少个时间中断。
3. CONFIG_HZ 的数值是内核可配选型，可以设置为  100、250、1000 等，通过查询 `/boot/config` 内核选项来查看它的配置值：`grep 'CONFIG_HZ=' /boot/config-$(uname -r)`。
4. 如果 CONFIG_HZ 为 250，则表示每 4ms 发生一次时钟中断，每秒发生 250 次。可以通过提高该参数增加系统的实时性，但同时会导致过多的时间花费在中断处理中。
5. 全局变量 Jiffies 记录了开机以来的节拍数。每发生一次时间中断，Jiffies 的值就加 1。

**用户空间节拍率 USER_HZ**：

1. 节拍率是内核选项，用户空间无法访问，为了方便用户空间程序，内核提供了一个用户空间节拍率 USER_HZ，它总是固定为 100，也就是 `1/100` 秒，即 10ms。
2. 可以通过 `getconf CLK_TCK` 命令获取 USER_HZ 的值，也可以在 C 语言中通过 `sysconf(_SC_CLK_TCK)` 获得。

具体参考：

- [Kernel 系统时钟](https://jin-yang.github.io/post/linux-kernel-timer.html)
- [CONFIG_HZ 和 USER_HZ](http://blog.chinaunix.net/uid-24774106-id-3877992.html)

### 5.2 CPU使用率的计算

`/proc` 虚拟文件系统，向用户空间提供了系统内部状态的信息，其中 `/proc/stat` 提供是系统的 CPU 和任务统计信息。

```shell
# grep ^cpu 表示只查看 cpu 相关信息
cat /proc/stat | grep ^cpu

# 输出
#       us   ni    sys      id    wa hi si st guest gnice
cpu  99105 1036 127483 9883680 35290 0 958 0      0    0
cpu0 99105 1036 127483 9883680 35290 0 958 0      0    0

# 第一列表示 cpu 编号。其他列表示不同场景下 CPU 的累加节拍数。单位为 USER_HZ。
# 第一行 cpu 数据，表示所有 cpu 数据累加
# cpu0 表示第一个 cpu 的数据，由于只有一个 cpu，所以它们的值相等。
```

每一列所表示的意义可以通过 man proc 查看，或者参考在线文档 <http://man7.org/linux/man-pages/man5/proc.5.html>，搜索 `/proc/stat` 可以快速定位到。

从第 2 列到最后一列（一共 10 列），含义分别为：

1. user（通常缩写为 us），代表用户态 CPU 时间。不包括下面的 nice 时间，但包括了 guest 时间。
2. nice（通常缩写为 ni），代表低优先级用户态 CPU 时间，也就是进程的 nice 值被调整为 1-19 之间时的 CPU 时间。nice 可取值范围是 -20 到 19，数值越大，优先级反而越低。
3. system（通常缩写为 sys），代表内核态 CPU 时间。
4. idle（通常缩写为 id），代表空闲时间。它不包括等待 I/O 的时间（iowait）。
5. iowait（通常缩写为 wa），代表等待 I/O 的 CPU 时间。
6. irq（通常缩写为 hi），代表处理硬中断的 CPU 时间。
7. softirq（通常缩写为 si），代表处理软中断的 CPU 时间。
8. steal（通常缩写为 st），代表当系统运行在虚拟机中的时候，被其他虚拟机占用的CPU 时间。
9. guest（通常缩写为 guest），代表通过虚拟化运行其他操作系统的时间，也就是运行虚拟机的 CPU 时间。
10. guest_nice（通常缩写为 gnice），代表以低优先级运行虚拟机的时间。

**CPU 使用率计算公式**：

```shell
CPU 使用率 = 1 - (空闲时间/总 CPU 时间)
```

空闲时间和总 CPU 时间可以从 `/proc/stat` 文件中计算获取，比如 `USER_HZ=100` 即表示每 10ms 切换一次，则`总时间 = 10ms * 次数`，但是直接使用某个时刻的数据进行计算没有意义，就好像用拍摄一张汽车运行的照片，然后求它当时的运行速度一样。

为了计算 CPU 使用率的准确性，性能工具一般都会取间隔一段时间（比如 3 秒）的两次值，作差后，再计算出这段时间内的平均 CPU 使用率：

```shell
平均 CPU 使用率 = 1 - ( (新时刻空闲时间 - 旧时刻空闲时间) / (新时刻总 CPU 时间 - 旧时刻总 CPU 时间))
```

**单独进程的运行统计信息**：`/proc/stat` 中统计的是系统 CPU 的运行信息，如果要单独查看进行的运行信息，可以查看 `/proc/pid/stat` 中的数据，其提供了多达 52 项数据，可以参考在线文档 <http://man7.org/linux/man-pages/man5/proc.5.html>，搜索 `/proc/[pid]/stat` 可以快速定位到。

总计：**性能分析工具给出的都是间隔一段时间的平均 CPU 使用率，所以要注意间隔时间的设置**。

- top 默认使用 3 秒时间间隔来计算。
- ps 使用进程的整个生命周期计算。

### 5.3 如何查看 CPU 使用率

1 **top 命令**：

- top 可以查看系统总体的 CPU 和内存使用情况，以及各个进程的资源使用情况。默认每 3 秒刷新一次。
- top 默认显示的是所有 CPU 的平均值，按下数字 1 ，可以切换到每个 CPU 的使用率。
- top 没有细分进程的用户态 CPU 和内核态 CPU。

```shell
# 负载情况
top - 11:19:49 up 1 day, 20:46,  1 user,  load average: 0.05, 0.02, 0.00
# 任务队列
Tasks:  87 total,   1 running,  49 sleeping,   0 stopped,   0 zombie
# cpu 使用率
%Cpu(s):  0.7 us,  0.3 sy,  0.0 ni, 98.7 id,  0.3 wa,  0.0 hi,  0.0 si,  0.0 st
# 内存信息
KiB Mem :  1877076 total,    96460 free,   128912 used,  1651704 buff/cache
KiB Swap:        0 total,        0 free,        0 used.  1555560 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
 1161 root      20   0  644612  18020   6812 S  0.3  1.0   3:25.13 YDService
23840 ubuntu    20   0   41012   3820   3276 R  0.3  0.2   0:00.03 top
    1 root      20   0   78060   9012   6560 S  0.0  0.5   0:07.49 systemd
    2 root      20   0       0      0      0 S  0.0  0.0   0:00.01 kthreadd
    4 root       0 -20       0      0      0 I  0.0  0.0   0:00.00 kworker/0:0H
    6 root       0 -20       0      0      0 I  0.0  0.0   0:00.00 mm_percpu_wq
    7 root      20   0       0      0      0 S  0.0  0.0   0:04.74 ksoftirqd/0
    8 root      20   0       0      0      0 I  0.0  0.0   0:13.04 rcu_sched
    9 root      20   0       0      0      0 I  0.0  0.0   0:00.00 rcu_bh
   10 root      rt   0       0      0      0 S  0.0  0.0   0:00.00 migration/0
   11 root      rt   0       0      0      0 S  0.0  0.0   0:00.37 watchdog/0
   12 root      20   0       0      0      0 S  0.0  0.0   0:00.00 cpuhp/0
   13 root      20   0       0      0      0 S  0.0  0.0   0:00.00 kdevtmpfs
   14 root       0 -20       0      0      0 I  0.0  0.0   0:00.00 netns
   15 root      20   0       0      0      0 S  0.0  0.0   0:00.00 rcu_tasks_kthre
   16 root      20   0       0      0      0 S  0.0  0.0   0:00.00 kauditd
   17 root      20   0       0      0      0 S  0.0  0.0   0:00.03 khungtaskd
   18 root      20   0       0      0      0 S  0.0  0.0   0:00.00 oom_reaper
   19 root       0 -20       0      0      0 I  0.0  0.0   0:00.00 writeback
   20 root      20   0       0      0      0 S  0.0  0.0   0:00.00 kcompactd0
   21 root      25   5       0      0      0 S  0.0  0.0   0:00.00 ksmd
   22 root      39  19       0      0      0 S  0.0  0.0   0:00.00 khugepaged
   23 root       0 -20       0      0      0 I  0.0  0.0   0:00.00 crypto
   24 root       0 -20       0      0      0 I  0.0  0.0   0:00.00 kintegrityd
   25 root       0 -20       0      0      0 I  0.0  0.0   0:00.00 kblockd
   26 root       0 -20       0      0      0 I  0.0  0.0   0:00.00 ata_sff
   27 root       0 -20       0      0      0 I  0.0  0.0   0:00.00 md
   28 root       0 -20       0      0      0 I  0.0  0.0   0:00.00 edac-poller
   29 root       0 -20       0      0      0 I  0.0  0.0   0:00.00 devfreq_wq
```

cpu 使用率参数说明：

- `us` 用户进程占用 cpu 百分率
- `sy` 系统占用 cpu 百分率
- `ni` 用户进程空间内改变过优先级的进程占用 CPU 百分比
- `id` cpu 空闲率
- `wa` 等待 IO 的 CPU 时间百分比
- `hi` 硬中断（Hardware IRQ）占用 CPU 的百分比
- `si` 软中断（Software Interrupts）占用 CPU 的百分比

各个进程的资源使用情况参考说明：

- `PID` 进程 ID
- `USER` 进程创建者
- `PR` 进程优先级
- `NI` nice值，越小优先级越高，最小-20，最大20（用户设置最大19）
- `VIRT` 进程使用的虚拟内存总量，单位kb
- `RES` 进程使用的、未被换出的物理内存大小，单位kb
- `SHR` 共享内存大小，单位kb
- `S` 进程状态：D=不可中断的睡眠状态 R=运行 S=睡眠 T=跟踪/停止 Z=僵尸进程
- `%CPU` 进程占用cpu百分比，是用户态和内核态 CPU 使用率的总和，包括进程用户空间使用的 CPU、通过系统调用执行的内核空间 CPU 、以及在就绪队列等待运行的 CPU。在虚拟化环境中，它还包括了运行虚拟机占用的 CPU。
- `%MEN` 进程占用内存百分比
- `TIME+` 进程运行时间
- `COMMAND` 进程名称

各个参数具体含义，参考下面链接：

- [了解你服务器的心情——top命令详解](https://www.jianshu.com/p/aae6ee900d2e)
- [top命令详解](https://www.jianshu.com/p/078ed7895b0f)

2 **ps 命令**：

3 **pidstat 命令**：

- pidstat 可以查看每个进程的详细情况。

```shell
pidstat 1 5

Linux 4.15.0-88-generic (VM-0-7-ubuntu) 	04/03/2020 	_x86_64_	(1 CPU)

11:47:03 AM   UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
11:47:04 AM     0     24264    0.00    1.00    0.00    0.00    1.00     0  kworker/u2:0

11:47:04 AM   UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
11:47:05 AM   500     23828    0.00    0.99    0.00    0.00    0.99     0  sshd

11:47:05 AM   UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
11:47:06 AM     0      1447    0.00    1.01    0.00    0.00    1.01     0  barad_agent

11:47:06 AM   UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
11:47:07 AM   500     27406    0.00    1.00    0.00    0.00    1.00     0  pidstat

11:47:07 AM   UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
11:47:08 AM     0      1161    0.00    1.02    0.00    0.00    1.02     0  YDService
11:47:08 AM     0      1447    2.04    0.00    0.00    0.00    2.04     0  barad_agent
11:47:08 AM   500     27406    1.02    0.00    0.00    0.00    1.02     0  pidstat

# 上面 5 组数据的平均值
Average:      UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
Average:        0      1161    0.00    0.20    0.00    0.00    0.20     -  YDService
Average:        0      1447    0.40    0.20    0.00    0.00    0.60     -  barad_agent
Average:      500     23828    0.00    0.20    0.00    0.00    0.20     -  sshd
Average:        0     24264    0.00    0.20    0.00    0.00    0.20     -  kworker/u2:0
Average:      500     27406    0.20    0.20    0.00    0.00    0.40     -  pidstat
```

各个参数说明：

- `%usr` 用户态 CPU 使用率
- `%system` 内核态 CPU 使用率
- `%guest` 运行虚拟机 CPU 使用率
- `%wait` 等待 CPU 使用率
- `%CPU` 总的 CPU 使用率
- `CPU` 所在 CPU
- `Command` 进程名

### 5.4 CPU 使用率过高如何找到问题源头

1. **使用 GDB（The GNU Project Debugger）**：但是 GDB 并不适合在性能分析的早期应用，因为线上程序一般不允许调试，GDB 用于在利用其他工具找到大致的问题返回后，在线下进行调试，从而精确定位问题所在。
2. **使用 perf 性能分析工具**：perf 是 Linux2.6.31 以后内置的性能分析工具。它以性能事件采样为基础，不仅可以分析系统的各种事件和内核性能，还可以用来分析指定应用程序的性能问题。

使用 perf 分析 CPU 性能问题，有两种常用的方法：

1. perf top：可以实时显示占用 CPU 时钟最多的函数或者指令，因此可以用来查找热点函数，但是其并不保存数据，无法用于离线或后续分析。
2. perf record：提供了保存数据的功能，后期可以使用 perf record 解析展示。

**perf top 数据**：

```shell
# 第一行包含三个数据：
# Samples：采样数、event：件类型、Event count：件总数量
Samples: 288  of event 'cycles', Event count (approx.): 19207476

# 注意，如果上面采样数过少，则下面排序没有太多意义
#     Overhead：该符号的性能事件在所有采样中的比例，用百分比来表示。
#     Shared：该函数或指令所在的动态共享对象（Dynamic Shared Object），如内核、进程名、动态链接库名、内核模块名等。
#     Object：动态共享对象的类型。比如 [.] 表示用户空间的可执行程序、或者动态链接库，而 [k] 则表示内核空间。
#     Symbol：符号名，也就是函数名。当函数名未知时，用十六进制的地址来表示。
Overhead  Shared                 Object          Symbol
   7.02%  [kernel]               [k] update_blocked_averages
   3.29%  perf                   [.] map__process_kallsym_symbol
   2.76%  [kernel]               [k] kallsyms_expand_symbol.constprop.1
   2.23%  perf                   [.] rb_next
   2.11%  perf                   [.] hex2u64
   2.07%  python                 [.] PyEval_EvalFrameEx
   1.91%  [kernel]               [k] pvclock_clocksource_read
   1.89%  [kernel]               [k] memcpy
   1.83%  [kernel]               [k] __schedule
   1.62%  [kernel]               [k] native_write_msr
   1.26%  python                 [.] meth_dealloc
   1.07%  [kernel]               [k] switch_mm_irqs_off
   1.04%  [kernel]               [k] kfree
   1.01%  [kernel]               [k] update_curr
   0.99%  [kernel]               [k] async_page_fault
   0.98%  [kernel]               [k] rcu_cblist_dequeue
   0.98%  [kernel]               [k] kvm_clock_get_cycles
   0.95%  [kernel]               [k] perf_event_task_tick
   0.94%  [kernel]               [k] arch_cpu_idle_exit
   0.87%  libbfd-2.30-system.so  [.] 0x00000000000f509e
   0.87%  [kernel]               [k] set_next_entity
   0.86%  [kernel]               [k] dequeue_task_fair
   0.85%  [kernel]               [k] update_load_avg
   0.85%  [kernel]               [k] mutex_unlock
   0.83%  python                 [.] vgetargs1
   0.83%  [kernel]               [k] vunmap_page_range
   0.82%  [kernel]               [k] pick_next_task_fair
   0.81%  [kernel]               [k] irq_exit
```

从上面数据可以看出，整体上占用 CPU 最高的也只有 7%，不存在性能问题。

**perf record 数据**：

```shell
# 第一步：采集数据（Ctrl+C 终止采集）
perf record

# 第二步：展开报告
perf report
```

### 5.5 案例分析

todo
