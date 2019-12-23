# App jni 签名验证

仅仅是一个 Sample，不能在生产中使用。

- 不应该明文存储 APK 签名信息。
- 不应该使用反射调用 Java API 获取 APK 签名，因为 Java 层可以被 Hook，而是应该在 Native 中直接通过相关手段获取 APK 签名信息。
