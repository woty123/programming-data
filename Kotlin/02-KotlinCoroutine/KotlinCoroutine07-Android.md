# Android 中使用协程

## 0 Migration To AndroidX

Google 在 AndroidX 中，针对 Kotlin Coroutine 提供了很多有用扩展，所以推荐先将项目迁移至 AndroidX，具体可以参考 [AndroidX](../Android/08-Architecture/Jetpack-AndroidX.md)

## 1 Getting Start

### [Use Kotlin coroutines with Architecture components]

官方文档 [Use Kotlin coroutines with Architecture components](https://developer.android.com/topic/libraries/architecture/coroutines) 中主要介绍了 Google 在 Architecture components 中针对 Coroutines 提供的各种扩展，以便开发者更高效地使用 Kotlin Coroutines，主要包括：

- ViewModel 上的协程支持：ViewModelScope
- 生命周期组件上的协程支持：LifecycleScope
- 针对 LiveData 的 Coroutines 扩展

### [Improve app performance with Kotlin coroutines](https://developer.android.com/kotlin/coroutines)

官方文档 [Improve app performance with Kotlin coroutines](https://developer.android.com/kotlin/coroutines)（使用协程来优化 APP 性能）中针对使用 Kotlin Coroutines 提出了一些建议：

- 推荐使用协程来执行长耗时任务。
- 介绍了协程提供的几种 Dispatcher，每个协程都需要运行在一个 Dispatcher 上，我们需要针对不同的任务类型来选择合适的 Dispatcher。
- 使用 withContext 来优化性能。
- 使用 Android Architecture components 中提供的 CoroutineScope 来管理协程。
- 使用 launch 或 async 来启动协程。
- 并行分解：使用 async 同时启动多个协程，使用 await 或 awaitAll 来等待协程返回结果。
- Android Architecture components 提供的针对使用 Kotlin Coroutines 的扩展。

## 2 CoroutineScope 的选择

CoroutineScope 用于创建协程，同时还管理着写成的执行与取消，在不同的组件中选择合适的 CoroutineScope 很重要。

### 在 Activity/Fragment

在 Activity/Fragment 主要有以下需求：

- 协程随着 Activity/Fragment 的销毁而取消
- 协程可以与 Activity/Fragment 的各个生命周期联动

针对以上需求，我们可以选择：

- [MainScope](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-main-scope.html) 即可满足此需求。
- AndroidX 针对 Lifecycle 提供了各种扩展：

```kotlin
suspend fun <T> LifecycleOwner.whenCreated(block: suspend CoroutineScope.() -> T): T =
    lifecycle.whenCreated(block)

suspend fun <T> Lifecycle.whenCreated(block: suspend CoroutineScope.() -> T): T {
    return whenStateAtLeast(Lifecycle.State.CREATED, block)
}

suspend fun <T> LifecycleOwner.whenStarted(block: suspend CoroutineScope.() -> T): T =
    lifecycle.whenStarted(block)

suspend fun <T> Lifecycle.whenStarted(block: suspend CoroutineScope.() -> T): T {
    return whenStateAtLeast(Lifecycle.State.STARTED, block)
}
```

### 在 ViewModel 中

AndroidX 针对 ViewModel 提供了 CoroutineScope 支持。

## 引用

Blogs:

- [如何正确的在 Android 上使用协程 ？](https://juejin.im/post/5d5d5aac51882549be53b75b)
- [Android Coroutine Recipes](https://speakerdeck.com/dmytrodanylyk/android-coroutine-recipes)

Official Introductions:

- [Use Kotlin coroutines with Architecture components](https://developer.android.com/topic/libraries/architecture/coroutines)
- [Improve app performance with Kotlin coroutines](https://developer.android.com/kotlin/coroutines)

Coroutines on Android:

- [Coroutines on Android (part I): Getting the background](https://medium.com/androiddevelopers/coroutines-on-android-part-i-getting-the-background-3e0e54d20bb)
- [Coroutines on Android (part II): Getting started](https://medium.com/androiddevelopers/coroutines-on-android-part-ii-getting-started-3bff117176dd)
- [Coroutines On Android (part III): Real work](https://medium.com/androiddevelopers/coroutines-on-android-part-iii-real-work-2ba8a2ec2f45)

Libraries:

- [kotlin-coroutines-android](https://github.com/enbandari/kotlin-coroutines-android) 提供了 Activity/Fragment/View 级别的 coroutineScope，而且这些 Scope 都是与 Activity/Fragment/View 生命周期相关联的，相对于 MainScope，使用起来更加优雅和方便。但是如果已经迁移到 AndroidX 的话，就没必要引入了。
