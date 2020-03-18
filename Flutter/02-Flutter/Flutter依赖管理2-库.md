# 极客时间 [《Flutter核心技术与实战》](https://time.geekbang.org/column/article/104040)：依赖管理2-库

除了管理这些资源外，pubspec.yaml 更为重要的作用是管理 Flutter 工程代码的依赖，比如第三方库、Dart 运行环境、Flutter SDK 版本都可以通过它来进行统一管理。

## 1 Pub

**包管理工具 Pub**：Dart 提供了包管理工具 Pub，用来管理代码和资源。**包是什么**：从本质上说，包（package）实际上就是一个包含了 pubspec.yaml 文件的目录，其内部可以包含代码、资源、脚本、测试和文档等文件。包中包含了需要被外部依赖的功能抽象，也可以依赖其他包。

Dart 提供了官方的包仓库 Pub 等同于：

- Android 中的 JCenter/Maven
- iOS 中的 CocoaPods
- 前端中的 npm 库

Dart 提供包管理工具 Pub 的真正目的是，让你能够找到真正好用的、经过线上大量验证的库，复用他人的成果来缩短开发周期，提升软件质量。

在 Dart 中包有如下特点：

1. 库和应用都属于包。
2. pubspec.yaml 是包的配置文件，包含了：
   1. 包的元数据（比如，包的名称和版本）
   2. 运行环境（也就是 Dart SDK 与 Fluter SDK 版本）
   3. 外部依赖
   4. 内部配置（比如，资源管理）。

比如：声明一个 flutter_app_example 的应用配置文件，其版本为 1.0，Dart 运行环境支持 2.1 至 3.0 之间，依赖 flutter 和 cupertino_icon：

```yaml
name: flutter_app_example # 应用名称
description: A new Flutter application. # 应用描述
version: 1.0.0
#Dart 运行环境区间
environment:
  sdk: ">=2.1.0 <3.0.0"
#Flutter 依赖库
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ">0.1.1"
```

**版本约束信息**：运行环境和依赖库 cupertino_icons 冒号后面的部分是版本约束信息，由一组空格分隔的版本描述组成，可以支持指定版本、版本号区间，以及任意版本这三种版本约束方式。有以下需要注意：

- 由于元数据与名称使用空格分隔，因此版本号中不能出现空格。
- 由于大于符号“>”也是 YAML 语法中的折叠换行符号，因此在指定版本范围的时候，必须使用引号， 比如`">=2.1.0 < 3.0.0"`。

## 2 包的依赖实践

- **指定版本区间**：对于包，我们通常是指定版本区间，而很少直接指定特定版本，因为包升级变化很频繁，如果有其他的包直接或间接依赖这个包的其他版本时，就会经常发生冲突。
- **统一团队的开发环境**：对于运行环境，如果是团队多人协作的工程，建议将 Dart 与 Flutter 的 SDK 环境写死，避免因为跨 SDK 版本出现的 API 差异进而导致工程问题。

## 3 远程依赖于本地依赖

- **第三方包**：基于版本的方式引用第三方包，需要在其 Pub 上进行公开发布，我们可以访问 <https://pub.dev/> 来获取可用的第三方包。

