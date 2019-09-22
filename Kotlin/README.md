## 1 Kotlin 简介

Kotlin主要是由俄罗斯圣彼得堡的JetBrains开发团队所发展出来的编程语言，其名称来自于圣彼得堡附近的科特林岛。Kotlin是一门 **静态的强类型编程语言**，可以运行在JVM上，但不限于JVM。Kotlin 与所有基于 Java 的框架完全兼容，应用领域有 **服务端开发、Android开发、Kotlin For JavaScript、Kotlin Native**，可以说是全栈语言。

Kotlin 领域：

- Kotlin Script，直接运行.kts文件
- gradle脚本
- web开发
- javaFX
- 前端开发，编译为JavaScript
- native，与c代码交互，不依赖JVM

kotlin 发展简史：

- 2010 立项
- 2011.6 公开
- 2012.2 开源
- 2013.8 支持 AndroidStudio
- 2014.4.6 全新web站点 `kotlinlang.org`
- 2016.2 发布1.0
- 2016.9 支持 apt
- kotlin 生成的字节码默认支持 java6

## 2 Kotlin 学习资料

### 1 文档与资料

- [官网](https://kotlinlang.org/)
- [官方：kotlin-examples](https://github.com/JetBrains/kotlin-examples)
- [Kotlin 中文站](https://www.kotlincn.net/)
- [Ktor 中文站](https://ktor.kotlincn.net/)

Books：

- [《Kotlin实战》](https://panxl6.gitbooks.io/kotlin-in-action-in-chinese/content/introduction.html)
- [《Atomic Kotlin》](https://www.atomickotlin.com/atomickotlin/)

Collections：

- [Collections杂谈(一)](https://mp.weixin.qq.com/s?__biz=MzIzMTYzOTYzNA==&mid=2247484478&idx=1&sn=7761fd02ff5a6e9503a572085cc4bf5a&chksm=e8a05b03dfd7d2155c98dbbb2a2b0e32cac57d194794358161121364daec67bf325acd083a66&mpshare=1&scene=1&srcid=&sharer_sharetime=1565312916247&sharer_shareid=837da3c9c7d8315352e3f3c120932755#rd)

### 2 Android

- [Kotlin on Android FAQ](https://developer.android.com/kotlin/faq.html)
- [kotlin-for-android-developers](https://wangjiegulu.gitbooks.io/kotlin-for-android-developers-zh/guan_yu_ben_shu.html)
- [Kotlin Android Extensions: Say goodbye to findViewById](https://antonioleiva.com/kotlin-android-extensions/)
- [kotlin in medium](https://medium.com/androiddevelopers/tagged/kotlin)
- [码上开学-Kotlin系列](https://kaixue.io/)
- [EasyKotlin](https://github.com/JackChan1999/EasyKotlin)
- [EasyKotlin-All](https://github.com/EasyKotli)
- [Kotlin 实战指南 | 如何在大型应用中添加 Kotlin](https://mp.weixin.qq.com/s?__biz=MzAwODY4OTk2Mg==&mid=2652047413&idx=1&sn=d8b248868406fc641b8a11ccc16807a5&scene=21#wechat_redirect)

### 3 项目

- [awesome-kotlin](https://github.com/KotlinBy/awesome-kotlin)
- [awesome-kotlin-cn](https://github.com/kymjs/awesome-kotlin-cn)
- [anko](https://github.com/Kotlin/anko)
- [kovenant](http://kovenant.komponents.nl/)：Kotlin 的简单异步库
- [Kodein](https://github.com/SalomonBrys/Kodein/) Kotlin 依赖注入框架
- [Fuel](https://github.com/kittinunf/Fuel) Kotlin 网络请求库
- [kotlinpoet](https://github.com/square/kotlinpoet) 类似 square 的 javapoet，用于生成 kotlin 代码
- [Apt-Utils](https://github.com/enbandari/Apt-Utils) 与相关教程 [Apt-Tutorials](https://github.com/enbandari/Apt-Tutorials)

### 4 协程

码上开学：

- [Kotlin 的协程用力瞥一眼 - 学不会协程？很可能因为你看过的教程都是错的](https://kaixue.io/kotlin-coroutines-1/)
- [Kotlin 协程的挂起好神奇好难懂？今天我把它的皮给扒了](https://kaixue.io/kotlin-coroutines-2/)

什么是协程：

- [协程-维基百科](https://zh.wikipedia.org/wiki/%E5%8D%8F%E7%A8%8B)
- [协程的好处有哪些？](https://www.zhihu.com/question/20511233/answer/24260355)

文档：

- [kotlinx.coroutines guide en](https://github.com/Kotlin/kotlinx.coroutines)
- [kotlinx coroutines guide cn](https://www.kotlincn.net/docs/reference/coroutines.html)
- [kotlinx coroutines api doc](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/)

文档（中文）：

- [kotlinx.coroutines cn](https://github.com/hltj/kotlinx.coroutines-cn)
- [kotlinx.coroutines cn](https://saplf.gitbooks.io/kotlinx-coroutines/content/)

破解协程系列：

- [破解 Kotlin 协程(1) - 入门篇](https://juejin.im/post/5ceb423451882533441ece67)
- [破解 Kotlin 协程(2) - 协程启动篇](https://juejin.im/post/5ceb464ef265da1b7c60f626)
- [破解 Kotlin 协程(3) - 协程调度篇](https://juejin.im/post/5ceb4749518825141c356cbe)
- [破解 Kotlin 协程(4) - 异常处理篇](https://juejin.im/post/5ceb480de51d4556da53d031)
- [破解 Kotlin 协程(5) - 协程取消篇](https://juejin.im/post/5ceb48d2e51d45109b01b120)
- [破解 Kotlin 协程(6) - 协程挂起篇](https://juejin.im/post/5ceb494851882532b93019e2)
- [破解 Kotlin 协程(7) - 序列生成器篇](https://juejin.im/post/5cfe19025188252ee72966ee))
- [破解 Kotlin 协程(8) - Android 篇](https://juejin.im/post/5cfe1947e51d45105d63a4e3)
- [破解 Kotlin 协程(9) - Channel 篇](https://mp.weixin.qq.com/s/8j74bn9x0-gFmZxa6k6GwA)

Sample：

- [coroutine-recipes 协程风格代码](https://github.com/dmytrodanylyk/coroutine-recipes)
- [google-codelabs：kotlin-coroutines](https://codelabs.developers.google.com/codelabs/kotlin-coroutines/#0)

教程：

- [Kotlin 系统入门到进阶视频教程](http://coding.imooc.com/class/108.html)
- [基于 GitHub App 业务深度讲解 Kotlin1.2高级特性与框架设计](https://coding.imooc.com/class/232.html)

博客：

- [Kotlin Coroutines(协程)](https://blog.dreamtobe.cn/kotlin-coroutines/)
- [深入浅出 Kotlin 协程](https://cloud.tencent.com/developer/article/1334825)
- [了解Kotlin协程实现原理这篇就够了](https://ethanhua.github.io/2018/12/24/kotlin_coroutines/)

RxJava VS Coroutines

- [RxJava to Kotlin coroutines](https://medium.com/androiddevelopers/rxjava-to-kotlin-coroutines-1204c896a700)
- [Kotlin coroutines vs RxJava: an initial performance test](https://proandroiddev.com/kotlin-coroutines-vs-rxjava-an-initial-performance-test-68160cfc6723)
- [Forget RxJava: Kotlin Coroutines are all you need. Part 1/2](https://proandroiddev.com/forget-rxjava-kotlin-coroutines-are-all-you-need-part-1-2-4f62ecc4f99b)
