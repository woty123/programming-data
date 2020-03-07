# 34-理解Flutter的编译模式

在开发移动应用程序时，一个 App 的完整生命周期包括`开发、测试和上线` 3 个阶段。在每个阶段，开发者的关注点都不一样。

- 在开发阶段，我们希望调试尽可能方便、快速，尽可能多地提供错误上下文信息。
- 在测试阶段，我们希望覆盖范围尽可能全面，能够具备不同配置切换能力，可以测试和验证还没有对外发布的新功能。
- 在发布阶段，我们则希望能够去除一切测试代码，精简调试信息，使运行速度尽可能快，代码足够安全。

这要求我们在构建移动应用时，不仅要在工程内提前准备多份配置环境，还要利用编译器提供的编译选项，打包出符合不同阶段优化需求的 App。

Flutter 对此作了以下支持:

1. 常见的 Debug、Release 等工程物理层面的编译模式。
2. 支持在工程内提供多种配置环境入口。

## 1 Flutter 的编译模式

Flutter 支持 3 种运行模式，包括 Debug、Release 和 Profile。在编译时，这三种模式是完全独立的。

- **Debug 模式**：对应 Dart 的 JIT 模式，flutter run --debug 命令，就是以这种模式运行的。
  - 优点：可以在真机和模拟器上同时运行。该模式会打开所有的断言（assert），以及所有的调试信息、服务扩展和调试辅助（比如 Observatory）。此外，该模式为快速开发和运行做了优化，支持亚秒级有状态的 Hot reload（热重载）。
  - 缺点：没有优化代码执行速度、二进制包大小和部署。
- **Release 模式**：对应 Dart 的 AOT 模式，其编译目标为最终的线上发布，给最终的用户使用。flutter run --release 命令，就是以这种模式运行的。
  - 优点：该模式会关闭所有的断言，以及尽可能多的调试信息、服务扩展和调试辅助。此外，该模式优化了应用快速启动、代码快速执行，以及二级制包大小。
  - 缺点：只能在真机上运行，不能在模拟器上运行，由于编译阶段有诸多优化，因此编译时间较长。
- **Profile 模式**，基本与 Release 模式一致，只是多了对 Profile 模式的服务扩展的支持，包括支持跟踪，以及一些为了最低限度支持所需要的依赖（比如，可以连接 Observatory 到进程）。该模式用于分析真实设备实际运行性能。flutter run --profile 命令，就是以这种模式运行的。

## 2 在运行时识别应用的编译模式

有两种解决办法：

- 通过断言识别；
- 通过 Dart VM 所提供的编译常数识别。

### 通过断言识别应用的编译模式

Release 与 Debug 模式的一个重要区别就是，Release 模式关闭了所有的断言。因此，我们可以借助于断言，写出只在 Debug 模式下生效的代码。

我们在断言里传入了一个始终返回 true 的匿名函数执行结果，这个匿名函数的函数体只会在 Debug 模式下生效：

```dart
assert(() {
  //Do sth for debug
  return true;
}());
```

需要注意的是，匿名函数声明调用结束时追加了小括号（）。 这是因为断言只能检查布尔值，所以我们必须使用括号强制执行这个始终返回 true 的匿名函数，以确保匿名函数体的代码可以执行。

### 通过编译常数识别应用的编译模式

如果说通过断言只能写出在 Debug 模式下运行的代码，而通过 Dart 提供的编译常数，我们还可以写出只在 Release 模式下生效的代码。Dart 提供了一个布尔型的常量 kReleaseMode，用于反向指示当前 App 的编译模式。

```dart
if(kReleaseMode){
  //Do sth for release
} else {
  //Do sth for debug
}
```

总结：通过断言和 kReleaseMode 常量，我们能够识别出当前 App 的编译环境，从而可以在运行时对某个代码功能进行局部微调。

## 3 分离配置环境

想在整个应用层面，为不同的运行环境提供更为统一的配置（比如，对于同一个接口调用行为，开发环境会使用 dev.example.com 域名，而生产环境会使用 api.example.com 域名），则需要在应用启动入口提供可配置的初始化方式，根据特定需求为应用注入配置环境。

