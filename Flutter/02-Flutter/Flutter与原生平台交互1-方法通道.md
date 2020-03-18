# 极客时间 [《Flutter核心技术与实战》](https://time.geekbang.org/column/article/104040)：在Dart层兼容Android与iOS平台特定实现1-方法通道

## 1 Dart 层需要原生平台支持

Dart 层所提供的能力与局限：

1. 依托于与 Skia 的深度定制及优化，Flutter 给我们提供了很多关于**渲染的控制和支持**，能够实现绝对的跨平台**应用层渲染一致性**。
2. 对于一个应用而言，除了应用层视觉显示和对应的交互逻辑处理之外，有时还需要原生操作系统（Android、iOS）提供的底层能力支持。比如数据持久化、推送、摄像头硬件调用等。而由于 Flutter 只接管了应用渲染层，因此这些系统底层能力是无法在 Flutter 框架内提供支持的。
3. Flutter 还是一个相对年轻的生态，因此原生开发中一些相对成熟的 Java、C++ 或 Objective-C 代码库，比如图片处理、音视频编解码等，可能在 Flutter 中还没有相关实现。

**方法通道的引入**：为了解决调用原生系统底层能力以及相关代码库复用问题，Flutter 为开发者提供了一个轻量级的解决方案，即逻辑层的方法通道（Method Channel）机制。基于方法通道，我们可以将原生代码所拥有的能力，以接口形式暴露给 Dart，从而实现 Dart 代码与原生代码的交互，就像调用了一个普通的 Dart API 一样。

## 2 方法通道

### 方法通道简介

1. Flutter 作为一个跨平台框架，提供了一套标准化的解决方案，为开发者屏蔽了操作系统的差异。
2. 因此在某些特定场景下（比如推送、蓝牙、摄像头硬件调用时），Flutter 也需要具备直接访问系统底层原生代码的能力。
3. Flutter 提供了一套灵活而轻量级的机制来实现 Dart 和原生代码之间的通信，即方法调用的消息传递机制，而方法通道则是用来传递通信消息的信道。

### 方法通道调用过程

一次典型的方法调用过程类似网络调用：

1. 由作为客户端的 Flutter，通过方法通道向作为服务端的原生代码宿主发送方法调用请求；
2. 原生代码宿主在监听到方法调用的消息后，调用平台相关的 API 来处理 Flutter 发起的请求，最后将处理完毕的结果通过方法通道回发至 Flutter。

调用过程如下图所示：

![](images/26-method-channel.png)

可以看出，方法调用请求的处理和响应：

1. 在 Android 中是通过 FlutterView，而在 iOS 中则是通过 FlutterViewController 进行注册的。
2. FlutterView 与 FlutterViewController 为 Flutter 应用提供了一个画板，使得构建于 Skia 之上的 Flutter 通过绘制即可实现整个应用所需的视觉效果。
3. 因此，FlutterView 与 FlutterViewController 不仅是 Flutter 应用的容器，同时也是 Flutter 应用的入口，自然也是注册方法调用请求最合适的地方。

## 3 使用方法通道

### 3.1 在 Flutter 中实现方法调用请求

1. 首先，我们需要确定一个唯一的字符串标识符，来构造一个命名通道；
2. 然后，在这个通道之上，Flutter 通过指定方法名“openAppMarket”来发起一次方法调用请求。

示例：

```dart
// 声明 MethodChannel
const platform = MethodChannel('samples.chenhang/utils');

// 处理按钮点击
handleButtonClick() async{
  int result;
  // 异常捕获
  try {
    // 异步等待方法通道的调用结果
    result = await platform.invokeMethod('openAppMarket');
  }
  catch (e) {
    result = -1;
  }
  print("Result：$result");
}
```

注意：

1. 因为方法调用过程是异步的，所以我们需要使用非阻塞（或者注册回调）来等待原生代码给予响应。
2. 方法调用请求有可能会失败（比如，Flutter 发起了原生代码不支持的 API 调用，或是调用过程出错等），因此我们需要把发起方法调用请求的语句用 try-catch 包装起来。

### 3.2 在原生代码中完成方法调用的响应

#### Android 平台实现

在 Android 平台，方法调用的处理和响应是在 Flutter 应用的入口，也就是在 MainActivity 中的 FlutterView 里实现的，因此我们需要打开 Flutter 的 Android 宿主 App，找到 MainActivity.java 文件，并在其中添加相关的逻辑。

