# 30-为什么需要做状态管理，怎么做

**状态管理的必要性**：

1. 前面已经学习了 InheritedWidget、Notification 和 EventBus 这 3 种数据传递机制，通过它们可以实现组件间的单向数据传递。如果我们的应用足够简单，数据流动的方向和顺序是清晰的，我们只需要将数据映射成视图就可以了。作为声明式的框架，Flutter 可以自动处理数据到渲染的全过程，通常并不需要状态管理。
2. 随着产品需求迭代节奏加快，项目逐渐变得庞大时，我们往往就需要管理不同组件、不同页面之间共享的数据关系。当需要共享的数据关系达到几十上百个的时候，我们就很难保持清晰的数据流动方向和顺序了，导致应用内各种数据传递嵌套和回调满天飞。在这个时候，我们迫切需要一个解决方案，来帮助我们理清楚这些共享数据的关系，于是状态管理框架便应运而生。

**框架选择**：

- 社区框架：Flutter 在设计声明式 UI 上借鉴了不少 React 的设计思想，因此涌现了诸如 flutter_redux、flutter_mobx 、fish_redux 等基于前端设计理念的状态管理框架。但这些框架大都比较复杂，且需要对框架设计概念有一定理解，学习门槛相对较高。
- 官方框架：源自 Flutter 官方的状态管理框架 Provider 则相对简单得多，不仅容易理解，而且框架的侵入性小，还可以方便地组合和控制 UI 刷新粒度。因此，在 Google I/O 2019 大会一经面世，Provider 就成为了官方推荐的状态管理方式之一。

## 1 Provider 介绍

Provider 是一个用来提供数据的框架。它是 InheritedWidget 的语法糖，提供了依赖注入的功能，允许在 Widget 树中更加灵活地处理和传递数据。

使用 Provider，首先需要在 pubspec.yaml 文件中添加 Provider 的依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: 3.0.0+1  #provider 依赖
```

### 1.1 依赖注入

依赖注入是一种可以让我们在需要时提取到所需资源的机制，即：预先将某种“资源”放到程序中某个我们都可以访问的位置，当需要使用这种“资源”时，直接去这个位置拿即可，而无需关心“资源”是谁放进去的。

因此为了使用 Provider，我们需要解决以下 3 个问题：

1. 资源（即数据状态）如何封装？
2. 资源放在哪儿，才都能访问得到？
3. 具体使用时，如何取出资源？

### 1.2 Provider 使用示例

#### 封装资源

示例：有两个独立的页面 FirstPage 和 SecondPage，它们会共享计数器的状态：其中 FirstPage 负责读，SecondPage 负责读和写。

首先，进行数据状态的封装了。这里，我们只有一个状态需要共享，即 count。由于第二个页面还需要修改状态，因此我们还需要在数据状态的封装上包含更改数据的方法：

```dart
// 定义需要共享的数据模型，通过混入 ChangeNotifier 管理听众
class CounterModel with ChangeNotifier {

  int _count = 0;

  // 读方法
  int get counter => _count;

  // 写方法
  void increment() {
    _count++;
    notifyListeners();// 通知听众刷新
  }
}
```

在资源封装类中使用 mixin 混入了 ChangeNotifier。这个类能够帮助我们管理所有依赖资源封装类的听众。当资源封装类调用 notifyListeners 时，它会通知所有听众进行刷新。

#### 资源放置

因为 Provider 实际上是 InheritedWidget 的语法糖，所以通过 Provider 传递的数据从数据流动方向来看，是由父到子（或者反过来）。所以需要把资源放到 FirstPage 和 SecondPage 的父 Widget，也就是应用程序的实例 MyApp 中（当然，把资源放到更高的层级也是可以的，比如放到 main 函数中）：

```dart
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
     // 通过 Provider 组件封装数据资源
    return ChangeNotifierProvider.value(
        value: CounterModel(),// 需要共享的数据资源
        child: MaterialApp(
          home: FirstPage(),
        )
    );
  }

}
```

既然 Provider 是 InheritedWidget 的语法糖，因此它也是一个 Widget。所以，我们直接在 MaterialApp 的外层使用 Provider 进行包装，就可以把数据资源依赖注入到应用中。

注意:

- **由于封装的数据资源不仅需要为子 Widget 提供读的能力，还要提供写的能力，因此我们需要使用 Provider 的升级版 ChangeNotifierProvider**。
- 如果只需要为子 Widget 提供读能力，直接使用 Provider 即可。

#### 资源获取

在注入数据资源完成之后，我们就可以在 FirstPage 和 SecondPage 这两个子 Widget 完成数据的读写操作了。

关于读数据，与 InheritedWidget 一样，我们可以通过 Provider.of 方法来获取资源数据。而如果我们想写数据，则需要通过获取到的资源数据，调用其暴露的更新数据方法（本例中对应的是 increment），代码如下所示：

```dart
// 第一个页面，负责读数据
class FirstPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    // 取出资源
    final _counter = Provider.of<CounterModel>(context);
    return Scaffold(
      // 展示资源中的数据
      body: Text('Counter: ${_counter.counter}'),
      // 跳转到 SecondPage
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecondPage()))
      ));
  }

}

