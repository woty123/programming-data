# Android Archtitecture References

## Jetpack-AAC

分析Android原生开发的现状：

- [对Google的吐槽：2019年11月，分析Android原生开发的现状](https://mp.weixin.qq.com/s/4Z_Do6kC8WC5u5qnGgZNKw)

AAC work with Dagger2：

- Dagger2 自动注入：[kotlin-architecture-components](https://github.com/satorufujiwara/kotlin-architecture-components)

ViewModel：

- [viewmodels-and-livedata-patterns-antipatterns](https://medium.com/androiddevelopers/viewmodels-and-livedata-patterns-antipatterns-21efaef74a54)
- 使用 Dagger2 注入 SavedStateRegistryOwner 到 ViewModel 中：[saving-ui-state-with-viewmodel-savedstate-and-dagger](https://proandroiddev.com/saving-ui-state-with-viewmodel-savedstate-and-dagger-f77bcaeb8b08#7f89)
- [知识点 | ViewModel 四种集成方式](https://mp.weixin.qq.com/s/Hl8Yuf2bkDlVlgdB4M-wrw)

## 值得研究的项目

Google：

- [Google-android-architecture](https://github.com/googlesamples/android-architecture)
- [android-architecture-components](https://github.com/googlesamples/android-architecture-components)
- [android-sunflower](https://github.com/googlesamples/android-sunflower)

组件化：

- [非常彻底的组件化-auc-frame](https://blankj.com/2019/07/22/auc-frame/)

TDD：

- [AndroidTDDBootStrap](https://github.com/Piasy/AndroidTDDBootStrap)

CleanArchitecture：

- [Android-CleanArchitecture](https://github.com/android10/Android-CleanArchitecture)
- [Android-CleanArchitecture-Kotlin](https://github.com/android10/Android-CleanArchitecture-Kotlin)
- [Android-ReactiveProgramming](https://github.com/android10/Android-ReactiveProgramming)

AOP

- AOP架构之[EasyMVP](https://github.com/6thsolution/EasyMVP)
- AOP架构之[T-MVP](https://github.com/north2016/T-MVP)

从零开始仿写一个抖音app系列

- [从零开始仿写一个抖音App](https://www.jianshu.com/p/e92bd896ac35)
- [从零开始仿写一个抖音App-MyTikTok](https://github.com/dongmin2002345/MyTikTok)

Other：

- [AndroidChromium-理清本项目业务逻辑完全可以胜任国内一线公司工程师](https://github.com/JackyAndroid/AndroidChromium)

## 接口设计

- [从客户端的角度设计后端的接口](http://www.jianshu.com/p/35a7b6f5f92e)

## 软件 UI 框架模式研究

UI 架构史：

- [MVC溯源](http://www.jianshu.com/p/add73330d106)
- [UI架构小史1（GUI Architectures）](http://www.jianshu.com/p/d52e662db75c)
- [UI架构小史2（Interactive Application Architecture Patterns）](http://www.jianshu.com/p/c20449ce1a30)
- [UI架构小史3（MVC/MVP/MVVM）](http://www.jianshu.com/p/96e26ceb2fef)
- [GUI 应用程序架构的十年变迁：MVC、MVP、MVVM、Unidirectional、Clean](https://zhuanlan.zhihu.com/p/26799645)
- [MVC，MVP 和 MVVM 模式如何选择？](https://mp.weixin.qq.com/s?__biz=MzI3OTU0MzI4MQ==&mid=2247485868&idx=1&sn=f6a2e3b380296c2fbf9da3112e12667d&chksm=eb476532dc30ec24f9f94f95d4e30b0177baa7c078b01858f224abff64408d904e7d00a3ba7d&mpshare=1&scene=1&srcid=06200bRr5B4IYUxjdnG0Ux5d#rd)
- [MVC，MVP和MVVM 的图示](http://www.ruanyifeng.com/blog/2015/02/mvcmvp_mvvm.html)

MVX：

- [Android MVP 详解（上）](http://www.jianshu.com/p/9a6845b26856)
- [Android MVP 详解（下）](http://www.jianshu.com/p/0590f530c617)
- [为什么你需要ViewObject](http://www.jianshu.com/p/8217317d4ad1) 与 [别把协议层的Model直接用于业务层的Model](http://www.jianshu.com/p/f28e51ee5430)
- [MVC, MVP, MVVM比较以及区别(上)](http://www.cnblogs.com/JustRun1983/p/3679827.html)、[MVC, MVP, MVVM比较以及区别(下)](http://www.cnblogs.com/JustRun1983/p/3727560.html) 与 [谈谈关于MVP模式中V-P交互问题](http://www.cnblogs.com/artech/archive/2010/03/25/1696205.html)
- [说说Android的MVP模式](http://toughcoder.net/blog/2015/11/29/understanding-android-mvp-pattern/)
- [浅谈 MVC、MVP 和 MVVM 架构模式](https://draveness.me/mvx)
- [如何构建Android MVVM 应用框架](https://tech.meituan.com/android_mvvm.html?utm_source=tool.lu)

架构思考与实践

- [AndroidArchitectureCollection-架构文章合集](https://github.com/CameloeAnthony/AndroidArchitectureCollection)
- [Android应用架构学习笔记](http://mp.weixin.qq.com/s?__biz=MzA3ODg4MDk0Ng==&mid=401668447&idx=1&sn=5b6b6c2ea8e415041498634a2b67699a&scene=23&srcid=0217TGuCBRFE3EiMIp7ftNys#rd)
- [从零开始的Android新项目系列](http://blog.zhaiyifan.cn/2016/03/14/android-new-project-from-0-p1/)
- [Android开发架构思考及经验总结](https://zhuanlan.zhihu.com/p/24614642)
- [Android 开发最佳实践](https://github.com/futurice/android-best-practices/blob/master/translations/Chinese/README.cn.md)
- [苏宁易购Android架构演进史](https://mp.weixin.qq.com/s?__biz=MzUxMzcxMzE5Ng==&mid=2247488720&idx=1&sn=9fb295dbaa1686697c5e1a7e5aaa7123&chksm=f951a193ce2628854a92fbcf1f4b4103dd1b8d29537d8a1db09e9dcbeb5a05e991a45343d804&mpshare=1&scene=1&srcid=0417WopVHCuItM79aGDFhIgX#rd)
- [我对移动端架构的思考](https://juejin.im/post/5b44d50de51d451925627900)
- [Android项目开发如何设计整体架构？](https://www.zhihu.com/question/45517397)

微信架构实践

- [微信Android模块化架构重构实践](https://mp.weixin.qq.com/s/mkhCzeoLdev5TyO6DqHEdw)
- [实现微信 pins 工程](https://segmentfault.com/a/1190000015798515)

其他架构：

- [Flux 架构入门教程](http://www.ruanyifeng.com/blog/2016/01/flux.html)
- [Android Fulx](http://androidflux.github.io/)
- [android-flux-architecture](https://github.com/satorufujiwara/android-flux-architecture)
- [kotlin-android-flux](https://github.com/satorufujiwara/kotlin-android-flux)
- [Redux 入门教程](http://www.ruanyifeng.com/blog/2016/09/redux_tutorial_part_one_basic_usages.html)

## 关于烂代码的那些事

- [关于烂代码的那些事（上）](http://blog.2baxb.me/archives/1343)
- [关于烂代码的那些事（中）](http://blog.2baxb.me/archives/1378)
- [关于烂代码的那些事（下）](http://blog.2baxb.me/archives/1499)

## 架构系列文章

### App架构设计经验谈

- [App架构设计经验谈:接口的设计](http://keeganlee.me/post/architecture/20160107)
- [App架构设计经验谈:技术选型](http://keeganlee.me/post/architecture/20160114)
- [App架构设计经验谈:数据层的设计](http://keeganlee.me/post/architecture/20160120)
- [App架构设计经验谈:业务层的设计](http://keeganlee.me/post/architecture/20160214)
- [App架构设计经验谈:展示层的设计](http://keeganlee.me/post/architecture/20160222)

### App重构之路

- [Android项目重构之路:架构篇](http://keeganlee.me/post/android/20150605)
- [Android项目重构之路:界面篇](http://keeganlee.me/post/android/20150619)
- [Android项目重构之路:实现篇](http://keeganlee.me/post/android/20150629)