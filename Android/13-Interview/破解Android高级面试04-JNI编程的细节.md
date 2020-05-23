>[大厂资深面试官 带你破解Android高级面试](https://coding.imooc.com/class/317.html) 笔记

# 4 JNI 编程的细节

---
## 4.1 CPU 架构适配需要注意哪些问题？

### 考察什么？

- 是否有 Native 开发经验（中级）
- 是否关注过 CPU 架构适配（中级）
- 是否有过含 Native 代码的 SDK 开发经历（中级）
- 是否针对 CPU 架构适配做出过包体积优化（高级）

### 题目剖析

- native 开发才需要关注 CPU 架构适
- 不同 cpu 架构之间的兼容性
- so 太多，如何优化 apk 体积
- sdk 开发者应该提供哪些 so 库

**cpu 架构之间的兼容性**：

- mip（已经废弃）
- mips 64（已经废弃）
- x86
- x86_64
- armeabi
- armeabi_v7a
- arm64_v8a
- armeabi 兼容 x86 和 其他 arm 架构

**系统加载 so 库的顺序**:

- 系统优先加载对应架构目录下的 so 库
- 要提供就提供一整套

**兼容模式的一些问题**：

- 兼容模式运行的 Native 无法获得最佳性能
  - 所以 x86 的电脑上运行 arm 的虚拟机会很慢
- 兼容模式容易出现一些难以排除的内存问题
- 系统优先加载对应架构目录下的 so 库

**如果优化 APP 体积**

- 结果目标用户群体的设备 cpu 架构来选择合适的 so 库。
- 目前兼容性最好的是 armeabi_v7a，大部分机器都是这个。
- 根据设备 cpu 架构动态加载 so 库。
- 线上监控问题，针对性提供 Native 库
- 非启动加载库可云端下发

**优化 so 体积**：

- 默认隐藏所有符号，只暴露必须公开的
- 禁用 C++ Exception 和 RTTI，用处不大
- 不要使用 iostream，优先使用 Android Log
- 使用 gcc-sections 去掉无用代码
- 构建时分包，借助应用市场分发对应的 APK

**SDK 开发注意**

- 尽量不要使用  Natrive 开发
- 尽量优化 Native 库的体积
- 必须提供完整的 CPU 架构依赖

---
## 4.2 Java Native 方法与 Native 函数是怎么绑定的？

### 考察什么？

- 是否有 Native 开发经验（中级）
- 是否面对知识善于发现背后的原因（高级）

### 题目剖析

- 静态绑定：命名规则
- 动态绑定：JVM 注册

**静态绑定**：

- java_类路径名_方法名
- `extern C` 的作用，告诉编译器，编译 Native 函数时，保留名字按照 C 的规则，不能去混淆名字(c++为了避免命名冲突，默认会混淆命名)。
- JNIEXPORT 用于告知编译器，公开该方法符号(即 visibility 位 default)，这样才能被 JVM 发现。
- JNICALL 处理兼容性问题，最好加上。

**动态绑定**：

- 动态绑定任何时候都可以触发。
- 可以借此来实现 so 替换，动态绑定可以覆盖静态绑定。
- 性能由于静态绑定，无需查找
- 重构方便

---
## 4.3 JNI 如何实现数据传递？

### 考察什么？

- 是否有 Native 开发经验（中级）
- 是否对 JNI 数据传递中的细节有认识（高级）
- 是否能够合理地设计 JNI 的界限（高级）

### 题目剖析

**通过 long 类型传递对象指针**：

- Bitmap 在 Native 层也有一个类对应，Bitmap 类中有一个 `long mNativePtr` 用于引用底层的 bitmap 指针。

**字符串的操作**：

- GetStringUTFChars/ReleaseStringUTFChars
  - 返回 `const char*` 型，类似 java 中的 byte
  - 拷贝出 `Modified-UTF-8` 的字节流
  - `\0`编码成 `0xC080`，不会影响 C 字符串结尾
- GetStringChars/ReleaseStringChars
  - 返回 `const jchar*` 类型
  - JNI 函数自动处理字节序转换
- GetStringUTFRegion/GetStringRegion
  - 先在 C 层创建足够容量的空间
  - 将字符串的某一个部分拷贝到开辟好的空间
  - 针对性复制，少量读取时效率更优
- GetStringCritical/ReleaseStringCritical
  - 调用对中间会停止 JVM GC
  - 调用对之间不可有其他的 JNI 操作
  - 调用对可嵌套

**字符串操作的 isCopy**：

- `const char * GetStringUTFChars(JNIEnv *env, jstring string, jboolean *isCopy);`
- `const jchar * GetStringChars(JNIEnv *env, jstring string, jboolean *isCopy);`
- `const jchar * GetStringCritical(JNIEnv *env, jstring string, jboolean *isCopy);`

- `isCopy = false` 表示 native 中的指针指向的字符串就是在 Java 内存分配的。JVM GC 应该保证该内存块不被回收，大部分 JVM 都不会这样实现，因为很繁琐。
- `isCopy = true` 表示 native 中的指针指向的字符串不是在 Java 内存分配的。而是复制一份到 native 内存中。
- 拷贝与否，取决于 JVM 实现。

**对象数组传递**：

- LocalReference 在方法结束后会被自动使用。
- 但 LocalReference 有数量限制，如果一个方法中需要大量创建 LocalReference(比如 for 循环中)，则应该一边释放旧的 LocalReference，一边创建新的 LocalReference。

**DirectBuffer**：

- `ByteBuffer.allocateDirect()`
- 不需要拷贝
- 需要自己处理字节序

---
## 4.4 如何全局捕获 Native 异常？

### 考察什么？

- 是否熟悉 Linux 的信号（中级）
- 是否熟悉 Native 层任意位置获取 jclass 的方法（高级）
- 是否熟悉底层线程与 Java 虚拟机的关系（高级）
- 通过实现细节的考察，确认候选人的项目经验（高级）

### 题目剖析

- 如果捕获异常
- 如何清理 Native 层和 Java 层的资源
- 如何排除定位问题

**捕获 Native 异常**：

- `sigaction()` 函数

**传递异常到 Java 层**：

- javaVM 全局不会变
- 通过  javaVM 可以获取到 JNIEnv 指针
- 返回通过反射调用 Java 层
- 注意：Native 线程需要 attach 到 JVM，才能通过 javaVM 获取 JNIEnv，只有 detach 才能清理期间创建的 Jvm 对象
- ClassLoader 一定要保证一致，可以在初始化时设置全局的 ClassLoader。

```c
static jobject classLoader;

jint setUpClassLoader(JNIEnv *env){
    jclass applicationClass = ent->FindClass("xxx/xxx/xxx/AppContext");//获取 AppContext.class
    jclass classClass = getObjectClass(applicationClass);//获取 java.lang.Class 对象
    jmethodID getClassLoaderMethod = env->GetMethodID(classClass, "getClassLoader", "()Ljava/lang/ClassLoader;");
    classLoader = env->NewGlobalRef(env->CallObjectMethod(applicationClass, getClassLoaderMethod));
    return classLoade == NULL? JNI_ERR:JNI_OK;
}
```

**捕获 Native 异常堆栈**：

- 设备备用栈，防止 SIGSEGV 因栈溢出而出现堆栈被破坏。
- 创建独立线程专门用于堆栈收集并回收至 Java 层。
- 收集堆栈信息：
  - `[4.4.1, 5.0]` 使用内置 `libcorkscrew.so`
  - `5.0+`使用自己编译的 `libnuwind`
- 通过线程关联 Native 异常对应的 Java 堆栈

---
## 4.5 只有 C、C++ 可以编写 JNI 的 Native 库吗？

### 考察什么？

- 是否对 JNI 函数绑定的原理有深入认识（高级）
- 是否有底层开发有丰富经验

### 题目剖析

- Native 程序与 Java 关联的本质是什么？

**JVM 对 Native 函数的要求**：

- 静态绑定
  - 符号绑定
  - 符号符合 Java Native 方法的 `包名_类名_方法名`
  - 符号名按照 C 语言的规则修饰
- 动态绑定
  - 函数本身无要求
  - JNI 可识别入口函数如 JNI_OnLoad 进行注册即可

**可选的 Native 语言**：

- Golang
- Rust
- Kotlin Native
- Scala Native
- 其他语言，理论上都可以

**认识 Kotlin Native**：

- kotlin jvm
- kotlin js
- kotlin native