// 第二个页面，负责读写数据
class SecondPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // 取出资源
    final _counter = Provider.of<CounterModel>(context);

    return Scaffold(
      // 展示资源中的数据
      body: Text('Counter: ${_counter.counter}'),
      // 用资源更新方法来设置按钮点击回调
      floatingActionButton:FloatingActionButton(
          onPressed: _counter.increment,
          child: Icon(Icons.add),
     ));

  }

}
```

可见，使用 Provider.of 获取资源，可以得到资源暴露的数据的读写接口，在实现数据的共享和同步上还是比较简单的。

## 2 Consumer

### Provider.of 的副作用

注意，**滥用 Provider.of 方法也有副作用，那就是当数据更新时，页面中其他的子 Widget 也会跟着一起刷新**。

为验证这一点，可以以第二个界面右下角 FloatingActionButton 中的子 Widget “+”Icon 为例做个测试。

```dart
// 用于打印 build 方法执行情况的自定义控件
class TestIcon extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print("TestIcon build");
    return Icon(Icons.add);// 返回 Icon 实例
  }

}
```

然后，我们用 TestIcon 控件，替换掉 SecondPage 中 FloatingActionButton 的 Icon 子 Widget：

```dart
class SecondPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // 取出共享的数据资源
    final _counter = Provider.of<CounterModel>(context);
    return Scaffold(
     ...
      floatingActionButton:FloatingActionButton(
          onPressed: _counter.increment,
          child: TestIcon(),// 替换掉原有的 Icon(Icons.add)
     ));

  }
