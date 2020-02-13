# 09-Widget，构建Flutter界面的基石

根据 Flutter 官方的架构图，不难看出 Widget 是整个视图描述的基础。

![04-flutter-arch](images/04-flutter-arch.png "https://flutter.dev/docs/resources/technical-overview")

## 1 Widget 到底是什么

Widget 是 Flutter 功能的抽象描述，**是视图的配置信息，同样也是数据的映射**，是 Flutter 开发框架中最基本的概念。

前端框架中常见的名词，比如视图（View）、视图控制器（View Controller）、活动（Activity）、应用（Application）、布局（Layout）等，在 Flutter 中都是 Widget。

Flutter 的核心设计思想便是“一切皆 Widget”。

## 2 Widget 渲染过程

- 前端界面开发会的问题：**如何结构化地组织视图数据，提供给渲染引擎，最终完成界面显示**。
- 视图树的概念：通常情况下，不同的 UI 框架中会以不同的方式去处理这一问题，但无一例外地都会用到视图树（View Tree）的概念。
  
 Flutter 将视图树的概念进行了扩展，把视图数据的组织和渲染抽象为三部分，即 Widget，Element 和 RenderObject。

 这三部分之间的关系：

 ![](images/09-widget-renderobject-element.png)

### 2.1 Widget

Widget 是 Flutter 世界里对视图的一种结构化描述，可以理解为空间或组件，Widget 是控件实现的**基本逻辑单位**里面存储的是有关视图渲染的配置信息，包括布局、渲染属性、事件响应信息等。

**Widget是不可变的**：Flutter 将 Widget 设计成不可变的，所以当视图渲染的配置信息发生变化时，Flutter 会选择重建 Widget 树的方式进行数据更新，以数据驱动 UI 构建的方式简单高效。

- **缺点**：涉及到大量对象的销毁和重建，所以会对垃圾回收造成压力。
- **优化**：Widget 本身并不涉及实际渲染位图，所以它只是一份轻量级的数据结构，重建的成本很低。
- **收益**：由于 Widget 的不可变性，可以以较低成本进行渲染节点复用，因此在一个真实的渲染树中可能存在不同的 Widget 对应同一个渲染节点的情况，这无疑又降低了重建 UI 的成本。

### 2.2 Element

Element 是 Widget 的一个实例化对象，它承载了视图构建的上下文数据，是连接结构化的配置信息到完成最终渲染的桥梁。Flutter 渲染过程，可以分为这么三步：

1. 首先，通过 Widget 树生成对应的 Element 树；
2. 然后，创建相应的 RenderObject 并关联到 Element.renderObject 属性上；
3. 最后，构建成 RenderObject 树，以完成最终的渲染。

**Element 是中间层：Element**：同时持有 Widget 和 RenderObject。而无论是 Widget 还是 Element，其实都不负责最后的渲染，只负责发号施令，真正去干活儿的只有 RenderObject。

**为什么需要 Element 中间层**：为什么不由 Widget 直接发号施令，而增加中间的这层 Element 树呢？——为了降低性能消耗，因为 Widget 具有不可变性，但 Element 却是可变的。实际上，Element 树这一层将 Widget 树的变化（类似 React 虚拟 DOM diff）做了抽象，**可以只将真正需要修改的部分同步到真实的 RenderObject 树中，最大程度降低对真实渲染视图的修改，提高渲染效率，而不是销毁整个渲染视图树重建**。这就是 Element 树存在的意义。

### 2.3 RenderObject

RenderObject 是主要负责实现视图渲染的对象。

1. Flutter 通过控件树（Widget 树）中的每个控件（Widget）创建不同类型的渲染对象，组成渲染对象树。
2. 渲染对象树在 Flutter 的展示过程分为四个阶段，即`布局、绘制、合成和渲染`。
   1. 其中，布局和绘制在 RenderObject 中完成，Flutter 采用深度优先机制遍历渲染对象树，确定树中各个对象的位置和尺寸，并把它们绘制到不同的图层上。
   2. 绘制完毕后，合成和渲染的工作则交给 Skia 搞定。

Flutter 通过引入 Widget、Element 与 RenderObject 这三个概念，把原本从视图数据到视图渲染的复杂构建过程拆分得更简单、直接，在易于集中治理的同时，保证了较高的渲染效率。

>绘制侧重绘图命令（GPU前），渲染侧重最终呈现（GPU后）

## 3 RenderObjectWidget 介绍

**RenderObjectWidget 负责实际的布局和绘制**：在开发中我们使用 StatelessWidget 和 StatefulWidget 来构建界面，但这两者只是用来组装控件的容器，并不负责组件最后的布局和绘制。在 Flutter 中，布局和绘制工作实际上是在 Widget 的另一个子类 RenderObjectWidget 内完成的。

>StatelessWidget 或 StatefulWidget 最终都要在 build 方法中返回 RenderObjectWidget。

通过 RenderObjectWidget 的源码，来看看其如何使用 Element 和 RenderObject 完成图形渲染工作。

