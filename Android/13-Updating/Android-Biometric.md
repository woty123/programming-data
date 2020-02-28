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

### 2.1 Api23-Api27

在 Api23-Api27 上，我们应该使用 suport/androidx 中的 FingerprintManagerCompat，其对指纹验证做了封装，其主要功能包括：

- 判断手机是否支持指纹验证：isHardwareDetected
- 判断手机上是否录入的指纹：hasEnrolledFingerprints
- 调用系统指纹验证功能：authenticate

在发起指纹验证之前，首先我们应该使用 isHardwareDetected 和 hasEnrolledFingerprints 方法进行判断，如果不支持或者没有录入指纹，则对用户机械能相关提示，如果判断通过，则调用 authenticate 方法发起指纹验证调用，在 Api23-Api27 上，是没有系统级 UI 提示，我们需要开发 UI 提示相关功能。

authenticate 方法：

```java
public void authenticate(
        @Nullable CryptoObject crypto,
        int flags,
        @Nullable CancellationSignal cancel,
        @NonNull AuthenticationCallback callback,
        @Nullable Handler handler) {
            ...
}
```

该方法的作用注释以及说得很清楚：Request authentication of a crypto object. This call warms up the fingerprint hardware and starts scanning for a fingerprint. It terminates when AuthenticationCallback#onAuthenticationError(int, CharSequence)} or AuthenticationCallback#onAuthenticationSucceeded(AuthenticationResult)} is called, at which point the object is no longer valid. The operation can be canceled by using the provided cancel object.

参考说明：

- crypto 用于请求验证的对象，与安全相关。
- flags 预留参数，传 0 即可。
- cancel 用于取消请求，使用场景是比如在用户点击识别框上的“取消”按钮或者“密码验证”按钮后，就要及时取消扫描器的扫描操作。不及时取消的话，指纹扫描器就会一直扫描，直至超时。这会造成两个问题：
  - 耗电。
  - 在超时时间内，用户将无法再次调起指纹识别。
- callback 用于接受验证结果。
- handler 可选参数，用于发送发送指纹验证的事件。

可见最重要的是 AuthenticationCallback 回调：

```java
    public static abstract class AuthenticationCallback {
        public void onAuthenticationError(int errMsgId, CharSequence errString) { }
        public void onAuthenticationHelp(int helpMsgId, CharSequence helpString) { }
        public void onAuthenticationSucceeded(AuthenticationResult result) { }
        public void onAuthenticationFailed() { }
    }
```

AuthenticationCallback 上定义的方法分别对应不同的验证结果：

1. onAuthenticationError：表示此次指纹验证请求遇到了不可恢复的错误，这次请求已经完全结束，之后不会再有回调。errString 可用直接用来提示用户。
2. onAuthenticationHelp：表示此次指纹验证请求遇到了可恢复的错误，这次请求还没有结束，用户还可以再次尝试指纹验证，helpString 可以用于直接提示用户当前出现了什么错误，比如指纹传感器脏了。
3. onAuthenticationSucceeded：指纹验证成功，可以从 result 参数获取我们在调用 authenticate 方法时传入的 CryptoObject。
4. onAuthenticationFailed：表示指纹被识别到了，但是与录入的指纹不匹配，用户还可以再次尝试指纹验证。

### 2.2 Api28

在 Api28 即以上，则使用 android.hardware.biometrics.BiometricPrompt 进行中指纹验证请求，此时系统已经统一了指纹验证 UI 提示，开发者不需要再做这方便工作，只需要在构建 BiometricPrompt 对象时，配置好相关文案即可：

```java
    BiometricPrompt.Builder builder = new BiometricPrompt.Builder(context)
            .setTitle(title)
            .setNegativeButton(cancelText, command -> {
                }, (dialog, which) -> {
            })
            .setSubtitle(subTitle)
            .setDescription(description)

    //构建 BiometricPrompt
    BiometricPrompt biometricPrompt = builder.build();
```

BiometricPrompt 类上也定义了 authenticate，其与 FingerprintManagerCompat 上定义的大同小异。

### 2.3 CryptoObject 的作用

CryptoObject 内部定义了以下三个成员：

```java
        private final Signature mSignature;
        private final Cipher mCipher;
        private final Mac mMac;
```