比如依赖 [DateTime](https://api.flutter.dev/flutter/dart-core/DateTime-class.html) 库：

```yaml
dependencies:
  date_format: 1.0.6
```

- **本地包**：对于不对外公开发布，或者目前处于开发调试阶段的包，我们需要设置数据源，使用本地路径或 Git 地址的方式进行包声明。

下面演示了分别以路径依赖以及 Git 依赖的方式，声明了 package1 和 package2 这两个包：

```yaml
dependencies:
  package1:
    path: ../package1/  # 路径依赖
  date_format:
    git:
      url: https://github.com/xxx/package2.git #git 依赖
```

## 4 `.packages` 与 `pubspec.lock`文件

在开发应用时，我们可以不写明具体的版本号，而是以区间的方式声明包的依赖；但对于一个程序而言，其运行时具体引用哪个版本的依赖包必须要确定下来。因此，除了管理第三方依赖，包**管理工具 Pub 的另一个职责是，找出一组同时满足每个包版本约束的包版本**。包版本一旦确定，接下来就是下载对应版本的包了。

对于 dependencies 中的不同数据源，Dart 会使用不同的方式进行管理，最终会将远端的包全部下载到本地。比如：

- 对于 Git 声明依赖的方式，Pub 会 clone Git 仓库
- 对于版本号的方式，Pub 则会从 pub.dartlang.org 下载包。如果包还有其他的依赖包，Pub 也会一并下载。

### `.packages` 文件

在完成了所有依赖包的下载后，Pub 会在应用的根目录下创建 `.packages` 文件，将依赖的包名与系统缓存中的包文件路径进行映射，方便后续维护。

### `pubspec.lock` 文件

最后，Pub 会自动创建 pubspec.lock 文件。pubspec.lock 文件的作用类似 iOS 的 Podfile.lock 或前端的 package-lock.json 文件，用于记录当前状态下实际安装的各个直接依赖、间接依赖的包的具体来源和版本号。

比较活跃的第三方包的升级通常比较频繁，因此**对于多人协作的 Flutter 应用来说，我们需要把 pubspec.lock 文件也一并提交到代码版本管理中**，这样团队中的所有人在使用这个应用时安装的所有依赖都是完全一样的，以避免出现库函数找不到或者其他的依赖错误。

## 5 依赖第三方资源

除了提供功能和代码维度的依赖之外，包还可以提供资源的依赖。在依赖包中的 pubspec.yaml 文件已经声明了同样资源的情况下，为节省应用程序安装包大小，我们需要复用依赖包中的资源。

示例：依赖一个名为 package4 的包，而它的目录结构是这样的：

```dart
pubspec.yaml
└──assets
    ├──2.0x
    │   └── placeholder.png
    └──3.0x
        └── placeholder.png
```

其中，placeholder.png 是可复用资源。因此，在应用程序中，我们可以通过 Image 和 AssetImage 提供的 package 参数，根据设备实际分辨率去加载图像。

```dart
Image.asset('assets/placeholder.png', package: 'package4');
AssetImage('assets/placeholder.png', package: 'package4');
```

## 5 扩展

现代编程语言大都自带第依赖管理机制，其核心功能是为工程中所有直接或间接依赖的代码库找到合适的版本，但这并不容易。就比如前端的依赖管理器 npm 的早期版本，就曾因为不太合理的算法设计，导致计算依赖耗时过长，依赖文件夹也高速膨胀，一度被开发者们戏称为“黑洞”。而 Dart 使用的 Pub 依赖管理机制所采用的 [PubGrub 算法](https://github.com/dart-lang/pub/blob/master/doc/solver.md)则解决了这些问题，因此被称为下一代版本依赖解决算法，在 2018 年底被苹果公司吸纳，成为 Swift 所采用的[依赖管理器算法](https://github.com/apple/swift-package-manager/pull/1918)。

如果你的工程里的依赖比较多，并且依赖关系比较复杂，即使再优秀的依赖解决算法也需要花费较长的时间才能计算出合适的依赖库版本。**如果我们想减少依赖管理器为你寻找代码库依赖版本所耗费的时间，一个简单的做法就是从源头抓起，在 pubspec.yaml 文件中固定那些依赖关系复杂的第三方库们，及它们递归依赖的第三方库的版本号**。

## 6 思考

1.`pubspec.yaml`、`.packages` 与 `pubspec.lock` 这三个文件，在包管理中的具体作用是什么？

- `pubspec.yaml`是声明依赖哪些包的配置文件。
- `.packages`是表示包在本地目录缓存的地址。
- `pubspec.lock`是把依赖锁死的文件

2.`.packages` 与 `pubspec.lock` 是否需要做代码版本管理呢？为什么？

- `.packages`：自动生成的文件。不应该被加入版本控制 中。
- `pubspec.lock`：这个文件的作用是：记录 每个程序包所引用的具体的版本号，而不是.yaml文件中的记录的 约束范围。它指定程序包所依赖的每个直接和传递依赖项的具体版本和其他标识信息。与仅列出直接依赖关系并允许版本范围的pubspec不同，锁文件将整个依赖关系图全面地固定到特定版本的包。锁定文件可确保您可以重新创建应用程序使用的包的确切配置。应该被加入到版本控制中。

参考 [Dart-包概念](http://yannischeng.com/Dart-%E5%8C%85%E6%A6%82%E5%BF%B5/)
