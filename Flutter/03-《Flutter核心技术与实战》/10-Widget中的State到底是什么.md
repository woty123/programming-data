# 10-Widget 中的 State 到底是什么

- Flutter 在底层做了大量的渲染优化工作，使得我们只需要通过组合、嵌套不同类型的 Widget，就可以构建出任意功能、任意复杂度的界面。
- Widget 有 StatelessWidget 和 StatefulWidget 两种类型。
  - StatelessWidget 则用于处理静态的、无状态的视图展示。
  - StatefulWidget 应对有交互、需要动态变化视觉效果的场景。

StatefulWidget 的场景已经完全覆盖了 StatelessWidget，那么，StatelessWidget 存在的必要性在哪里？StatefulWidget 是否是 Flutter 中的万金油？

## 1 UI 编程范式

UI 编程范式：如何调整一个控件（Widget）的展示样式。

**命令式**：需要精确地告诉操作系统或浏览器用何种方式去做事情。比如，如果我们想要变更界面的某个文案，则需要找到具体的文本控件并调用它的控件方法命令，才能完成文字变更。如 （Android、iOS）或原生 JavaScript 开发。

```java
// Android 设置某文本控件展示文案为 Hello World
TextView textView = (TextView) findViewById(R.id.txt);
textView.setText("Hello World");

// iOS 设置某文本控件展示文案为 Hello World
UILabel *label = (UILabel *)[self.view viewWithTag:1234];
label.text = @"Hello World";

// 原生 JavaScript 设置某文本控件展示文案为 Hello World
document.querySelector("#demo").innerHTML = "Hello World!";
```

**声明式**：其核心设计思想就是将视图和数据分离，这与 React 的设计思路完全一致。Flutter 采用的就是声明式 UI 编程。

- 构建声明式 UI：除了设计好 Widget 布局方案之外，还需要提前维护一套文案数据集，并为需要变化的 Widget 绑定数据集中的数据，使 Widget 根据这个数据集完成渲染。
- 更新 UI：当需要变更界面的文案时，我们只要改变数据集中的文案数据，并通知 Flutter 框架触发 Widget 的重新渲染即可。

声明式 UI 的好处：开发者无需再精确关注 UI 编程中的各个过程细节，只要维护好数据集即可。比起命令式的视图开发方式需要挨个设置不同组件（Widget）的视觉属性，这种方式要便捷得多。

总结：**命令式编程强调精确控制过程细节；而声明式编程强调通过意图输出结果整体**。对应到 Flutter 中，意图是绑定了组件状态的 State，结果则是重新渲染后的组件。在 Widget 的生命周期内，应用到 State 中的任何更改都将强制 Widget 重新构建。

**StatelessWidget 和 StatefulWidget 区别点：**

1. 对于组件完成创建后就无需变更的场景，状态的绑定是可选项。这里“可选”就区分出了 Widget 的两种类型，即：StatelessWidget 不带绑定状态，而 StatefulWidget 带绑定状态。
2. 当你所要构建的用户界面不随任何状态信息的变化而变化时，需要选择使用 StatelessWidget，反之则选用 StatefulWidget。
3. StatelessWidget 一般用于静态内容的展示，而 StatefulWidget 则用于存在交互反馈的内容呈现中。

## 2 StatelessWidget

**Widget 的构建流程：** 在 Flutter 中，Widget 采用由父到子、自顶向下的方式进行构建，父 Widget 控制着子 Widget 的显示样式，其样式配置由父 Widget 在构建时提供。

**StatelessWidget 是无状态组件**：构建出的 Widget 中，有些在创建时，除了这些配置参数之外不依赖于任何其他信息，即它们一旦创建成功就不再关心、也不响应任何数据变化进行重绘。比如 Text、Container、Row、Column 等。

**以 Text 的部分源码为例，说明 StatelessWidget 的构建过程**：可以看到，在构造方法将其属性列表赋值后，build 方法随即将子组件 RichText 通过其属性列表（如文本 data、对齐方式 textAlign、文本展示方向 textDirection 等）初始化后返回，之后 Text 内部不再响应外部数据的变化。

```dart
class Text extends StatelessWidget {

  // 构造方法及属性声明部分
  const Text(this.data, {
    Key key,
    this.textAlign,
    this.textDirection,
    // 其他参数
    ...
  }) : assert(data != null),
     textSpan = null,
     super(key: key);

  //属性
  final String data;
  final TextAlign textAlign;
  final TextDirection textDirection;
  // 其他属性
  ...
  
  //构建方法
  @override
  Widget build(BuildContext context) {
    ...
    Widget result = RichText(
       // 初始化配置
       ...
      )
    );
    ...
    return result;
  }
}
```

### 什么场景下应该使用 StatelessWidget

简单的判断规则：**父 Widget 是否能通过初始化参数完全控制其 UI 展示效果**？如果能，那么我们就可以使用 StatelessWidget 来设计构造函数接口了。

示例场景:

1. 需要创建一个自定义的弹窗控件，把使用 App 过程中出现的一些错误信息提示给用户。这个组件的父 Widget，能够完全在子 Widget 初始化时将组件所需要的样式信息和错误提示信息传递给它，也就意味着父 Widget 通过初始化参数就能完全控制其展示效果。所以可以采用继承 StatelessWidget 的方式，来进行组件自定义。
2. 需要定义一个计数器按钮，用户每次点击按钮后，按钮颜色都会随之加深。可以看到，这个组件的父 Widget 只能控制子 Widget 初始的样式展示效果，而无法控制在交互过程中发生的颜色变化。所以无法通过继承 StatelessWidget 的方式来自定义组件。这时就需要使用 StatefulWidget 了。

## 3 StatefulWidget

**StatefulWidget 是有状态组件**：对这类控件的展示，除了父 Widget 初始化时传入的静态配置之外，还需要处理用户的交互（比如，用户点击按钮）或其内部数据的变化（比如，网络数据回包），并体现在 UI 上。即这些 Widget 创建完成后，还需要关心和响应数据变化来进行重绘。如  Image、Checkbox 等。

![](images/10-statefulwidget.png)

**真正的状态是 state**：Widget 是不可变的，发生变化时需要销毁重建，那么为什么还有 StatefulWidget 呢？其实 StatefulWidget 是以 State 类代理 Widget 构建的设计方式实现的。

**以 Image 的部分源码为例，说明 StatefulWidget 的构建过程**：Image 类的构造函数会接收要被这个类使用的属性参数。不同的是，Image 类并没有 build 方法来创建视图，而是通过 createState 方法创建了一个类型为 _ImageState 的 state 对象，然后由这个对象负责视图的构建。这个 state 对象持有并处理了 Image 类中的状态变化，以 _imageInfo 属性为例来展开说明：_imageInfo 属性用来给 Widget 加载真实的图片，一旦 State 对象通过 _handleImageChanged 方法监听到 _imageInfo 属性发生了变化，就会立即调用 _ImageState 类的 setState 方法通知 Flutter 框架“数据变了，请使用更新后的 _imageInfo 数据重新加载图片”，然后 Flutter 框架则会标记视图状态，更新 UI。

```dart
class Image extends StatefulWidget {
  // 构造方法及属性声明部分
  const Image({
    Key key,
    @required this.image,
    // 其他参数
  }) : assert(image != null),
       super(key: key);

  final ImageProvider image;
  // 其他属性
  ...
  
  //需要场景一个状态
  @override
  _ImageState createState() => _ImageState();
  ...
}

//与 Image 相关的状态类
class _ImageState extends State<Image> {
  ImageInfo _imageInfo;
  // 其他属性
  ...

  void _handleImageChanged(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo = imageInfo;
    });
  }
  ...

  //由 state 创建出展示的 widget。
  @override
  Widget build(BuildContext context) {
    final RawImage image = RawImage(
      image: _imageInfo?.image,
      // 其他初始化配置
      ...
    );
    return image;
  }
 ...
}
```

Image 以一种动态的方式运行：监听变化，更新视图。与 StatelessWidget 通过父 Widget 完全控制 UI 展示不同，StatefulWidget 的父 Widget 仅定义了它的初始化状态，而其自身视图运行的状态则需要自己处理，并根据处理情况即时更新 UI 展示。

## 4 StatefulWidget 不是万金油

对于 UI 框架而言，同样的展示效果一般可以通过多种控件实现。从定义来看，StatefulWidget 仿佛是万能的，**但是 StatefulWidget 的滥用会直接影响 Flutter 应用的渲染性能**。

**Widget 是不可变的，更新则意味着销毁 + 重建（build）。StatelessWidget 是静态的，一旦创建则无需更新；而对于 StatefulWidget 来说，在 State 类中调用 setState 方法更新数据，会触发视图的销毁和重建，也将间接地触发其每个子 Widget 的销毁和重建**。如果我们的根布局是一个 StatefulWidget，在其 State 中每调用一次更新 UI，都将是一整个页面所有 Widget 的销毁和重建。

虽然 Flutter 内部通过 Element 层可以最大程度地降低对真实渲染视图的修改，提高渲染效率，而不是销毁整个 RenderObject 树重建。但，大量 Widget 对象的销毁重建是无法避免的。如果某个子 Widget 的重建涉及到一些耗时操作，那页面的渲染性能将会急剧下降。因此**正确评估你的视图展示需求，避免无谓的 StatefulWidget 使用，是提高 Flutter 应用渲染性能最简单也是最直接的手段**。

## 5 总结

- Flutter 基于声明式的 UI 编程范式。
- StatelessWidget 与 StatefulWidget 的基本设计思路。
- 由于 Widget 采用由父到子、自顶向下的方式进行构建，因此在自定义组件时，我们可以根据父 Widget 是否能通过初始化参数完全控制其 UI 展示效果的基本原则，来判断究竟是继承 StatelessWidget 还是 StatefulWidget。
- 尽管 Flutter 会通过 Element 层去最大程度降低对真实渲染视图的修改，但大量的 Widget 销毁重建无法避免，因此避免 StatefulWidget 的滥用，是最简单、直接地提升应用渲染性能的手段。

## 6 思考题

Flutter 工程应用模板是计数器示例应用 Demo，这个 Demo 的根节点是一个 StatelessWidget。请在保持原有功能的情况下，将这个 Demo 改造为根节点为 StatefulWidget 的 App。你能通过数据打点，得出这两种方式的性能差异吗？
