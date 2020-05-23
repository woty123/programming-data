# Google Auto

Google的auto框架包括很多模块，利用注解帮开发者生成模板类。

资料：

```groovy
    https://github.com/google/auto
    //自动生成代码 包括Gson和Parcelable都支持
    http://ryanharter.com/blog/2016/03/22/autovalue/
    //Auto生成parcel依赖声明必须放在Dagger2前面
    https://github.com/rharter/auto-value-parcel/issues/64
```

集成(gradle):

```groovy
squaeJavapoetApt          : 'com.squareup:javapoet:1.8.0',//注解处理器工具
autoValue                 : 'com.google.auto.value:auto-value:1.2',//https://github.com/google/auto/blob/master/value/userguide/index.md
autoValueApt              : 'com.google.auto.value:auto-value:1.2',
autoValueParcelApt        : 'com.ryanharter.auto.value:auto-value-parcel:0.2.5',//https://github.com/rharter/auto-value-parcel
autoValueParcelAdapterApt : 'com.ryanharter.auto.value:auto-value-parcel-adapter:0.2.5',
```