调用方与响应方都是通过命名通道进行信息交互的，所以我们需要在 onCreate 方法中，创建一个与调用方 Flutter 所使用的通道名称一样的 MethodChannel，并在其中设置方法处理回调，响应 openAppMarket 方法，打开应用市场的 Intent。同样地，考虑到打开应用市场的过程可能会出错，我们也需要增加 try-catch 来捕获可能的异常：

```java
protected void onCreate(Bundle savedInstanceState) {

  ...
  // 创建与调用方标识符一样的方法通道
  new MethodChannel(getFlutterView(), "samples.chenhang/utils").setMethodCallHandler(
   // 设置方法处理回调
    new MethodCallHandler() {
      // 响应方法请求
      @Override
      public void onMethodCall(MethodCall call, Result result) {
        // 判断方法名是否支持
        if(call.method.equals("openAppMarket")) {
          try {
            // 应用市场 URI
            Uri uri = Uri.parse("market://details?id=com.hangchen.example.flutter_module_page.host");
            Intent intent = new Intent(Intent.ACTION_VIEW, uri);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            // 打开应用市场
            activity.startActivity(intent);
            // 返回处理结果
            result.success(0);
          } catch (Exception e) {
            // 打开应用市场出现异常
            result.error("UNAVAILABLE", " 没有安装应用市场 ", null);
          }
        }else {
          // 方法名暂不支持
          result.notImplemented();
        }
      }
    });

}
```

#### IOS 平台实现

在 iOS 平台，方法调用的处理和响应是在 Flutter 应用的入口，也就是在 Applegate 中的 rootViewController（即 FlutterViewController）里实现的，因此我们需要打开 Flutter 的 iOS 宿主 App，找到 AppDelegate.m 文件，并添加相关逻辑。

与 Android 注册方法调用响应类似，我们需要在 didFinishLaunchingWithOptions: 方法中，创建一个与调用方 Flutter 所使用的通道名称一样的 MethodChannel，并在其中设置方法处理回调，响应 openAppMarket 方法，通过 URL 打开应用市场：

```oc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // 创建命名方法通道
  FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"samples.chenhang/utils" binaryMessenger:(FlutterViewController *)self.window.rootViewController];
  // 往方法通道注册方法调用处理回调
  [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    // 方法名称一致
    if ([@"openAppMarket" isEqualToString:call.method]) {
      // 打开 App Store(本例打开微信的 URL)
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/xy/app/foo/id414478124"]];
      // 返回方法处理结果
      result(@0);
    } else {
      // 找不到被调用的方法
      result(FlutterMethodNotImplemented);
    }
  }];
  ...
}
```

### 数据类型对应

在原生代码处理完毕后将处理结果返回给 Flutter 时，我们在 Dart、Android 和 iOS 分别用了三种数据类型：

- Android 端返回的是 java.lang.Integer
- iOS 端返回的是 NSNumber
- Dart 端接收到返回结果时是 int 类型

这些数据类型是如何对应的呢？在使用方法通道进行方法调用时，由于涉及到跨系统数据交互，Flutter 会使用 StandardMessageCodec 对通道中传输的信息进行类似 JSON 的二进制序列化，以标准化数据传输行为。这样在我们发送或者接收数据时，这些数据就会根据各自系统预定的规则自动进行序列化和反序列化。

对于上面提到的例子，类型为 java.lang.Integer 或 NSNumber 的返回值，先是被序列化成了一段二进制格式的数据在通道中传输，然后当该数据传递到 Flutter 后，又被反序列化成了 Dart 语言中的 int 类型的数据。

关于 Android、iOS 和 Dart 平台间的常见数据类型转换，总结如下表：

![](images/26-data-type-mapping.png)

## 4 总结

1. 方法通道解决了逻辑层的原生能力复用问题，使得 Flutter 能够通过轻量级的异步方法调用，实现与原生代码的交互。
2. **方法通道是非线程安全的**。这意味着原生代码与 Flutter 之间所有接口调用必须发生在主线程。Flutter 是单线程模型，因此自然可以确保方法调用请求是发生在主线程（Isolate）的；而原生代码在处理方法调用请求时，如果涉及到异步或非主线程切换，需要确保回调过程是在原生系统的 UI 线程（也就是 Android 和 iOS 的主线程）中执行的，否则应用可能会出现奇怪的 Bug，甚至是 Crash。

## 5 相关示例

- [26_native_method](https://github.com/cyndibaby905/26_native_method)

## 6 思考题

请扩展方法通道示例，让 openAppMarket 支持传入 AppID 和包名，使得我们可以跳转到任意一个 App 的应用市场。

- dart 层通过 platform.invokeMethod 第二个参数传入动态参数，native 层可以通过 call.argument 拿到参数。
