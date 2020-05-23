>[大厂资深面试官 带你破解Android高级面试](https://coding.imooc.com/class/317.html) 笔记

# 7 内存优化

## 7.1 如何避免 OOM

### 考察什么？

- 是否对 Java 内存管理机制有一定认识（中级）
- 是否对 Android 内存优化有一定的经验（高级）
- 是否在代码编写时有良好的习惯以避免内存消耗（高级）

### 题目剖析

- 如何避免 OOM 产生
- 如果优化内存使用

**如何避免 OOM 产生**：

- 已经使用的内存 + 新申请的内存 > 大于可分配的内存
- OOM 几乎覆盖所有的内存区域，通常指堆内存
- Native Heap 在物理内存不够时，也会有 OOM

**使用合适的数据结构**：

- SparseAarray/ArrayMap（适用于数量、增删不频繁）有缩容机制。
- HashMap（数量大于 1000 个或者增删频繁，使用 HashMap）。
- 避免使用枚举(24字节)，推荐使用Int(4字节)，配合 IntDef 注解使用。
- Kotlin 可以使用内联类，在一定程度上避免带来枚举。

**Bitmap的使用**：

- 尽量根据实际需求选择合适的分辨率
- 注意原始文件与内存缩放的结果
- 不适用帧动画，使用代码实现动效
- 考虑对 Bitmap 的重采样和复用配置(`inBitmap`)

**谨慎地使用多进程**：

- 一个子进程预加载的资源可能就有几 M
- 谨慎地使用 Large Heap 配置，增加了 GC 时间

**使用 NDK**：

- Native Heap 没有专门的内存限制
- 内存大户的核心逻辑主要在 Native 层（避免了 Java 堆内存的限制）
  - 各类基于 Cocos2dx、Unity 3D 等框架的游戏
  - 游戏以外的 OpenGL 重度用户，例如各大地图 App

**内存优化 5R 法则**（腾讯工程师胡凯总结）：

- Reduce 缩减：降低突破分辨率/重采样/抽疏策略
- Reuse 复用：池化策略/避免频繁创建对象，减小 GC 压力
- Recycle 回收：主动销毁、结束、避免内存泄露/声明周期闭环
- Refactor 重构：更合适的数据结构/更合理的程序架构
- Revalus 重审：谨慎使用 Large Heap/多进程/第三方库

**Android性能优化典范**：

- Google 官方教程

### 点拨

- 高级工程师要有自己的方法论总结

---
## 7.2 如何对图片进行缓存

### 考察什么？

- 是否对淘汰算法有一定的研究（高级）
- 是否对常见的图片加载框架有深入研究（高级）
- 是否对算法效果有验证闭环的意识（高级）

### 题目剖析

- 网络/磁盘/内存缓存
- 缓存算法分析
- 已熟悉的框架为例，分析其缓存机制
- 要有严重算法效果的意识（产出/收益）

**缓存算法**：

- 缓存加载过程
- 哪些缓存、哪些丢弃、什么时候丢弃
- 获取成本
- 缓存成本
- 缓存价值（缓存命中率，该对象缓存是否一直被需要）
- Least Recntly Used(LinkedHashMap)
- Least Frequently Used
- Android LUR 内置实现：`android.util.LruCache` 中的实现是错误的（LinkedHashMap中最后一个元素使用实际上是最近使用的一个元素），应该使用 ``android.suport.v4.util.LruCache``
- Glide LruCache 内置实现
- OkHttp 的 DiskLruCache 实现

---
## 7.3 如何计算图片占用内存的大小？

### 考察什么？

- 是否了解图片加载到内存的过程以及变换（高级）
- 是否清除如何对图片占用大小进行比较（高级）

### 题目剖析

- 注意是占用内存，不是文件大小
- 可以运行时获取
- 重要的是掌握直接计算的方法

**基础知识**：

- density 像素密度
- densityDpi 点与实际像素的关系

**运行时获取 Bitmap 大小的方法**：

```java
//图片占用多大的理论需求值
public final int getByteCount(){
    if(mRecycled){
        return 0;
    }
    return getRowBytes() * getHeight();
}

//图片实际占用内存大小（与 inBitmap 有关，小图片复用大图片内存）
public final int getAllocationByteCount(){
    if(mRecycled){
        return 0;
    }
    return nativeGetAllocation(mNativePtr);
}
```

**图片有哪些来源**：

- assets：等同于文件系统
  - PNG 默认使用 `ARGB_8888` 格式，一个像素 4 个字节。如果没有透明度需求，应该使用 `RGB_565`，一个像素 2 个字节。
  - JPG 默认也使用  `ARGB_8888` 格式，浪费了透明度空间，应该使用 `RGB_565`。
- raw：与 assets 中类似
- drawable：
  - drawable `densityDpi = 1`
  - drawable-hdip：`densityDpi = 1.5`，如果屏幕的 `dpi = 2.15`，那么缩放值为 `原始宽或高 / 1.5 * 2.75`。
  - drawable-nodip：不做缩放

**图片内存体积优化**：

- 根文件存储格式无关
- 使用 imSampleSize：大图 -> 小图
- 使用矩阵变换大小图片：小图 -> 大图
- 使用 RGB_565 来加载不透明图片
- 使用 9-patch
- 不使用图片
  - canvas
  - vectorDrawable

**索引模式的图片**：

- 存储分为两部分，颜色表 + 索引值
- 适用于颜色很少的图片
- 限制：
  - 不能放入 drawable 中，
  - 得到的 Bitmap 不能用于创建 Canvas
  - Android 从未开放过底层的 Indexed Color
  - Android 8.1 开始移除底层 Indexed Color
