# Flutter 插件开发

Package 类型分为两种：

- Dart packages：不包含特定平台实现，用 dart 语言编写。
- Plugin packages：Dart专用程序包，其中包含用Dart代码编写的API以及用于 Android 或 IOS 特定平台的实现。

## 1 开发 Dart packages

相对简单，参考官方稳定即可。

## 2 开发 Plugin packages

在 [26-在Dart层兼容Android与iOS平台特定实现1-方法通道](26-在Dart层兼容Android与iOS平台特定实现1-方法通道.md)学习了如何在原生工程中的 Flutter 应用入口注册原生代码宿主回调，从而实现 Dart 层调用原生接口的方案。这种方案简单直接，适用于 Dart 层与原生接口之间交互代码量少、数据流动清晰的场景。

**Plugin package 场景**：涉及 Dart 与原生多方数据流转、代码量大的模块，这种与工程耦合的方案就不利于独立开发维护了。这时，我们需要使用 Flutter 提供的插件工程对其进行单独封装。

### 插件工程简介

创建插件工程：`flutter create --org com.example --template=plugin flutter_push_plugin`，其中 `flutter_push_plugin` 为插件名称。

运行完命令后会创建一个插件工程，结构如下图示：

![](images/31-plugin-structure.png)

- Flutter 的插件工程与普通的应用工程类似，都有 android 和 ios 目录，这也是我们完成平台相关逻辑代码的地方，而 Flutter 工程插件的注册，则仍会在应用的入口完成。
- 插件工程还内嵌了一个 example 工程，这是一个引用了插件代码的普通 Flutter 应用工程。我们通过 example 工程，可以直接调试插件功能。

### 进行 Android 平台接口实现

1. 由于 android 子工程的运行依赖于 Flutter 工程编译构建产物，所以在打开 android 工程进行开发前，你需要确保整个工程代码至少 build 过一次，否则 IDE 会报错。
2. 用 Android Studio 打开 example 下的 android 工程进行插件开发工作。（注意，是 example 下的 android 工程，而不要直接打开插件工程 ）

### 进行 IOS 平台接口实现

1. 在打开 ios 工程前，你需要确保整个工程代码至少 build 过一次，否则 IDE 会报错。
2. 使用 Xcode 打开 example 下的 ios 工程进行插件开发工作。

### 使用 example 下的 flutter 工程测试插件

待 example 工程运行所需的所有原生配置工作和接口实现都已经搞定了。接下来，就可以在 example 工程中的 main.dart 文件中，使用所开发的插件来实现原生推送能力了。

### 在 Flutter 工程中使用插件

1. 可以选择将插件发布到 pub.dev 上，然后在工程中进行依赖。
2. 可以在本地进行依赖，代码如下：

```yaml
dependencies:
  flutter_push_plugin:
    git:
      url: https://github.com/cyndibaby905/31_flutter_push_plugin.git
```

## 3 实战：使用 Flutter 插件实现原生推送送能力

- [31_flutter_push_plugin](https://github.com/cyndibaby905/31_flutter_push_plugin)
- [31_flutter_push_demo](https://github.com/cyndibaby905/31_flutter_push_demo)

## 4 参考

- [developing-packages](https://flutter.dev/docs/development/packages-and-plugins/developing-packages)
- [开发Packages和插件](https://flutterchina.club/developing-packages/)
