# RecyclerView 资料

## 1 入门

### 1.1 RecyclerView 相关组件介绍

- `Adapter` 托管数据集合，为每个Item创建视图
- `ViewHolder`  承载Item视图的子视图
- `LayoutManager` 负责Item视图的布局
- `ItemDecoration`  为每个Item视图添加子视图，比如用来绘制Divider，`onDrawOver`绘制在最上面
- `ItemAnimator`  负责添加、删除数据时的动画效果，默认使用内部的DefaultAnimator，可以参考DefaultAnimator来实现自己的ItemAnimator
- `ItemTouchHelper`用来帮助实现RecyclerView Item的滑动帮助类
- `OnItemTouchListener`用来处理Item的触摸事件接口
- `SnapHelper`  用来帮助实现Snap滑动
- `RecycledViewPool` 多个RecyclerView可以共享一个RecycledViewPool
- `SortedList`如果你的列表需要**批量更新或者频繁删改**，且刚好有明确的**先后顺序**，可以使用`SortedList`。`SortedList`在RecyclerView中，可以很方便的实现这样的功能。如果使用`SortedList`作为RecyclerView数据源，在往集合中添加或者删除数据时，SortedList会自动的通知RecyclerView的Adapter然后RecyclerView调整视图。这一点是很方便的。
- `DiffUtil`当Adapter的数据源发生变化是，使用DiffUtil提供的算法算出数据源的差异，然后让DiffUtil通知Adapter哪些Item需要被刷新
- `AsyncListUtil`用于异步从数据库加载数据

### 1.2 使用步骤

- 实例化RecyclerView
- 为RecyclerView设置LayoutManager
- 为RecyclerView设置Adapater
- 如果有需求，可以设置一个或多个ItemDecorations，当然，也可以不设置
- 如果有需求，可以设置ItemAnimator

### 1.3 有用的方法

#### RecyclerView

```java
    //滑动到当前Scroll + offset
    mRecyclerView.smoothScrollBy(0, 300);
    //滑动到指定位置，position已经显示则不会移动，如果从上往下移动到目标位置则靠上,否则靠下
    mRecyclerView.smoothScrollToPosition();
    //在给定的点上找到最顶端的视图
    findChildViewUnder(float x, float y)
    //根据view找对对应的ItemView
    findContainingItemView(View view)
    //根据位置找到对应的ViewHolder
    findViewHolderForAdapterPosition(int position)
    //https://stackoverflow.com/questions/28709220/understanding-recyclerview-sethasfixedsize
    setHasFixedSize(true)
    //https://stackoverflow.com/questions/32050210/what-is-the-difference-between-swapadapter-method-and-notifydatasetchanged-metho
    swapAdapter(Adapter adapter, boolean removeAndRecycleExistingViews)
```

#### LayoutManager

```java
// 返回当前第一个可见Item的position
layoutManager.findFirstVisibleItemPosition()
// 返回当前第一个完全可见Item的position
layoutManager.findFirstCompletelyVisibleItemPosition()
// 返回当前最后一个可见Item的position
layoutManager.findLastVisibleItemPosition()
// 返回当前最后一个完全可见Item的position
layoutManager.findLastCompletelyVisibleItemPosition()
```

### 1.3 `stableIds(true)` 与 `getItemId(int position)` 的作用

