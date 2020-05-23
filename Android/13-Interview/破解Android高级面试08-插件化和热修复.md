>[大厂资深面试官 带你破解Android高级面试](https://coding.imooc.com/class/317.html) 笔记

# 8 插件化和热修复

---
## 8.1 如何规避 Android P 对访问私有 API 的限制？

### 考察什么？

- 是否能熟练使用 Java 反射（中级）
- 是否有 Hook 调用系统 API 的开发经验？（高级)
- 是否对底层源码有扎实的语言功底和较强的分析能力（高级）

### 题目剖析

- 私有 API 包括哪些类型
- 如何访问私有 API
- Android P 如何做到对私有 API 的访问限制
- 如果规避这些限制

**私有 API 包括哪些类型**：

- `@hide` 的，把源码拿过来，骗过编译器
- private 的，使用反射，可以修改 final 变量

**Android P 的 API 名单**：

- 白名单：SDK
- 浅灰名单：可以通过反射访问
- 深灰名单：targetApiVersion >= 28 的不允许访问，等同于黑名单
- 黑名单：受限，不能访问

**Android P 对发射做了什么**：

- 底层方法 shouldBlockAccessToMember --> GetHiddenApiAccessFlag

**如何绕过限制**：

- 第一个 hook 点：修改 Runtime 的 hidden_api_policy_（[一种绕过Android P上非SDK接口限制的简单方法](https://zhuanlan.zhihu.com/p/37819685)）
- 第二个 hook 点：`isCallerTrusted`，将 ClassLoader 值为空。
- 第三个 hook 点：`GetHiddenApiExemptions

---
## 8.2 如何实现换肤功能？

### 考察什么？

- 是否了解 Android 的资源加载流程（高级）
- 是否对各种换肤方案有深入的研究和分析（高级）
- 可以借机引入插件化、热修复相关话题（高级）

### 题目剖析

- 主题切换
- 资源加载流程
- 热加载还是冷加载
- 支持哪些资源类型
- 支不支持增量加载

**系统的换肤支持-Theme**：

- 只支持替换主体中配置的属性值
- 资源中需要主动引用这些属性
- 无法实现主体外部加载、动态下载

**资源加载流程**：

- Context.getDrawable/getColor/getString --> Resourse.getDrawable/getColor/getString --> AssetManager.openXmlBlockAsset/openNotAsset/getResoureValue/getResoureText
- Context.obtainStyledAttributes --> Theme.obtainStyledAttributes --> AssetManager.applyStyle

**换肤方案**：

- Resources 缓存字段替换：替换 Resources 中的某些缓存字段。
- Resource 包装，拦截掉原始 Resources 方法的调用。
- AssetManager 替换，sAssetPaths。
- 其他方案...

---
## 8.3 VirtualApk 如何实现插件化？

### 考察什么？

- 是否清楚插件化如何实现插件 APK 的类加载（高级）
- 是否清楚插件化如何实现插件 APK 的资源加载（高级）
- 是否清楚插件化框架如何实现对四个组件的支持（高级）

### 题目剖析

- 不一定是讲 VirtualApk
- 如何处理类加载
- 如何处理资源加载和冲突
- 如何支持四大组件

---
## 8.4 Tinker 如何实现热修复？

### 考察什么？

- 是否有过热修复的实战经验（中级）
- 是否清楚热修复方案如何对代码进行更新（高级）
- 是否清楚热修复方案如何对资源进行更新（高级）
- 是否具备框架设计开发的技术功底和技术素养（高级）

### 题目剖析

- 如何支持代码热修复
- 如何支持资源热修复

**Tinker 工作流程**：

- Old.apk 和 New.apk 计算差分包，客户端合成新包。
- Dex 插队。
