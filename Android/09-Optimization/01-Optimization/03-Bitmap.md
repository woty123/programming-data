# Bitmap 优化

bitmap 优化包括：

- 内存优化，使内存中的图片占用更少的内存。
- 图片压缩，在传输图片的时候，减轻网络压力。

## 1 图片格式选择

- PNG
- JPEG
- WebP

## 2 图片加载与缓存

- 按需加载图片
- 图片的内存与磁盘缓存

## 3 图片的压缩

1. 质量压缩：compress，该压缩不减少像素。
2. 尺寸压缩：canvas。
3. 采样率压缩：inSampleSize。
4. [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo)。

很多 app 都集成了 libjpeg-turbo 库，用于对图片进行压缩，其实 Android 底层 Skia 也使用了 lib-jpeg 库，只是在 Android7.0 以前做了阉割，因为lib-jpeg 采用的 “哈夫曼”编码比较耗性能。

## 继承 libjpeg-turbo

1. 下载 libjpeg-turbo 源码
2. 在 linux 下编译 libjpeg-turbo，获取对应的 `.so` 共享库或者 `.a` 静态库，下面是编译脚本。
3. 在 Android 中使用 libjpeg-turbo，参考[ImageCompress](.././../00-Code/NDK/ImageCompressor/README.md)

## 4 图像处理引擎

- 95年 JPEG处理引擎，用于最初的在PC上面处理图片的引擎。
- 05年 skia开源的引擎，基于JPEG处理引擎的二次开发。便于浏览器的使用。
- 07年 安卓上面用的什么引擎？skia引擎阉割版。谷歌拿了skia去掉一个编码算法——哈夫曼算法。采用定长编码算法。但是解码还是保留了哈夫曼算法。导致了图片处理后文件变大了。理由是：当时由于CPU和内存在手机上都非常吃紧 性能差，由于哈夫曼算法非常吃CPU，被迫用了其他的算法。

## 5 相关参考资料

- 参考 [高性能图片压缩 —— libjpeg-turbo 的编译与集成](https://juejin.im/post/5cb1d6f7518825186d653aa7)
- 参考[Android图片压缩的几种方案](https://mp.weixin.qq.com/s/-ixGY5E34Fbsy0N3-XTk-Q?)