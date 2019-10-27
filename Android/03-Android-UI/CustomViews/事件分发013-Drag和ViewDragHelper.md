# 拖拽 与 ViewDragHelper

## 1 拖拽的实现方式

- 自定义 ViewGroup，处理事件。
- 使用 `View.startDarg()`、`OnDragListener` 相关 API。
- 使用 ViewGrapHelper。

OnDragListener：

- 使⽤场景：⽤户的「`拖起 -> 放下`」操作，重在内容的移动。可以附加拖拽数据，支持跨进程拖拽。
- 不需要写⾃定义 View，使⽤ `startDrag()` / `startDragAndDrop()` ⼿动开启拖拽
- 拖拽的原理是创造出⼀个图像在屏幕的最上层，⽤户的⼿指拖着图像移动，即拖动的不是 View 本身，而是通过 View 构建出的一块图形。
- ⽤ `setOnDragListener()` 来监听拖拽
  - OnDragListener 内部只有⼀个⽅法：`onDrag()`
  - `onDragEvent()` ⽅法也会收到拖拽回调（界⾯中的每个 View 都会收到）

ViewDragHelper 是在 supportv4 中提供的，用于帮助实现 View 的拖拽逻辑，功能比较强大：

- 使⽤场景：⽤户拖动 ViewGroup 中的某个⼦ View
- 需要应⽤在⾃定义 ViewGroup 中调⽤ ViewDragHelper.shouldInterceptTouchEvent() 和 processTouchEvent()，程序会⾃动开启拖拽
- 拖拽的原理是实时修改被拖拽的⼦ View 的 mLeft, mTop, mRight, mBottom 值

## 2 ViewDragHelper 的使用

参考：

- [Android ViewDragHelper完全解析 自定义ViewGroup神器](https://blog.csdn.net/lmj623565791/article/details/46858663)
- [ViewDragHelper完全解析,妈妈再也不担心我自定义ViewGroup滑动View操作啦](https://www.kancloud.cn/digest/fastdev4android/109673)
- [神器ViewDragHelper完全解析之详解实现QQ5.X侧滑酷炫效果(三十四)](https://www.kancloud.cn/digest/fastdev4android/109672)
- [Android应用ViewDragHelper详解及部分源码浅析](https://blog.csdn.net/yanbober/article/details/50419059)
