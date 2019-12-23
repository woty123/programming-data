# 应用安全优化

## 1 应用安全需求

常见反编译工具有：

- apktool：主要用于资源文件的获取
- dex2jar：将 apk 中的 dex 文件编译成 jar 文件
- jd-gui：查看反编译后的 jar 中的 class
- jadx：可直直接查看 APK 中的资源与代码
- enjarify：将 apk 反编译成 java 源码

如果不对 apk 进行加固，那么利用一些工具， apk 中的代码以及相关信息就很容易被反编译出来，从而引发一些安全性问题。在实际工作中，很多业务对安全有较高的要求，下面我在一个真实项目中遇到的安全需求：

1. 代码保护：应提供DEX、SO代码保护功能，防止APP应用程序被反编译。避免移动应用的业务逻辑等暴露。
2. 完整性保护：应提供APP文件完整性保护。
3. 防篡改：需提供防篡改保护功能，防止移动应用程序的代码、图片、配置、布局等被增加、修改或删除。避免移动应用程序被二次打包、添加恶意代码等。
4. 防调试：需提供反调试保护功能，防止移动应用在运行时被动态调试攻击、动态代码注入攻击。避免移动应用程序在运行时内存被修改、调用方法被 hook 等，导致使用者信息泄露或经济损失。
5. 数据防泄漏：支持对数据库文件、sharedpreferences数据文件、webview数据文件、assets资源文件、res资源文件、raw资源文、配置文件、证书文件等透明加密保护，防止数据泄露：
6. 运行环境保护，包括不限于：
   1. 支持敏感页面不可被截屏；
   2. 支持敏感页面不可被录屏；
   3. 支持APP运行过程中，发生劫持行为，自动提示客户。
   4. root检测
   5. 模拟器检测
7. 安全平台能力
   1. 性能监测（首次启动时间、二次启动时间、电量、CPU占用、内存占用 。）
   2. 平台自身防护（SQL注入、命令注入攻击、目录遍历、信息泄露。）

因此掌握常见的 apk 加固手段还是很有必要的。

## 2 把敏感数据写入 so 库

实现双向加密

1. so 层通过反射获取 App 的签名。
2. 把正式签名预配置在 c/c++ 层中。
3. 在 so 加载时验证动态获取的 App 签名与 so 中预留的 App 签名，签名一直才允许正常加载，否则抛出异常。
4. 把 App 用于加密的 Key 或者其他敏感数据放在 so 层中，待 so 层验证签名通过后才可以被获取。

注意

- c/c++ 中放置了敏感数据，对应的 so 也需要防破解，可以先对敏感数据进行多重加密再放在 c/c++ 中，用到的这些敏感数据的时候，先进行复杂的解密方可使用，还可以在解密的过程中增添一些无用的代码，用以增加破解难度。
- native 获取 app 签名时，如果使用反射去调用 java 层的 API，这里很容易被拦截和删改，其实，native 层能通过进程 id 然后在 `/proc/{pid}/cmdline` 找到 packageName，通过 pkgName 找到安装时备份下来的 apk，而 apk 就是 zip 压缩文件，自然能找到里面的签名证书，这样才相对来说安全可靠些去校验 APK 的合法性。具体参考[ndk-application-signature-check](https://stackoverflow.com/questions/30650006/ndk-application-signature-check)。

---
## 2 混淆代码，防止反编译

使用 proguard 进行代码混淆

---
## 3 DEX 加密

需要掌握的相关知识点：

1. 熟悉 Android 类加载机制，了解 Class 最终都是通过通过遍历 dexElements 去加载。
2. Application 绑定过程

dex 加固的主要流程：

1. 开发加固SDK：
   1. 开发加固工具，加固工具用于对 APK 中的 dex 进行加固和重签名。
   2. 开发加固 SDK，SDK 主要提供解密 dex 功能。有加固需求的项目需要依赖该 SDK。
2. 配置过程：
   1. 对于有加固需求的项目，需要依赖加固 SDK。
      1. 在 manifest 中配置程序入口为 SDK 提供的 ProxyApplication。
      2. 在 manifest 中使用 matedata 配置程序自身的 Application。
   2. 有加固需求的项目打包生成 APK。
3. 加固过程（使用加固工具）：
   1. 将 APK 解压，得到 dex 等文件。
   2. 将解压后的所有 dex 文件进行加密。
   3. 重新打包 APK，然后进行 ZipAlign 和重新签名。
4. 解密过程（使用加固 SDK）
   1. 在被加固应用启动时，ProxyApplication 把 Apk 中被加密的 dex 解密出来，然后反射替换类加载器中的 dexElements。
   2. 待 dex 解密和替换完毕，获取程序在 manifest 中配置的程序自身的 Application，利用反射，实例化该 Application，并替换到系统中去。

Dex 加固实战参考：

- [DexEncipher1](../../00-Code/DNDexEncipher1/README.md)
- [DexEncipher2](../../00-Code/DNDexEncipher2/README.md)

---
## 4 使用第三方加固

- 360加固
- 腾讯加固
- 阿里加固

---
## 5 把 HTTP 替换为 HTTPS

HTTP 本身是不安全的通讯协议，HTTPS 在 HTTP 的基础上对双方传输数据进行了加密。

---
## 6 注意代码安全

- 日志：正式版关掉所有日志，避免泄漏敏感信息
- `WebView`：WebView防注入风险
- 本地拒绝服务风险

---
## 相关资料

- [native层实现安全关键信息保护：把敏感数据写入so库](http://www.jianshu.com/p/2576d064baf1)
- [安卓安全开发手册](http://www.jianshu.com/p/500f1fd13b9b)
- [浅谈Android安全](https://www.jianshu.com/p/fe0206f8be5b)
