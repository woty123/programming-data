# 36-调试Flutter应用

在 Flutter 中，调试代码主要分为：

- 输出日志
- 断点调试
- 布局调试

## 1 输出日志

**使用 print 的弊端**：由于涉及 I/O 操作，使用 print 来打印信息会消耗较多的系统资源。同时，这些输出数据很可能会暴露 App 的执行细节。

**使用 debugPrint 函数**：debugPrint 函数同样会将消息打印至控制台，但与 print 不同的是，它提供了定制打印的能力。也就是说，我们可以向 debugPrint 函数，赋值一个函数声明来自定义打印行为。

```dart
debugPrint = (String message, {int wrapWidth}) {};// 空实现
```

我们可以分别在 debug 和 release 模式下指定不同的 debugPrint 实现：

```dart
//main.dart
void main() {
  // 将 debugPrint 指定为空的执行体, 所以它什么也不做
  debugPrint = (String message, {int wrapWidth}) {};
  runApp(MyApp());
}

//main-dev.dart
void main() async {
  // 将 debugPrint 指定为同步打印数据
  debugPrint = (String message, {int wrapWidth}) => debugPrintSynchronously(message, wrapWidth: wrapWidth);
  runApp(MyApp());
}
```

## 2 断点调试

如果要想获取更为详细，或是粒度更细的上下文信息，我们需要更为灵活的动态调试方法，即断点调试。通过断点调试，我们在 Android Studio 的调试面板中，可以随时查看执行上下文有关的变量的值，根据逻辑来做进一步的判断，确定跟踪执行的步骤。

调试 Flutter 应用与原生应用调试一样，分为：

- 标记断点
- 调试应用
- 查看信息

主要包含以下断点操作：

![](images/36-debug-functions.png)

## 3 布局调试

### 3.1 Debug Painting

如果想要更快地发现界面中更为细小的问题，比如对齐、边距等，需要使用 Debug Painting 这个界面调试工具。

Debug Painting 能够以辅助线的方式，清晰展示每个控件元素的布局边界，因此我们可以根据辅助线快速找出布局出问题的地方。而 Debug Painting 的开启也比较简单，只需要将 debugPaintSizeEnabled 变量置为 true 即可。

```dart
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = true;      // 打开 Debug Painting 调试开关
  runApp(new MyApp());
}
```

辅助线提供了基本的 Widget 可视化能力。通过辅助线，我们能够感知界面中是否存在对齐或边距的问题。

### 3.2 Flutter Inspector

如果我们想要获取到 Widget 的可视化信息（比如布局信息、渲染信息等）去解决渲染问题，就需要使用更强大的 Flutter Inspector 了。

为了使用 Flutter Inspector，我们需要回到 Android Studio，通过工具栏上的“Open DevTools”按钮启动 Flutter Inspector：

![](images/36-flutter-inspector.png)

随后，Android Studio 会打开浏览器，将计数器示例中的 Widget 树结构展示在面板中。可以看到，Flutter Inspector 所展示的 Widget 树结构，与代码中实现的 Widget 层次是一一对应的。

![](images/36-flutter-inspector-show.png)

## 4 思考题

请将 debugPrint 在生产环境下的打印日志行为更改为写日志文件。其中，日志文件一共 5 个（0-4），每个日志文件不能超过 2MB，但可以循环写。如果日志文件已满，则循环至下一个日志文件，清空后重新写入。
