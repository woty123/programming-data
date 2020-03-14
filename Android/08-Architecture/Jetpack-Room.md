# Room

## 1 Room 的使用

参考：

- <https://developer.android.com/training/data-storage/room/index.html>
- <https://medium.com/androiddevelopers/understanding-migrations-with-room-f01e04b07929>

## 2 在多个 Module 中使用 Room

由于 Room 是使用注解在编译期生成对应的 Dao 和 Database 实现，定义的 Entity 都要注解到 RoomDatabase 类上，那么 RoomDatabase  定义在哪里就成了问题。比如放到 base 模块那么就要求所有具体 feature 的 entity 都放到 base 中。尝试在相关社区寻找答案，找到以下资料：

在 [architecture-components-samples/issues/274：How to use Room database across Instant App feature modules?](https://github.com/android/architecture-components-samples/issues/274) 中有人提出三种方案：

1. Option 1 (Database per feature module)
2. Option 2 (Database per app module)
3. Option 3 (Single Database)

在 [Writing a modular project on Android](https://medium.com/mindorks/writing-a-modular-project-on-android-304f3b09cb37) 中，建议采用上述第一种方案，即为每个 feature module 创建单独的 database，但是需要注意的是，如官方文档所说，RoomDatabase 是重量级的对象，应该使用单例模式实现。

[Hard to modularize app with RoomDatabase](https://issuetracker.google.com/issues/67967869)
