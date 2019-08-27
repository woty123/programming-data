# Android 中使用协程

## 0 Migration To AndroidX

Google 在 AndroidX 中，针对 Kotlin Coroutine 提供了很多有用扩展，所以推荐先将项目迁移至 AndroidX，具体可以参考 [AndroidX](../Android/08-Architecture/Jetpack-AndroidX.md)

## 1 [Use Kotlin coroutines with Architecture components](https://developer.android.com/topic/libraries/architecture/coroutines)

todo

## 2 CoroutineScope 的选择

### 在 Activity 中

- 协程随着 Activity 的销毁而取消。
  - MainScope 即可满足此需求。
- 协程可以响应 Activity 的各个声明周期

### 在 Fragment 中

需求：

1. 协程随着 Fragment 的 OnDestory 而取消。

方案：

- MainScope 即可满足此需求。

### 在 ViewModel 中

## 引用

- [如何正确的在 Android 上使用协程 ？](https://juejin.im/post/5d5d5aac51882549be53b75b#heading-6)
