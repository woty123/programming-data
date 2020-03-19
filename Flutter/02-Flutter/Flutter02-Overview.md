# Flutter Arch

## 1 UI

### Widget 概览

**Widget 按功能分类：**

1. 基础控件，比如文本、图片、按钮、选框、表单、进度条。
2. 布局控件
3. 容器控件
4. 列表、滚动型控件。
5. 功能型控件

**根据 Widget 是否需要包含子节点将 Widget 分为了三类：**

1. LeafRenderObjectWidget：对应 LeafRenderObjectElement，Widget 树的叶子节点，用于没有子节点的 widget，比如 Image。
2. SingleChildRenderObjectWidget：对应 SingleChildRenderObjectWidget，包含一个子 Widget，比如 Container。
3. MultiChildRenderObjectWidget：对应 MultiChildRenderObjectElement，包含多个 Widget，比如 Column、Row、Stack。

**基础 Widget：**

- Text
  - TextSpan
  - TextStyle
  - DefaultTextStyle
- Image
  - ImageProvider
    - AssetImage
    - NetworkImage
- Icon、Icons
- Switch、Checkbox：本身不会保存当前选中状态。
- TextField
  - 获取输入类容：1 TextEditingController ；2 onChange
- Form、TextFormField
- LinearProgressIndicator
- CircularProgressIndicator

**布局类 Widget：**（布局类 Widget 是按照一定的排列方式来对其子 Widget 进行排列）

- 线性弹性布局：Flex、Row、Column、Expanded。
  - 对于这一类控件，如果子 widget 超出屏幕范围，则会报溢出错误。
- 流式布局：Wrap、Flow。
- 层叠布局：Stack、Positioned。
- 对齐布局：Align、Center
  - Alignment 以矩形的中心点作为坐标原点
  - FractionalOffset 坐标原点为矩形的左侧顶点，和布局系统的一致

**容器类布局：**（容器类Widget一般只是包装其子Widget，对其添加一些修饰）

- Padding 可以给其子节点添加填充（留白），和边距效果类似。
  - EdgeInsets
- 尺寸限制类容器：
  - ConstrainedBox、SizedBox、UnconstrainedBox
  - AspectRatio 可以指定子组件的长宽比
  - LimitedBox 可以指定最大宽高
  - FractionallySizedBox 可以根据父容器宽高的百分比来设置子组件宽高
- 装饰容器：
  - DecoratedBox 可以在其子组件绘制前(或后)绘制一些装饰（Decoration），如背景、边框、渐变
- 变换:
  - Transform 可以在其子组件绘制时对其应用一些矩阵变换来实现一些特效，变换阶段是绘制阶段。
  - RotatedBox 可以对子组件进行旋转变换，变换阶段是 layout 阶段。
- Container：一个组合类容器，它本身不对应具体的RenderObject，它是 DecoratedBox、ConstrainedBox、Transform、Padding、Align 等组件组合的一个多功能容器，所以我们只需通过一个 Container 组件可以实现同时需要装饰、变换、限制的场景。
- **Scaffold**：一个完整的路由页可能会包含导航栏、抽屉菜单(Drawer)以及底部Tab导航菜单等。
  - AppBar
  - MyDrawer
  - BottomNavigationBar
  - FloatingActionButton
  - TabBarView
- 用于裁剪的 Widget：
  - ClipOval：子组件为正方形时剪裁为内贴圆形，为矩形时，剪裁为内贴椭圆
  - ClipRRect：将子组件剪裁为圆角矩形
  - ClipRect：剪裁子组件到实际占用的矩形大小（溢出部分剪裁）
  - CustomClipper：自定义裁剪区域  

**列表与滚动类组件**：当组件内容超过当前显示视口(ViewPort)时，如果没有特殊处理，Flutter 则会提示 Overflow 错误，这种情况下我们需要使用滚动布局：

1. Scrollable 基础滚动组件实现。
2. ScrollPhysics 用于配置边缘拉拽效果。
3. Scrollbar 用于实现滚动条的组件。
4. 基于 Sliver 的延迟构建与组合滑动。
5. SingleChildScrollView 类似于 Android 中的 ScrollView，不支持基于 Sliver 的延迟实例化模型。
6. ListView，构造方式：1 children；2 ListView.builder。
7. GridView 表格布局，需要专注的参数是 SliverGridDelegate，即控制 GridView 子组件如何排列：
   1. SliverGridDelegateWithFixedCrossAxisCount 横轴为固定数量子元素的layout算法
   2. SliverGridDelegateWithMaxCrossAxisExtent 横轴子元素为固定最大长度的layout算法
8. 复杂 Grid 布局实现可以使用 pub 上的 flutter_staggered_grid_view 库。
9. CustomScrollView 可以使用Sliver来自定义滚动模型（效果）的组件。
10. 滚动监听：
    1. ScrollController 控制可滚动组件的滚动位置。
    2. PageStorage 用于在特定情况下保存页面(路由)相关数据的组件。
    3. ScrollPosition：ScrollController。
    4. NotificationListener 另一个监听滚动的组件。