且同一时刻只能有一个是非 null，就像联合体一样。参考官方示例 [google-security-samples](https://github.com/android/security-samples)，使用的是 Cipher 对象来创建 CryptoObject：

```kotlin

    private lateinit var keyStore: KeyStore

     /**
     * Sets up KeyStore and KeyGenerator
     */
    private fun setupKeyStoreAndKeyGenerator() {
        try {
            keyStore = KeyStore.getInstance("AndroidKeyStore")
        } catch (e: KeyStoreException) {
            throw RuntimeException("Failed to get an instance of KeyStore", e)
        }

        try {
            keyGenerator = KeyGenerator.getInstance(KEY_ALGORITHM_AES, ANDROID_KEY_STORE)
        } catch (e: Exception) {
            when (e) {
                is NoSuchAlgorithmException,
                is NoSuchProviderException ->
                    throw RuntimeException("Failed to get an instance of KeyGenerator", e)
                else -> throw e
            }
        }
    }

    /**
     * Sets up default cipher and a non-invalidated cipher
     */
    private fun setupCiphers():Cipher {
        val defaultCipher: Cipher
        try {
            val cipherString = "AES/CBC/PKCS7Padding"
            defaultCipher = Cipher.getInstance(cipherString)
        } catch (e: Exception) {
            when (e) {
                is NoSuchAlgorithmException,
                is NoSuchPaddingException -> throw RuntimeException("Failed to get an instance of Cipher", e)
                else -> throw e
            }
        }
        return defaultCipher
    }

    /**
     * Creates a symmetric key in the Android Key Store which can only be used after the user has
     * authenticated with a fingerprint.
     *
     * @param keyName the name of the key to be created
     * @param invalidatedByBiometricEnrollment if `false` is passed, the created key will not be
     * invalidated even if a new fingerprint is enrolled. The default value is `true` - the key will
     * be invalidated if a new fingerprint is enrolled.
     */
    override fun createKey(keyName: String, invalidatedByBiometricEnrollment: Boolean) {

        // The enrolling flow for fingerprint. This is where you ask the user to set up fingerprint
        // for your flow. Use of keys is necessary if you need to know if the set of enrolled
        // fingerprints has changed.

        try {
            keyStore.load(null)

            val keyProperties = KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT

            val builder = KeyGenParameterSpec.Builder(keyName, keyProperties)
                    .setBlockModes(BLOCK_MODE_CBC)
                    .setUserAuthenticationRequired(true)
                    .setEncryptionPaddings(ENCRYPTION_PADDING_PKCS7)
                    .also {
                        if (Build.VERSION.SDK_INT >= 24) {
                            it.setInvalidatedByBiometricEnrollment(invalidatedByBiometricEnrollment)
                        }
                    }

            keyGenerator.run {
                init(builder.build())
                generateKey()
            }

        } catch (e: Exception) {
            when (e) {
                is NoSuchAlgorithmException,
                is InvalidAlgorithmParameterException,
                is CertificateException,
                is IOException -> throw RuntimeException(e)
                else -> throw e
            }
        }
    }

    /**
     * Initialize the [Cipher] instance with the created key in the [createKey] method.
     *
     * @param keyName the key name to init the cipher
     * @return `true` if initialization succeeded, `false` if the lock screen has been disabled or
     * reset after key generation, or if a fingerprint was enrolled after key generation.
     */
    private fun initCipher(cipher: Cipher, keyName: String): Boolean {
        try {
            keyStore.load(null)
            cipher.init(Cipher.ENCRYPT_MODE, keyStore.getKey(keyName, null) as SecretKey)
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            when (e) {
                is KeyPermanentlyInvalidatedException -> return false
                is KeyStoreException,
                is CertificateException,
                is UnrecoverableKeyException,
                is IOException,
                is NoSuchAlgorithmException,
                is InvalidKeyException -> throw RuntimeException("Failed to init Cipher", e)
                else -> throw e
            }
        }
    }

    private fun createObj(){
        setupKeyStoreAndKeyGenerator()
        val DEFAULT_KEY_NAME = "a name of the key"
        val cipher = setupCiphers()
        createKey(DEFAULT_KEY_NAME,true)
        initCipher(cipher, DEFAULT_KEY_NAME)
        val object = BiometricPrompt.CryptoObject(cipher)
    }
```

与在 Java 平台的使用方式不同：

```kotlin
    //java 平台 des 加密
    fun encrypt(input: String, password: String): String {
        //1.创建cipher对象，学习查看api文档
        val cipher = Cipher.getInstance(transformation)

        //2.初始化cipher(参数1：加密/解密模式)
        val kf = SecretKeyFactory.getInstance(algorithm)
        val keySpec = DESKeySpec(password.toByteArray())

        val key: Key = kf.generateSecret(keySpec)
        val iv = IvParameterSpec(password.toByteArray())
        // CBC模式需要额外参数
        cipher.init(Cipher.ENCRYPT_MODE, key, iv)

        //3.加密/解密
        val encrypt = cipher.doFinal(input.toByteArray())
        println("加密后字节数组长度=" + encrypt.size)//8
        // base64编码解决乱码问题
        return Base64.encode(encrypt)
    }
```

这里使用的是 Android 平台提供密钥保存机制来生成密钥的：Android 的 Keystore 系统可以把密钥保持在一个难以从设备中取出数据的容器中。当密钥保存到Keystore之后，可以在不取出密钥的状态下进行私密操作。此外，它提供了限制何时以何种方式使用密钥的方法，比如使用密钥时需要用户认证或限制密钥只能在加密模式下使用。

关于 Android 平台提供密钥保存机制，具体参考：

- [Android Keystore 系统](https://developer.android.com/training/articles/keystore.html)
- [KeyGenParameterSpec](https://developer.android.com/reference/android/security/keystore/KeyGenParameterSpec)
- [using-the-android-keystore-system-to-store-sensitive-information-3a56175a454b](https://medium.com/@josiassena/using-the-android-keystore-system-to-store-sensitive-information-3a56175a454b)

关键的部分在于使用 KeyGenParameterSpec 创建 key 的过程：

```kotlin
            val builder = KeyGenParameterSpec.Builder(keyName, keyProperties)
                    //必要设置
                    .setBlockModes(BLOCK_MODE_CBC)
                    .setEncryptionPaddings(ENCRYPTION_PADDING_PKCS7)
                    //一般情况下不需要下面设置
                    .setUserAuthenticationRequired(true)
                    .also {
                        if (Build.VERSION.SDK_INT >= 24) {
                            it.setInvalidatedByBiometricEnrollment(invalidatedByBiometricEnrollment)
                        }
                    }
```

setUserAuthenticationRequired：设置是否只有用户身份认证后，key 才被授权使用。对应到我们请求指纹认证时，传入 CryptoObject，当用户指纹认证通过，CryptoObject 内部的 Cipher 对象所绑定的 key 会被授权，而只有 key 被授权了，绑定这个 key 的 Cipher 对象才能够进行正常的加解密操作。当指纹验证回调成功，我们可以在回调参数中获取传入的 CryptoObject，然后拿 CryptoObject 内部的 Cipher 尝试进行一次加密操作，如果能正常加密则说明此次指纹验证没有安全异常。

setInvalidatedByBiometricEnrollment：设置当在有新的指纹录入时，是否这个 key 应该被至于无效。这个方法设置用于检测在验证指纹的过程中，有没有新的指纹录入系统，如果有，则这个 key 将会失效，此时调用 `cipher.init(Cipher.ENCRYPT_MODE, keyStore.getKey(keyName, null) as SecretKey)` 就会出现异常。

可见，这两个配置都是出于安全考虑。那么**是否应该使用 CryptoObject 呢**？

1. 可以不使用，这不影响整体的验证流程。
2. 使用的 CryptoObject 会使我们的验证过程更加安全可靠。

具体可以参考 [Android 受保护的确认](https://developer.android.com/training/articles/security-android-protected-confirmation)

### 2.4 相关引用

博客：

- [An Android Fingerprint Authentication Tutorial](https://www.techotopia.com/index.php/An_Android_Fingerprint_Authentication_Tutorial)
- [指纹识别-Android](https://www.jianshu.com/p/ab148e3a6ffd)
- [Android指纹识别，提升APP用户体验，从这里开始](https://cloud.tencent.com/developer/article/1474404)

第三方库：

- [Fingerprint](https://github.com/OmarAflak/Fingerprint)

## 3 使用 androidx.biometric 库实现指纹认证

参考：[google-security-samples](https://github.com/android/security-samples)

## 4 指纹认证的安全性

- [Android Fingerprint Security](https://infinum.com/the-capsized-eight/android-fingerprint-security)