```

运行这段实例，然后在第二个页面多次点击“+”按钮，观察控制台输出：

```log
I/flutter (21595): TestIcon build
I/flutter (21595): TestIcon build
I/flutter (21595): TestIcon build
I/flutter (21595): TestIcon build
I/flutter (21595): TestIcon build
```

可以看到，TestIcon 控件本来是一个不需要刷新的 StatelessWidget，但却因为其父 Widget FloatingActionButton 所依赖的数据资源 counter 发生了变化，导致它也要跟着刷新。

### 使用 Consumer 优化

有没有办法能够在数据资源发生变化时，只刷新对资源存在依赖关系的 Widget，而其他 Widget 保持不变呢？可以，**Provider 可以精确地控制 UI 刷新粒度，而这一切是基于 Consumer 实现的**。Consumer 本身也是一个 Widget，其使用了 Builder 模式创建 UI，收到更新通知就会通过 builder 重新构建 Widget。

使用 Consumer 来改造 SecondPage：

```dart
class SecondPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // 使用 Consumer 来封装 counter 的读取
      body: Consumer<CounterModel>(

        //builder 函数可以直接获取到 counter 参数
        builder: (context, CounterModel counter, _) => Text('Value: ${counter.counter}')),

        // 使用 Consumer 来封装 increment 的读取
        floatingActionButton: Consumer<CounterModel>(

            //builder 函数可以直接获取到 increment 参数
            builder: (context, CounterModel counter, child) => FloatingActionButton(
                onPressed: counter.increment,
                child: child,
            ),

        child: TestIcon(),
      ),
    );
  }

}
```

可以看到，Consumer 中的 builder 实际上就是真正刷新 UI 的函数，它接收 3 个参数，即 context、model 和 child。其中：

- context 是 Widget 的 build 方法传进来的 BuildContext。
- model 是我们需要的数据资源，而 child 则用来构建那些与数据资源无关的部分。在数据资源发生变更时，builder 会多次执行，但 child 不会重建。

运行这段代码，可以发现，不管我们点击了多少次“+”按钮，TestIcon 控件始终没有发生销毁重建。

## 3 多状态的资源封装

多数据封装：通过上面的例子，我们学习了 Provider 是如何共享一个数据状态的。那么，如果有多个数据状态需要共享，我们又该如何处理呢？

接下来，按照**封装、注入和读写**这 3 个步骤介绍多个数据状态的共享。

示例：基于上面示例扩展，让两个页面之间展示计数器数据的 Text 能够共享 App 传递的字体大小。

### 3.1 数据封装

多个数据状态与单个数据的封装并无不同，如果需要支持数据的读写，我们需要一个接一个地为每一个数据状态都封装一个单独的资源封装类；而如果数据是只读的，则可以直接传入原始的数据对象，从而省去资源封装的过程。

### 3.2 数据注入

- 注入单个资源，我们通过 Provider 的升级版 ChangeNotifierProvider 实现了可读写资源的注入。
- 注入多个资源，可以使用 Provider 的另一个升级版 MultiProvider，来实现多个 Provider 的组合注入。

下面例子通过 MultiProvider 往 App 实例内注入了 double 和 CounterModel 这两个资源 Provider：

```dart
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      Provider.value(value: 30.0),// 注入字体大小
      ChangeNotifierProvider.value(value: CounterModel())// 注入计数器实例
    ],
    child: MaterialApp(
      home: FirstPage(),
    ));
  }

}
```

### 3.3 获取资源

还是使用 Provider.of 方式来获取资源。相较于单状态资源的获取来说，获取多个资源时，我们只需要依次读取每一个资源即可：

```dart
final _counter = Provider.of<CounterModel>(context);// 获取计时器实例
final textSize = Provider.of<double>(context);// 获取字体大小
```

如果以 Consumer 的方式来获取资源的话，我们只要使用 Consumer2<A,B> 对象（这个对象提供了读取两个数据资源的能力），就可以一次性地获取字体大小与计数器实例这两个数据资源：

```dart
// 使用 Consumer2 获取两个数据资源
Consumer2<CounterModel,double>(
  //builder 函数以参数的形式提供了数据资源
  builder: (context, CounterModel counter, double textSize, _) => Text(
      'Value: ${counter.counter}',
      style: TextStyle(fontSize: textSize))
)
```

Consumer2 与 Consumer 的使用方式基本一致，只不过是在 builder 方法中多了一个数据资源参数。事实上，如果你希望在子 Widget 中共享更多的数据，我们最多可以使用到 Consumer6，即共享 6 个数据资源。

## 4 总结

1. 在 Flutter 中可以通过 Provider 进行状态管理的方法，Provider 以 InheritedWidget 语法糖的方式，通过数据资源封装、数据注入和数据读写这 3 个步骤，为我们实现了跨组件（跨页面）之间的数据共享。
2. 既可以用 Provider 来实现静态的数据读传递，也可以使用 ChangeNotifierProvider 来实现动态的数据读写传递，还可以通过 MultiProvider 来实现多个数据资源的共享。
3. Provider.of 和 Consumer 都可以实现数据的读取，并且 Consumer 还可以控制 UI 刷新的粒度，避免与数据无关的组件的无谓刷新。

通过 Provider 来实现数据传递，无论在单个页面内还是在整个 App 之间，我们都可以很方便地实现状态管理，搞定那些通过 StatefulWidget 无法实现的场景，进而开发出简单、层次清晰、可扩展性高的应用。

## 5 相关示例

- [30_provider_demo](https://github.com/cyndibaby905/30_provider_demo)

## 6 思考题

使用 Provider 可以实现 2 个同样类型的对象共享，你知道应该如何实现吗？
