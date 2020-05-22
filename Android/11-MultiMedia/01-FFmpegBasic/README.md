# FFmeng 入门

- [ffmpeg 官网](https://ffmpeg.org/)
- [ffmpeg 官方 wiki](https://trac.ffmpeg.org/wiki)

## 1 简介

FFmpeg 既是一款音视频编解码工具，同时也是一组音视频编解码开发套件，作为编解码开发套件，它为开发者提供了丰富的音视频处理的调用接口。FFmpeg 提供了多种媒体格式的封装和解封装，包括多种音视频编码、多种协议的流媒体、多种色彩格式转换、多种采样率转换、多种码率转换等; FFmpeg 框架提供了多种丰富的插件模块，包含封装与解封转的插件、编码与解码的插件等。

FFmpeg 由法国天才程序员 Fabrice Bellard 在 2000 年的时开发出初版；后来发展到 2004 年， Fabrice Bellard 找到了接手人，这个人至今还在维护 FFmpeg 的 Michael Niedermayer 。Michael Niedermayer 对 FFmpeg 的贡献非常大，其将滤镜子系统 libavfilter 加入 FFmpeg 项目中，使得 FFmpeg 的多媒体处理更加多样、更加方便。在 FFmpeg 发布了 0.5 版本之后，很长一段时间没有进行新版本的发布，直到后来 FFmpeg 采用了 Git 作为版本控制服务器以后才开始继续进行代码更新、版本发布，当然也是时隔多年之后了；2011 年 3 月，在 FFmpeg 项目中有一些提交者对 FFmpeg 的项目管理方式并不满意，因而重新创建了一个新的项目，命名为 Libav, 该项目尽管至今并没有 FFmpeg 发展这么迅速，但是提交权限相对 FFmpeg 更加开放；2015 年 8 月，Michael Niedermayer 主动辞去 FFmpeg 项目负责人的职务。Michael Niedermayter 从 Libav 中移植了大量的代码和功能到 FFmpeg 中，Michael Niedermayter 辞职的主要目的是希望两个项目最终能够一起发展，若能够合并则更好。时至今日，在大多数的 Linux 发行版本系统中已经使用 FFmpeg 来进行多媒体处理

FFmpeg 框架的基本组成包含 libavcodec 、libavformat、libavfilter、libavdevice 、libavutil 等模块。

- libavcodec：编解码库，封装了 Codec 层，但是有一些 codec 是具备自己的 License 的，FFmpeg 不会默认添加像 libx264、FDK-AAC、Lame 等库，但是 FFmpeg 像一个平台，可以将其他的第三方codec以插件的方式添加进来，为开发者提供统一接口
- libavformat：文件格式和协议库，封装了 Protocol 层和 Demuxer、Muxer 层，使得协议和格式对于开发者来说是透明的
- libavfilter：音视频滤镜库，该模块包含了音频特效和视频特效的处理，在使用 FFmpeg 的 API 进行编解码的过程中，可以使用该模块高效的为音视频数据做特效处理
- libavdevice：输入输出设备库，比如需要编译出播放声音或者视频的工具 ffplay，就需要确保该模块是打开的，同事也需要 libsdl 的预先编译，该设备模块播放声音和视频都又是使用libsdl 库
- libavutil：核心工具库，最基础模块之一，其他模块都会依赖该库做一些基本的音视频处理操作
- libswresample：用于音频重采样，可以对数字音频进行声道数、数据格式、采样率等多种基本信息的转换
- libswscale：该模块用于图像格式转换，可以将 YUV 的数据转换为 RGB 的数据
- libpostproc：该模块用于进行后期处理，当我们使用filter的时候，需要打开这个模块，filter会用到这个模块的一些基础函数

比较老的 ffmpeg 还会编译出 avresamle 模块，也是用于对音频原始出具进行重采样的，但是已经被废弃，推荐使用 libswresample 替代另外，库里还可以包含对 H.264/MPEG-4 AVC 视频编码的 X264 库，是最常用的有损视频编码器，支持 CBR、VBR 模式，可以在编码的过程中直接改变码率的设置，在直播的场景中非常适用，可以做码率自适应的功能。

FFmeng 还提供以下几个工具

- ffmpeg-一个流媒体的编解码、格式转换以及多媒体流的内容处理工具
- ffplay-一个使用FFmpeg编解码的播放器
- ffprobe-一个多媒体分析工具
- ffserver-一个流多媒体服务器

## 2 相关资料

### 库

- [VideoCompression](https://github.com/RudreshJR/VideoCompression)，Android Library for VideoCompressionLibrary for VideoCompression
- [RxFFmpeg](https://github.com/microshow/RxFFmpeg)

### 项目

- [WeiXinRecordedDemo](https://github.com/Zhaoss/WeiXinRecordedDemo)

### 学习资料

- [Android 音视频开发打怪升级-系列文章](https://github.com/ChenLittlePing/LearningVideo)
- [Android 音视频开发学习思路](https://www.cnblogs.com/renhui/p/7452572.html)
- [FFMPEG视音频编解码零基础学习方法](http://blog.csdn.net/leixiaohua1020/article/details/15811977)
- [基于FFmpeg+SDL的视频播放器的制作](http://blog.csdn.net/leixiaohua1020/article/details/47068015)
- [音视频入门](https://www.ihubin.com/archives/)
- [WliveTV](https://github.com/wanliyang1990/WliveTV) 付费视频教程
- [FFmpeg音视频开发实战5 iOS/Android/windows/Linux](https://edu.csdn.net/course/detail/2314) 付费视频教程
- [《《音视频开发进阶指南-基于Android/iOS平台的实践》》](http://www.music-video.cn/category/%e9%9f%b3%e8%a7%86%e9%a2%91%e6%9d%83%e5%a8%81%e6%8c%87%e5%8d%97-%e7%9b%ae%e5%bd%95/)
