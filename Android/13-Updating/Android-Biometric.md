# Android Biometric

## 1 API 兼容与变更

6.0 之前的系统

1. 没有官方API。
2. 6.0 以下的高端手机，部分厂商自行添加了指纹功能，需要集成相关 SDK 才能使用。
3. 现在可以不考虑这部分用户，毕竟现在 6.0 的系统本来就比较少，更别说还是带有指纹识别的。

6.0 系统

- FingerprintManager 用于指纹验证

后续 support 包升级

- FingerprintManager 被标记 deprecated
- support v4 库中添加了 FingerprintManagerCompat 类，对 FingerprintManager 做了一定的封装，包括 SDK 版本的判断、对于加密部分的处理等，其本质还是在用 FingerprintManager 来实现指纹识别功能。

9.0 系统

- FingerprintManager 被废弃。
- 新增了 BiometricPrompt 类，BiometricPrompt 即生物识别提示。
- BiometricPrompt 旨在由系统提供统一的生物识别认证功能，包括指纹、虹膜、人脸等。但此时只包含指纹识别功能。
- 使用 BiometricPrompt 相 关API 时，不能够自定义 UI，系统采用了底部弹框方式。

10.0 系统

- BiometricManager 类，开发者可用其查询生物识别身份验证的可用性。
- BiometricPrompt 包含指纹和人脸识别身份验证集成。

androidx.biometric 库

- androidx.biometric 是 AndroidX 中推出的

具体参考[AOSP-生物识别](https://source.android.google.cn/security/biometric?hl=zh-cn)。

## 2 实现指纹认证

- [ ] todo

### CryptoObject 的作用

### 相关引用

博客：

- [An Android Fingerprint Authentication Tutorial](https://www.techotopia.com/index.php/An_Android_Fingerprint_Authentication_Tutorial)

第三方库：

- [Fingerprint](https://github.com/OmarAflak/Fingerprint)

## 3 使用 androidx.biometric 库实现指纹认证

参考：[google-security-samples](https://github.com/android/security-samples)

## 4 指纹认证的安全性

- [Android Fingerprint Security](https://infinum.com/the-capsized-eight/android-fingerprint-security)