在 Flutter 构建 App 时，为应用程序提供不同的配置环境，总体可以分为抽象配置、配置多入口、读配置和编译打包 4 个步骤：

1. 抽象出应用程序的可配置部分，并使用 InheritedWidget 对其进行封装；
2. 将不同的配置环境拆解为多个应用程序入口（比如，开发环境为 main-dev.dart、生产环境为 main.dart），把应用程序的可配置部分固化在各个入口处；
3. 在运行期，通过 InheritedWidget 提供的数据共享机制，将配置部分应用到其子 Widget 对应的功能中；
4. 使用 Flutter 提供的编译打包选项，构建出不同配置环境的安装包。

### 3.1 配置抽象

```dart
class AppConfig extends InheritedWidget {

  AppConfig({
    @required this.appName,
    @required this.apiBaseUrl,
    @required Widget child,
  }) : super(child: child);

  final String appName;// 主页标题
  final String apiBaseUrl;// 接口域名

  // 方便其子 Widget 在 Widget 树中找到它
  static AppConfig of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppConfig);
  }
  
  // 判断是否需要子 Widget 更新。由于是应用入口，无需更新
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
```

### 3.2 为不同的环境创建不同的应用入口

假设只有两个环境，即开发环境与生产环境，因此我们将文件分别命名为 main_dev.dart 和 main.dart。在这两个文件中，我们使用不同的配置数据来对 AppConfig 进行初始化，同时把应用程序实例 MyApp 作为其子 Widget，这样整个应用内都可以获取到配置数据：

```dart
//main_dev.dart
void main() {
  var configuredApp = AppConfig(
    appName: 'dev',// 主页标题
    apiBaseUrl: 'http://dev.example.com/',// 接口域名
    child: MyApp(),
  );
  runApp(configuredApp);// 启动应用入口
}

//main.dart
void main() {
  var configuredApp = AppConfig(
    appName: 'example',// 主页标题
    apiBaseUrl: 'http://api.example.com/',// 接口域名
    child: MyApp(),
  );
  runApp(configuredApp);// 启动应用入口
}
```

### 3.3 在应用内获取配置数据

由于 AppConfig 是整个应用程序的根节点，因此我可以通过调用 AppConfig.of 方法，来获取到相关的数据配置。

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var config = AppConfig.of(context);// 获取应用配置
    return MaterialApp(
      title: config.appName,// 应用主页标题
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var config = AppConfig.of(context);// 获取应用配置
    return Scaffold(
      appBar: AppBar(
        title: Text(config.appName),// 应用主页标题
      ),
      body:  Center(
        child: Text('API host: ${config.apiBaseUrl}'),// 接口域名
      ),
    );
  }
}
```

### 3.4 构建不同的安装包

现在，我们已经完成了分离配置环境的代码部分。最后，我们可以使用 Flutter 提供的编译选项，来构建出不同配置的安装包了。

如果想要在模拟器或真机上运行这段代码，我们可以在 flutter run 命令后面，追加–target 或 -t 参数，来指定应用程序初始化入口：

```shell
// 运行开发环境应用程序
flutter run -t lib/main_dev.dart

// 运行生产环境应用程序
flutter run -t lib/main.dart
```

如果我们想在 Android Studio 上为应用程序创建不同的启动配置，则可以通过 Flutter 插件为 main_dev.dart 增加启动入口。

如果我们想要打包构建出适用于 Android 的 APK，或是 iOS 的 IPA 安装包，则可以在 flutter build 命令后面，同样追加–target 或 -t 参数，指定应用程序初始化入口：

```dart
// 打包开发环境应用程序
flutter build apk -t lib/main_dev.dart
flutter build ios -t lib/main_dev.dart

// 打包生产环境应用程序
flutter build apk -t lib/main.dart
flutter build ios -t lib/main.dart
```

## 4 相关示例

- [34_multi_env](https://github.com/cyndibaby905/34_multi_env)

## 5 思考题

在保持生产环境代码不变的情况下，如果想在开发环境中支持不同配置的切换，我们应该如何实现？
