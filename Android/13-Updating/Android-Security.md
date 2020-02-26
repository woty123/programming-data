# Android 平台安全、加密记录

## 1 Android RSA加密模式和JAVA默认不一致

1. JDK 默认使用：`RSA/ECB/PKCS1Padding`。
2. Android 默认使用：`RSA/ECB/NoPadding`。

在开发中如果后台与客户端涉及到 RSA 加解密，需要注意统一好加密模式。

```java
Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
```

## 相关引用

- [cryptography-changes-in-android-p](https://android-developers.googleblog.com/2018/03/cryptography-changes-in-android-p.html)
- [secure-data-in-android-encrypting-large-data-dda256a55b36](https://proandroiddev.com/secure-data-in-android-encrypting-large-data-dda256a55b36)
- [data-encryption-on-android-with-jetpack](https://android-developers.googleblog.com/2020/02/data-encryption-on-android-with-jetpack.html)