```dart
/// RenderObjectWidgets provide the configuration for [RenderObjectElement]s,
/// which wrap [RenderObject]s, which provide the actual rendering of the
/// application.
abstract class RenderObjectWidget extends Widget {

  @override
  RenderObjectElement createElement();

  @protected
  RenderObject createRenderObject(BuildContext context);

  @protected
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) { }
  ...
}
```

RenderObjectWidget 这个类中同时拥有创建 Element、RenderObject，以及更新 RenderObject 的方法。但实际上，**RenderObjectWidget 本身并不负责这些对象的创建与更新**。

- **对于 Element 的创建**：Flutter 会在遍历 Widget 树时，调用 createElement 去同步 Widget 自身配置，从而生成对应节点的 Element 对象。
- **对于 RenderObject 的创建与更新**：是在 RenderObjectElement 类中完成的。

RenderObjectElement 部分源码如下：

```dart
/// An [Element] that uses a [RenderObjectWidget] as its configuration.
///
/// [RenderObjectElement] objects have an associated [RenderObject] widget in
/// the render tree, which handles concrete operations like laying out,
/// painting, and hit testing.
abstract class RenderObjectElement extends Element {

  RenderObject _renderObject;

  @override
  RenderObjectWidget get widget => super.widget;

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    //实际调用 RenderObjectWidget 的 createRenderObject
    _renderObject = widget.createRenderObject(this);
    attachRenderObject(newSlot);
    _dirty = false;
  }

  @override
  void update(covariant RenderObjectWidget newWidget) {
    super.update(newWidget);
    //实际调用 RenderObjectWidget 的 updateRenderObject
    widget.updateRenderObject(this, renderObject);
    _dirty = false;
  }
  ...
}
```

- **初始创建与渲染**：在 Element 创建完毕后，Flutter 会调用 Element 的 mount 方法。在这个方法里，会完成与之关联的 RenderObject 对象的创建，以及与渲染树的插入工作，插入到渲染树后的 Element 就可以显示到屏幕中了。
- **更新**：如果 Widget 的配置数据发生了改变，那么持有该 Widget 的 Element 节点也会被标记为 dirty。在下一个周期的绘制时，Flutter 就会触发 Element 树的更新，并使用最新的 Widget 数据更新自身以及关联的 RenderObject 对象，接下来便会进入 Layout 和 Paint 的流程。

而真正的绘制和布局过程，则完全交由 RenderObject 完成：

```dart
abstract class RenderObject extends AbstractNode with DiagnosticableTreeMixin implements HitTestTarget {
  ...
  void layout(Constraints constraints, { bool parentUsesSize = false }) {...}
  
  void paint(PaintingContext context, Offset offset) { }
}
```

布局和绘制完成后，接下来的事情就交给 Skia 了。在 VSync 信号同步时直接从渲染树合成 Bitmap，然后提交给 GPU。

### 界面示例

通过下面示例说明 Widget、Element 与 RenderObject 在渲染过程中的关系：

对于下面一个 Row 容器放置了 4 个子 Widget，左边是 Image，而右边则是一个 Column 容器下排布的两个 Text 的布局。

![](images/09-widget-sample.png)

在 Flutter 遍历完 Widget 树，创建了各个子 Widget 对应的 Element 的同时，也创建了与之关联的、负责实际布局和绘制的 RenderObject。

![](images/09-widget-sample-2.png)

## 4 总结

本篇是关于 Widget 的设计思路和基本原理的介绍：

1. Widget 渲染过程：在 Flutter 中视图数据的组织和渲染抽象的三个核心概念，即 Widget、 Element 和 RenderObject。
   1. Widget 是 Flutter 世界里对视图的一种结构化描述，里面存储的是有关视图渲染的配置信息；
   2. Element 则是 Widget 的一个实例化对象，将 Widget 树的变化做了抽象，能够做到只将真正需要修改的部分同步到真实的 Render Object 树中，，最大程度地优化了从结构化的配置信息到完成最终渲染的过程；
   3. RenderObject 负责实现视图的最终呈现，通过布局、绘制完成界面的展示。
2. 阅读 RenderObjectWidget 的代码，理解 Widget、Element 与 RenderObject 这三个对象之间是如何互相配合，实现图形渲染工作的。

>在日常开发学习中，绝大多数情况下，我们只需要了解各种 Widget 特性及使用方法，而无需关心 Element 及 RenderObject。因为 Flutter 已经帮我们做了大量优化工作，因此我们只需要在上层代码完成各类 Widget 的组装配置，其他的事情完全交给 Flutter 就可以了。

## 5 思考

如何理解 Widget、Element 和 RenderObject 这三个概念的？它们之间是一一对应的吗？你能否在 Android/iOS/Web 中找到对应的概念呢？

>Element是可复用的，只要 Widget 前后类型一样。比如 Widget 是蓝色的，重建后变红色了，Element 是会复用的。所以是多个 Widget（销毁前后）会对应一个 Element，而一个Element对应一个RenderObject。