**功能型 Widget**：不会影响UI布局及外观的Widget，它们通常具有一定的功能，如事件监听、数据存储等

- WillPopScope 用于拦截返回键
- InheritedWidget 用于共享数据
- Theme 用于自定义主题样式
- 异步加载：
  - FutureBuilder
  - StreamBuilder
  
**对话框与提示**：

- Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("$result"))); 用于弹出一个 SnackBar。
- showDialog Material组件库提供的一个用于弹出Material风格对话框的方法
- SimpleDialog Material组件库提供的对话框，它会展示一个列表，用于列表选择的场景。
  - AlertDialog 和 SimpleDialog 中不能使用延迟加载模型的组件，比如 ListView、GridView 等。
- Dialog：AlertDialog、SimpleDialog 都继承自 Dialog，它们三者是 Material 组件库提供的对话框，旨在帮助开发者快速构建出符合 Material 设计规范的对话框。
- showDialog 方法中不一定就要返回 Dialog 类型的组件，其他 Widget 也可以。
- showGeneralDialog：展示对话框的基础方法，showDialog 基于此封装。
- 对话框状态管理
  - 单独抽离出StatefulWidget
  - StatefulBuilder
  - context 即 Element
- showModalBottomSheet
- showBottomSheet 原理与 showModalBottomSheet 不同，依托于 Scaffold 组件。
- Loading
  - 使用 UnconstrainedBox 消除 showDialog 对框体 size 的限制
- showDatePicker
- showCupertinoModalPopup IOS 风格的底部对话框

具体参考：

1. [Widgets 目录](https://flutterchina.club/widgets/)
2. [Widget catalog](https://flutter.dev/docs/development/ui/widgets)
3. [widgets index](https://flutter.dev/docs/reference/widgets)

### Widget 如何管理自己的状态

- 自己管理。
- parent 管理。
- 混合方式管理。
- 全局状态管理。

### 文字绘制

- [How can I get the size of the Text Widget in flutter](https://stackoverflow.com/questions/52659759/how-can-i-get-the-size-of-the-text-widget-in-flutter)
- [图解 TextPainter 与 TextSpan 小尝试](https://www.jianshu.com/p/0fd1eaea6269)

### Flutter 动画——[Animation](https://flutter.dev/docs/development/ui/animations)

- Tween
- AnimationController
- AnimatedWidget
- AnimatedBuilder
- Hero 动画
- Staggered Animation

## 2 网络与存储

Json 解析

- 使用 `dart:convert` 手动解析
- <https://pub.dartlang.org/packages/json_serializable>
- <https://pub.dev/packages/built_value>
- 相关问题：
  - [How to Deserialize a list of objects from json in flutter](https://stackoverflow.com/questions/51053954/how-to-deserialize-a-list-of-objects-from-json-in-flutter)

## 3 架构模式

### 使用 Provider 进行状态管理

- [Provider doc](https://pub.dev/documentation/provider/latest/)
- [Flutter | 状态管理指南篇——Provider](https://juejin.im/post/5d00a84fe51d455a2f22023f)
- [Flutter Provider 3.0实战教程](https://juejin.im/post/5d2c19c6e51d4558936aa11c)

## 网络与存储

- [ ] todo

## 4 其他

### Flutter In StackOverflow

- [如何模拟 RelativeLayout 布局](https://stackoverflow.com/questions/44396075/equivalent-of-relativelayout-in-flutter)
- [Where does the title of Material App used in flutter?](https://stackoverflow.com/questions/50615006/where-does-the-title-of-material-app-used-in-flutter)
- [navigator-pass-arguments-with-pushnamed](https://stackoverflow.com/questions/53304340/navigator-pass-arguments-with-pushnamed)
- [如何绘制](https://stackoverflow.com/questions/46241071/create-signature-area-for-mobile-app-in-dart-flutter)
- [how-can-flutter-handle-dpi-text-and-image-size-differences](https://stackoverflow.com/questions/44173641/how-can-flutter-handle-dpi-text-and-image-size-differences)
- [how-to-use-dependecy-injection-in-flutter](https://stackoverflow.com/questions/44131766/how-to-use-dependecy-injection-in-flutter)

### Libraries

- <https://pub.dev/packages/provider>
- <https://pub.dev/packages/auto_size_text>
- <https://api.flutter.dev/flutter/dart-core/DateTime-class.html>
- [OpenFlutter](https://github.com/OpenFlutter)
- [fish-redux](https://github.com/alibaba/fish-redux)，[Flutter 应用框架 Fish Redux](https://mp.weixin.qq.com/s/JiCsU6qoIFJPct0FyYn8eA)
- [flutter_boost](https://github.com/alibaba/flutter_boost)：新一代Flutter-Native混合解决方案。 FlutterBoost是一个Flutter插件，它可以轻松地为现有原生应用程序提供Flutter混合集成方案。
- [best-flutter](https://github.com/best-flutter)一群热爱flutter的开发者，开源了许多插件。
- [awesome-flutter](https://github.com/Solido/awesome-flutter)
