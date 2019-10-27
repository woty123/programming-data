# Android 中使用协程

## 0 Migration To AndroidX

Google 在 AndroidX 中，针对 Kotlin Coroutine 提供了很多有用扩展，所以推荐先将项目迁移至 AndroidX，具体可以参考 [AndroidX](../Android/08-Architecture/Jetpack-AndroidX.md)

官方文档 [Use Kotlin coroutines with Architecture components](https://developer.android.com/topic/libraries/architecture/coroutines) 中主要介绍了 Google 在 Architecture components 中针对 Coroutines 提供的各种扩展，以便开发者更高效地使用 Kotlin Coroutines，主要包括：

- ViewModelScope
- LifecycleScope
- LiveData 与 Coroutines

## 2 CoroutineScope 的选择

### 需求：协程随着 Activity/Fragment 的销毁而取消

[MainScope](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-main-scope.html) 即可满足此需求。

### 需求：协程可以与 Activity/Fragment 的各个生命周期联动

AndroidX 针对 Lifecycle 提供了各种扩展：

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

...

```

### 在 ViewModel 中

AndroidX 针对 ViewModel 提供了 CoroutineScope 支持。

### 开源库：[kotlin-coroutines-android](https://github.com/enbandari/kotlin-coroutines-android)

[enbandari](https://github.com/enbandari) 开源的 [kotlin-coroutines-android](https://github.com/enbandari/kotlin-coroutines-android) 是针对 kotlin-coroutines 扩展，提供了 Activity/Fragment/View 级别的 coroutineScope，而且这些 Scope 都是与 Activity/Fragment/View 生命周期相关联的，相对于 MainScope，使用起来更加优雅和方便。

## 引用

- [如何正确的在 Android 上使用协程 ？](https://juejin.im/post/5d5d5aac51882549be53b75b)
- [Android Coroutine Recipes](https://speakerdeck.com/dmytrodanylyk/android-coroutine-recipes)
- [Use Kotlin coroutines with Architecture components](https://developer.android.com/topic/libraries/architecture/coroutines)
- [Improve app performance with Kotlin coroutines](https://developer.android.com/kotlin/coroutines)
- [Coroutines on Android (part I): Getting the background](https://medium.com/androiddevelopers/coroutines-on-android-part-i-getting-the-background-3e0e54d20bb)
- [Coroutines on Android (part II): Getting started](https://medium.com/androiddevelopers/coroutines-on-android-part-ii-getting-started-3bff117176dd)
- [Coroutines On Android (part III): Real work](https://medium.com/androiddevelopers/coroutines-on-android-part-iii-real-work-2ba8a2ec2f45)
