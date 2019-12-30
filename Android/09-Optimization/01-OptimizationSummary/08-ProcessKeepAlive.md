# 进程保活

service是一个后台服务，专门用来处理常驻后台的工作的组件。

## 1 进程优先级

进程的重要性优先级：（越往后的就越容易被系统杀死）

1. 前台进程：Foreground process
   - 用户正在交互的Activity（onResume()）
   - 当某个Service绑定正在交互的Activity。
   - 被主动调用为前台Service（startForeground()）
   - 组件正在执行生命周期的回调（onCreate()/onStart()/onDestroy()）
   - BroadcastReceiver 正在执行onReceive();
2. 可见进程：isible process
   - 我们的Activity处在onPause()（没有进入onStop()）,比如一个Activity启动了一个对话框样式的Activity
   - 绑定到前台Activity的Service。
3. 服务进程：Service process，简单的startService()启动。
4. 后台进程：Background process，对用户没有直接影响的进程----Activity处于onStop()的时候。
5. 空进程：Empty process，不含有任何的活动的组件。（android设计的，为了第二次启动更快，采取的一个权衡）

具体参考[官方文档](https://developer.android.google.cn/guide/components/processes-and-threads.html?hl=zh-cn)。

## 2 系统怎么杀进程

Android 系统通过 LMK(LowMemoryKiller) 机制来决定哪些进程需要被回收。

- 进程的启动分冷启动和热启动，当用户退出某一个进程的时候，并不会真正的将进程退出，而是将这个进程放到后台，以便下次启动的时候可以马上启动起来，这个过程名为热启动，这也是 Android 的设计理念之一。这个机制会带来一个问题，每个进程都有自己独立的内存地址空间，随着应用打开数量的增多,系统已使用的内存越来越大，就很有可能导致系统内存不足。为了解决这个问题，系统引入 LowmemoryKiller (简称lmk)管理所有进程，根据一定策略来 kill 某个进程并释放占用的内存，保证系统的正常运行
- 所有应用进程都是从 zygote 孵化出来的，记录在 AMS 中 mLruProcesses 列表中，由 AMS 进行统一管理，AMS 中会根据进程的状态更新进程对应的 oom_adj 值，这个值会通过文件传递到 kernel 中去，kernel 有个低内存回收机制，在内存达到一定阀值时会触发清理 oom_adj 值高的进程腾出更多的内存空间。

## 3 如何提升进程的优先级（尽量做到不轻易被系统杀死）

### Activity提权

监控手机锁屏解锁事件，在屏幕锁屏时启动1个像素透明的 Activity，在用户解锁时将 Activity 销毁掉，从而达到提高进程优先级的作用。

### Service提权

创建一个前台服务用于提高 app 在按下 home 键之后（回到后台）的进程优先级：

```java
//使Service成为前台Service。 前台服务需要在通知栏显示一条通知
startForeground(ID,Notification)
```

具体参考[后台执行限制](https://developer.android.google.cn/about/versions/oreo/background#services)

### Service机制(Sticky)拉活

将 Service 设置为 START_STICKY，利用系统机制在 Service 挂掉后自动拉活。

```java
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_STICKY;
    }
```

各个选项说明:

- START_STICKY：“粘性”。如果service进程被kill掉，保留service的状态为开始状态，但不保留递送的intent对象。随后系统会尝试重新创建service，由于服务状态为开始状态，所以创建服务后一定会调用onStartCommand(Intent,int,int)方法。如果在此期间没有任何启动命令被传递到service，那么参数Intent将为null。
- START_NOT_STICKY：“非粘性的”。使用这个返回值时，如果在执行完onStartCommand后，服务被异常kill掉，系统不会自动重启该服务。
- START_REDELIVER_INTENT：重传Intent。使用这个返回值时，如果在执行完onStartCommand后，服务被异常kill掉，系统会自动重启该服务，并将Intent的值传入。
- START_STICKY_COMPATIBILITY：START_STICKY的兼容版本，但不保证服务被kill后一定能重启。

事实上，只要 targetSdkVersion 不小于5，就默认是 START_STICKY。但是某些ROM 系统不会拉活。并且经过测试，Service 第一次被异常杀死后很快被重启，第二次会比第一次慢，第三次又会比前一次慢，一旦在短时间内 Service 被杀死 4-5 次，则系统不再拉起。

### 广播拉活

在发生特定系统事件时，系统会发出广播，通过在 AndroidManifest 中静态注册对应的广播监听器，即可在发生响应事件时拉活。但是从 android 7.0 开始，对广播进行了限制，而且在 8.0 更加严格。

具体参考：

- [后台执行限制](https://developer.android.google.cn/about/versions/oreo/background#broadcasts)
- [可静态注册广播列表](https://developer.android.google.cn/guide/components/broadcast-exceptions.html)

### 账户同步拉活

手机系统设置里会有“帐户”一项功能，任何第三方APP都可以通过此功能将数据在一定时间内同步到服务器中去。系统在将APP帐户同步时，会将未启动的APP进程拉活。

### “全家桶”拉活

监听QQ,微信，系统应用，友盟，小米推送等等的广播，然后把自己启动了。

### JobScheduler拉活

JobScheduler允许在特定状态与特定时间间隔周期执行任务。可以利用它的这个特点完成保活的功能,效果即开启一个定时器，与普通定时器不同的是其调度由系统完成。

### 推送拉活

接入多个推送 SDK，根据终端不同，在小米手机（包括 MIUI）启动小米推送、华为手机启动华为推送。

### Native拉活

Native fork子进程用于观察当前app主进程的存亡状态。对于5.0以上成功率极低。

### 双进程守护

两个进程共同运行，如果有其中一个进程被杀，那么另外一个进程就会将被杀的进程重新拉起。

### 系统白名单

与厂商合作，加入保活白名单，比如微信，前提是能做到微信那样的体量。

## 4 开源库

- [Android Keep Alive(安卓保活)，Cactus 集成双进程前台服务，JobScheduler，onePix(一像素)，WorkManager，无声音乐](https://github.com/gyf-dev/Cactus)
- [ProgressDaemon](https://github.com/oneapp1e/ProgressDaemon)
- [论Android应用进程长存的可行性](https://blog.csdn.net/aigestudio/article/details/51348408)