- [How to Avoid That RecyclerView’s Views are Blinking when notifyDataSetChanged()](https://medium.com/@hanru.yeh/recyclerviews-views-are-blinking-when-notifydatasetchanged-c7b76d5149a2)

在调用 notifyDataSetChanged 的时候可能会导致 Item 闪屏，`StableIds(true)` 与 `getItemId(int position)` 可以避免这样的问题：

- `stableIds(true)`：一般子构造 Adapter 时我们将其设置为 true，然后 Adapter 应该为数据源中的分配一个 key，key的作用是在在调用 notifyDataSetChanged 后，用于标识这个位置上的 item 是不是原来的那个。
- `getItemId(int position)`：用于返回 Item 的唯一 id，不推荐返回 positon，而应该返回具有唯一性的业务 id。

使用 stableIds 后，对应相同的 ID，RecyclerView 会尝试使用相同的 ViewHolder 和 View。

### 1.4 Prefetch

Prefetch 功能在版本 25 之后自带的，且默认是开启的，里面有个思路值得学习：计算创建 ViewHolder 所消耗时间的平均值，根据平均值来评估是否需要进行 Prefetch。

### 1.5 四级缓存

四级缓存定义在 Recycler.java  中：

- `mAttachedScrap/mChangedScrap`：用来保存被 RecyclerView 移除掉但最近又马上要使用的缓存，比如说 RecyclerView 中自带 item 的动画效果，本质上就是计算item的偏移量然后执行属性动画的过程，这中间可能就涉及到需要将动画之前的item保存下位置信息，动画后的item再保存下位置信息，然后利用这些位置数据生成相应的属性动画。
- mCachedViews：被划出屏幕的 ViewHolder，不会被立即置为无效，暂时放在 mCachedViews 中，如果往回滑动，可以立即使用其中的 View Holder。
- mViewCacheExtension：用于实现自定义缓存。
- mRecyclerPool：被划出屏幕的且被立即置为无效 ViewHolder。多个 RecyclerView 可以共享一个 RecyclerPool。

### 1.6 保存嵌套 RecyclerView 的滑动状态

一个竖着滑动的 RecyclerView 内部的 Item 可以是横向滑动的 RecyclerView，当横向滑动的 RecyclerView 被划出屏幕然后又滑回来，如何保存这个被嵌套 RecyclerView 的滑动状态呢？当 RecyclerView 被移除屏幕调用其 `onSaveInstanceState`，移回来时调用其 `onRestoreInstanceState` 即可。

## 2 相关资源

### RecyclerView 技术博客

- [RecyclerView一些你可能需要知道的优化技术](https://www.jianshu.com/p/1d2213f303fc)
- [【腾讯Bugly干货分享】RecyclerView 必知必会](https://www.cnblogs.com/bugly/p/6264751.html)
- [如何优雅的实现一个高效、高性能、异步数据实时刷新的列表](https://silencedut.github.io/2019/01/24/%E5%A6%82%E4%BD%95%E4%BC%98%E9%9B%85%E7%9A%84%E5%AE%9E%E7%8E%B0%E4%B8%80%E4%B8%AA%E9%AB%98%E6%95%88%E3%80%81%E9%AB%98%E6%80%A7%E8%83%BD%E3%80%81%E5%BC%82%E6%AD%A5%E6%95%B0%E6%8D%AE%E5%AE%9E%E6%97%B6%E5%88%B7%E6%96%B0%E7%9A%84%E5%88%97%E8%A1%A8/)
- [让你明明白白的使用RecyclerView——SnapHelper详解](https://www.jianshu.com/p/e54db232df62)

### 开源 LayoutManager

- [greedo-layout-for-android-可以顶边Item宽度百分比的布局管理器](https://github.com/500px/greedo-layout-for-android)
- [RecyclerView的CarouselLayoutManager布局管理器，旋转木马](https://github.com/Azoft/CarouselLayoutManager)
- [CarouselLayoutManager](https://github.com/Azoft/CarouselLayoutManager)
- [ChipsLayoutManager](https://github.com/BelooS/ChipsLayoutManager)
- [flexbox-layout](https://github.com/google/flexbox-layout)
- [turn-layout-manager](https://github.com/cdflynn/turn-layout-manager)
- [GalleryLayoutManager](https://github.com/BCsl/GalleryLayoutManager)

### 打造属于自己的 LayoutManager

- [第一部分](https://github.com/hehonghui/android-tech-frontier/blob/master/issue-9/%E5%88%9B%E5%BB%BA-RecyclerView-LayoutManager-Part-1.md)
- [第二部分](https://github.com/hehonghui/android-tech-frontier/blob/master/issue-13/%E5%88%9B%E5%BB%BA-RecyclerView-LayoutManager-Part-2.md)
- [第三部分](https://github.com/hehonghui/android-tech-frontier/blob/master/issue-13/%E5%88%9B%E5%BB%BA-RecyclerView-LayoutManager-Part-3.md)
- [第四部分](https://github.com/hehonghui/android-tech-frontier/blob/master/issue-13/%E5%88%9B%E5%BB%BA-RecyclerView-LayoutManager-Redux.md)

### RecyclerView 源码剖析

- [RecyclerView剖析](http://blog.csdn.net/qq_23012315/article/details/50807224)
- [RecyclerView源码剖析](https://blog.saymagic.tech/2016/10/21/understand-recycler.html)
