# JavaEE 学习

---

## 1 学习路线

下面收集到四个学习路线，一个比一个难。

- [快速入门Java后端开发的正确姿势](https://mp.weixin.qq.com/s/r3vuy71dXIbiIgGscsjz5g)
- [Java 后端自学之路](http://objcoding.com/2018/02/07/javaweb-learning/)
- [Java后端开发详细学习路线视频教程，串起 Java 后端开发几乎所有主流技术](https://www.bilibili.com/video/BV1GQ4y1N7HD?p=1&share_medium=android&share_plat=android&share_source=COPY&share_tag=s_i&timestamp=1589129297&unique_k=9lqKnN)
- [Java 工程师的成神之路](https://mp.weixin.qq.com/s/IfqEoFliXotzmI9TtWnYaw)

---

## 2 笔记学习路径

- [ ] todo

---

## 3 学习资料

### JavaEE

- [JavaEE 规范](https://www.oracle.com/java/technologies/java-ee-glance.html)

### Tomcat

- [Tomcat 安全部署实战指南](https://klionsec.github.io/2017/12/16/tomcat-sec/)
- [一文带你详解了解Tomcat的Server配置](https://mp.weixin.qq.com/s?__biz=MzI1NDQ3MjQxNA==&mid=2247485915&idx=1&sn=a3edc938ca6fdea6b3365da75cf8c65b&chksm=e9c5f06adeb2797caa773d4befc7d819a9ecfc6d2426628c18551ee792424ac370eedbff061b&mpshare=1&scene=1&srcid=0504YV1OsHez4g6iOVvhGIPw#rd)

### Servlet & JSP

- [IBM-Servlet 工作原理解析](https://www.ibm.com/developerworks/cn/java/j-lo-servlet/)
- [菜鸟教程：Servlet](http://www.runoob.com/servlet/servlet-tutorial.html)
- [菜鸟教程：JSP与标签库](http://www.runoob.com/jsp/jsp-tutorial.html)
- [difference-between-and-in-servlet-mapping-url-pattern](https://stackoverflow.com/questions/4140448/difference-between-and-in-servlet-mapping-url-pattern)
- 请求转发的原理
- Servlet3.0，注解如何设置Filter的优先级
- 请求转发的问题：比如Servlet转发到一个jsp，那么jsp中引用的资源是相对于Servlet路径的，如果Servlet的上级路径与jsp的上级路径不一致，那么jsp中引用的资源将会失效

### Spring

- [IBM：Spring 框架简介](https://www.ibm.com/developerworks/cn/java/wa-spring1/index.html)
- [为什么要有Spring](https://mp.weixin.qq.com/s?__biz=MzI1NDQ3MjQxNA==&mid=2247484822&idx=1&sn=6fbee2a12b31b6102a18d3725671d41b&chksm=e9c5fc27deb275319641c3f30d168b85c7c196fd276d47efa35046b5dc54f5b77174c5bf8808&mpshare=1&scene=1&srcid=041420A1TYYZjBbB6guYzon5#rd)
- [跟我学Spring3](http://jinnianshilongnian.iteye.com/blog/1752171)
- [知乎：如何学Spring](https://www.zhihu.com/question/21196869)
- [spring-framework-4-reference 中文](https://legacy.gitbook.com/book/waylau/spring-framework-4-reference/details)
- [Spring MVC探险](http://www.iteye.com/blogs/subjects/springmvc-explore)
- [知乎：如何学习Spring Boot](https://www.zhihu.com/question/53729800)
- [Spring 4 All](http://www.spring4all.com/)
- [外行人都能看懂的SpringCloud](https://juejin.im/post/5b83466b6fb9a019b421cecc)

## Docker

- [这可能是最为详细的Docker入门吐血总结](http://www.imooc.com/article/255015)

### 书籍

入门：

- 《Spring In Action》第四版，2016，PDF

深入分析原理：

- 《深入分析Java Web技术内幕修订版》，2017，PDF
- 《深入理解Spring 技术内幕》第二版，2012，PDF
- 《Spring揭秘》，2009，PDF

### 项目

- [基于Spring+SpringMVC+Mybatis分布式敏捷开发系统架构，提供整套公共微服务服务模块](https://github.com/shuzheng/zheng)
- [SpringBoot-Learning](https://github.com/dyc87112/SpringBoot-Learning)
- [springmvc-mybatis-learning](https://github.com/brianway/springmvc-mybatis-learning)
- Java并发编程与高并发解决方案：[funiture](https://github.com/kanwangzjm/funiture)
- [spring-boot-examples](https://github.com/ityouknow/spring-boot-examples)
- [Jeecg-Boot 快速开发平台（前后端分离版本）](https://github.com/zhangdaiscott/jeecg-boot)

### 架构演变与设计

- [高性能、高可用平台架构的演变过程](https://mp.weixin.qq.com/s?__biz=MzI0MDQ4MTM5NQ==&mid=2247485616&idx=1&sn=83e8c226c251d297e53efd3da677ce24&chksm=e91b6dacde6ce4baaadec554283d848a398b2336917313462237ef94a20cd4a3a046f77e05d1&mpshare=1&scene=1&srcid=0506PUIxcctaQEuPiUdhZn3I#rd)
- [消息队列常见的几种使用场景介绍](https://mp.weixin.qq.com/s?__biz=MzI1NDQ3MjQxNA==&mid=2247485990&idx=1&sn=ada87d68c18a10bc90ceb03fc1a2a7a4&chksm=e9c5f397deb27a8159434f8aa82815045b2f2fd2690c9bf70e9ac0c147a54ce95bf16f9f20f2&mpshare=1&scene=1&srcid=0507sSuflEqCV1evVBSsAp8k#rd)
- [如何构建一个较为通用的业务技术架构](https://mp.weixin.qq.com/s?__biz=MzU5OTMyODAyNg==&mid=2247484751&idx=1&sn=a9662584e821a296902e28d1ec6767a8&chksm=feb7d13ac9c0582cdc989d417ddfa1f2474c07aa5f9cca339bac9fff46b2740e6020dcdf4714&mpshare=1&scene=1&srcid=0601KAVLqYQyScmYcCKb1YbY#rd)
- [高并发下怎么优化能避免服务器压力过大？](https://mp.weixin.qq.com/s?__biz=MzI0MDQ4MTM5NQ==&mid=2247486577&idx=1&sn=6690cc249eea82cb08fe1d23ba3e2552&chksm=e91b696dde6ce07b032244666544656e7b9f87bbe7fa4a757a82f0407fdd998d355805e3958e&mpshare=1&scene=1&srcid=0808Gf4ojEhvtrVzRinzUZdi#rd)

### Vert.x

`Vert.x`是一个基于 JVM、轻量级、高性能的应用平台，非常适用于最新的移动端后台、互联网、企业应用架构。`Vert.x` 基于全异步Java服务器 Netty，并扩展出了很多有用的特性。

### 数据库

- [MySQL/InnoDB中，乐观锁、悲观锁、共享锁、排它锁、行锁、表锁、死锁概念的理解](https://juejin.im/post/5b5ea32351882519f6477c5c)

### 项目配置

- [idea 创建java web项目ssm-gradle](https://www.cnblogs.com/Im-Victor/p/10857638.html)

---

## 3 待整理

- Tomcat
- Netty
- Jetty
- Redis
- MyBatis
- 微服务
- Dubbo分布式框架
- Kafka

---

## 4 关于SSH

**SSH** 即`Spring+Struts2+Hibernate`，对于Struts2和Hibernate，现在的互联网公司大都不再使用，只有一些老项目才会用到，但还是需要对它们有所了解，比如：**了解它们是做什么的、它们的优点、它们的缺点以及如何被取代的。**

- Struts曾经是最流行的Java Web MVC框架，现在常见的选择是Spring MVC
- Hibernate是一个Java ORM开发框架，ORM是Object Relation Mapping的缩写，现在常见的选择是MyBatis
- 具体参考[Java新手如何学习Spring、Struts、Hibernate三大框架？](https://www.zhihu.com/question/21142149/answer/52383396)
