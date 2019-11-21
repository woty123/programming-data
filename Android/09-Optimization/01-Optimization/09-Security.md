# 应用安全优化

## 1 反编译工具

常见反编译工具有：

- apktool：主要用于资源文件的获取
- dex2jar：将 apk 中的 dex 文件编译成 jar 文件
- jd-gui：查看反编译后的 jar 中的 class
- jadx：可直直接查看 APK 中的资源与代码
- enjarify：将 apk 反编译成 java 源码

如果不对 apk 进行加固，那么 apk 中的代码就很容易被反编译，从而引发一些安全性问题。在实际工作中，很多业务对安全有较高的要求，因此掌握常见的 apk 加固手段还是很有必要的。

## 2 把敏感数据写入 so 库

实现双向加密

1. so 层通过反射获取 App 的签名
2. 把正式签名预配置在 c/c++ 层中
3. 在 so 加载时验证动态获取的 App 签名与 so 中预留的 App 签名，签名一直才允许正常加载，否则抛出异常
4. 把 App 用于加密的 Key 或者其他敏感数据放在 so 层中，待 so 层验证签名通过后才可以被获取。

注意：c/c++ 中放置了敏感数据，对应的 so 也需要防破解，可以先对敏感数据进行多重加密再放在 c/c++ 中，用到的这些敏感数据的时候，先进行复杂的解密方可使用，还可以在解密的过程中增添一些无用的代码，用以增加破解难度。

---
## 2 混淆代码，防止反编译

使用proguard进行代码混淆

---
## 3 DEX 加密

具体参考：

- [DexEncipher1](../../00-Code/DexEncipher1/README.md)
- [DexEncipher2](../../00-Code/DexEncipher2/README.md)

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
