# FFmpeg 播放器开发

本笔记记录从 0 开始开发一个 FFmpeg 播放器。

## 1 播放器原理说明

一个视频文件里面包含了视频流、音频流、字幕等信息，播放视频就是利用 FFmpeg 将里面的信息分别抽取出来，然后借助操作系统提供的 API 将数据展示出来，比如视频就对应着一帧一帧的画面，抽取信息涉及到解封装和解码，具体流程参考下图：

![解封装.png](images/解封装.png)

为什么需要解封装和解码呢？这就涉及到媒体数据的编码与封装了，我们使用使用设备分别对画面和声音进行采集，一定的编码方式存储为保存起来，这就形成了最原始的数据，然后再次通过一定的数据结构把视频数据和音频数据进行整合就形成了我们常见的视频格式了，比如 MP4 等，当然这其中还包括数据压缩等过程，而我们播放视频，其实对就是封装和编码的逆向过程。

## 2 FFmpeg 解码流程与常用结构体

FFmpeg 内部就提供了各种视频编解码算法，不仅如此，还可以将其他第三方算法集成到 FFmpeg 中，比如 x264、lamc、faac、fdkaac。通过代码的方式进行编解码称为软解码，其次有些设备支持硬解码（使用硬件进行解码），硬解码性能较好，Android 中也提供了 MediaCodec 用于编解码，但是其兼容性很不好，所以大部分厂商都会选择集成 FFmpeg 来进行视频应用开发。

这里我们将会使用 FFmpeg 实现一个简单的播放器，其概要架构如下：

![dn-ffmpeg-player-arch.png](images/dn-ffmpeg-player-arch.png)

1. JavaCallHelper：播放视频时，用于和 java 层进行交互，比如 c++ 中播放视频出错，就通过 JavaCallHelper 通知到 java 层，进行 UI 更新。
2. DNFFmpeg：用于对获取音视频信息。

既然要使用 FFmpeg 就需要对其内部常用的结构体和数据进行了解，以及 FFmpeg 的解码流程。

### 解码流程

![ffmpeg-decode-process.png](images/ffmpeg-decode-process.png)

说明：

1. `av_register_all()` 用于注册所有组件。（4.0 及以上版本不再需要调用该函数）
2. `avformat_open_input()`：打开输入视频文件或流，然后可以获取到视频的相关信息，比如视频的宽高、帧率等。
3. `avformat_find_stream_info()`：获取视频文件信息。
4. `avcodec_find_decoder()`：查找解码器。
5. `avcodec_open2()`：打开解码器。
6. `av_read_frame()`：从输入文件读取一帧压缩数据。
   1. 获取不到包，则急速播放。
   2. 获取到 AVPacket 则继续流程。
7. `avcodec_decode_video2()`：解码一帧压缩数据，获取到 AVFrame（像素数据），展示到屏幕视，然后回到步骤 6，反复执行。

### 常用结构体

AVFormatContext：封装格式上下文结构体，全局结构体，保存了视频文件封装格式相关信息

1. iformat：输入视频的 AVInputFormat
2. nb_streams：输入视频的AVStream 个数。
3. streams：输入视频的 `AVStream []` 数组。
4. duration：输入视频的时长（以微秒为单位）。
5. bit_rate：输入视频的码率。

AVInputFormat：每种封装格式对应一个该结构体

1. name：封装格式名称。
2. long_name：封装格式的长名称。
3. extensions：封装格式的扩展名。
4. id：封装格式 ID。。
5. 一些封装格式处理的接口函数

AVStream：视频文件中每个视频（音频）流对应一个该结构体

1. id：序号。
2. codec：该流对应的AVCodecContext。
3. time_base：该流的时基。
4. avg_frame_rate：该流的帧率。

AVCodecContext：编码器上下文结构体，保存了视频（音频）编解码相关信息

1. codec：编解码器的 AVCodec。
2. width, height：图像的宽高。
3. pix_fmt：像素格式。
4. sample_rate：音频采样率。
5. channels：声道数。
6. sample_fmt：音频采样格式。

AVCodec：每种视频（音频）编解码器(例如H.264解码器)对应一个该结构体

1. name：编解码器名称。
2. long_name：编解码器长名称。
3. type：编解码器类型。
4. id：编解码器ID。
5. 一些编解码的接口函数。

AVPacket

1. pts：显示时间戳。
2. dts：解码时间戳。
3. data：压缩编码数据。
4. size：压缩编码数据大小。
5. stream_index：所属的 AVStream。

AVFrame

1. data：解码后的图像像素数据（音频采样数据）。
2. linesize：对视频来说是图像中一行像素的大小；对音频来说是整个音。
3. width, height：图像的宽高。
4. key_frame：是否为关键帧。
5. pict_type：帧类型（只针对视频） 。例如 I，P，B。

## 3 音视频基础知识

### 3.1 视频压缩

为什么需要压缩：

1. 未经压缩的数字视频的数据量巨大
2. 存储困难
3. 传输困难

为什么可以压缩：

1. 去除冗余信息
2. 空间冗余：图像相邻像素之间有较强的相关性。
3. 时间冗余：视频序列的相邻图像之间内容相似。
4. 编码冗余：不同像素值出现的概率不同。
5. 视觉冗余：人的视觉系统对某些细节不敏感。
6. 知识冗余：规律性的结构可由先验知识和背景知识得到。

数据压缩分类：

1. 无损压缩(Winzip)，特点是：压缩前解压缩后图像完全一致，特点是压缩比低。
2. 有损压缩(H.264)，特点是：压缩前解压缩后图像不一致，压缩比高，利用人的视觉系统的特性(人眼能见的动画频率和图像细节有限制)。

### 3.2 编码格式

视频编码格式：

| 名称        | 推出机构       | 推出时间 | 目前使用领域 |
| ----------- | -------------- | -------- | ------------ |
| HEVC(H.265) | MPEG/ITU-T     | 2013     | 研发中       |
| H.264       | MPEG/ITU-T     | 2003     | 各个领域     |
| MPEG4       | MPEG           | 2001     | 不温不火     |
| MPEG2       | MPEG           | 1994     | 数字电视     |
| VP9         | Google         | 2013     | 研发中       |
| VP8         | Google         | 2008     | 不普及       |
| VC-1        | Microsoft Inc. | 2006     | 微软平台     |

音频编码格式：

| 名称   | 推出机构       | 推出时间 | 目前使用领域   |
| ------ | -------------- | -------- | -------------- |
| AAC    | MPEG           | 1997     | 各个领域（新） |
| AC-3   | Dolby Inc.     | 1992     | 电影           |
| MP3    | MPEG           | 1993     | 各个领域（旧） |
| WMA    | Microsoft Inc. | 1999     | 微软平台       |

### 3.3 封装格式

| 名称   | 推出机构           | 流媒体 | 支持的视频编码                 | 支持的音频编码                        | 目前使用领域   |
| ------ | ------------------ | ------ | ------------------------------ | ------------------------------------- | -------------- |
| AVI    | Microsoft Inc.     | 不支持 | 几乎所有格式                   | 几乎所有格式                          | BT下载影视     |
| MP4    | MPEG               | 支持   | MPEG-2, MPEG-4, H.264, H.263等 | AAC, MPEG-1 Layers I, II, III, AC-3等 | 互联网视频网站 |
| TS     | MPEG               | 支持   | MPEG-1, MPEG-2, MPEG-4, H.264  | MPEG-1 Layers I, II, III, AAC,        | IPTV，数字电视 |
| FLV    | Adobe Inc.         | 支持   | Sorenson, VP6, H.264           | MP3, ADPCM, Linear PCM, AAC等         | 互联网视频网站 |
| MKV    | CoreCodec Inc.     | 支持   | 几乎所有格式                   | 几乎所有格式                          | 互联网视频网站 |
| RMVB   | Real Networks Inc. | 支持   | RealVideo 8, 9, 10             | AAC, Cook Codec, RealAudio Lossless   | BT下载影视     |

### 3.4 流媒体协议

| 名称                  | 推出机构       | 传输层协议 | 客户端   | 目前使用领域    |
| --------------------- | -------------- | ---------- | -------- | --------------- |
| RTSP+RTP              | IETF           | TCP+UDP    | VLC, WMP | IPTV            |
| RTMP                  | Adobe Inc.     | TCP        | Flash    | 互联网直播      |
| RTMFP                 | Adobe Inc.     | UDP        | Flash    | 互联网直播      |
| MMS                   | Microsoft Inc. | TCP/UDP    | WMP      | 互联网直播+点播 |
| HTTP-FLV              | WWW+IETF       | TCP        | Flash    | 互联网直播      |
| HLS(http live stream) | APPLE          | TCP/UDP    | Flash    | 互联网直播+点播 |

### 3.5 YUV 简介

YUV定义：分为三个分量，“Y”表示明亮度也就是灰度值，而“U”和“V” 表示的则是色度和饱和度，作用是描述影像色彩及饱和度，用于指定像素的颜色。

YUV格式有两大类：(平面格式)planar和(打包格式)packed。

1. planar：先存储Y，然后U，然后 V。
2. packed：yuv交叉存储。

还有我们常说的 YUV420sp 与 YUV420p。

1. YUV420sp：一种 two-plane 模式，即 Y 和 UV 分为两个平面，U、V交错排列。
2. YUV420p：先把 U 存放完后，再存放 V。UV 是连续的。
3. YUV420 的数据大小为： `亮度(行×列) ＋ V(行×列/4) + U(行×列/4)`即：`W\*H\*3/2`

普遍的编码器都以接受 planar 的 I420 数据(YUV420P)

4*4 的 I420 数据排列如下:

```log
> y1   y2     y3    y4
>
> y5   y6     y7    y8  
>
> y9   y10   y11  y12
>
> y13 y14   y15  y16
>
> u1   u2    u3   u4
>
> v1   v2    v3    v4
```

Android 摄像头一般默认为 NV21(YUV420SP)

```log
>y1   y2     y3    y4
>
>y5   y6     y7    y8  
>
>y9   y10   y11  y12
>
>y13 y14   y15  y16
>
>u1   v1    u2     v2
>
>u3   v3    u4    v4
```

### H.264 `I, P，B` 帧和 `PTS`, `DTS`

`I, P，B` 帧：

- I frame：帧内编码帧，I 帧通常是每个 GOP（MPEG 所使用的一种视频压缩技术）的第一个帧，经过适度地压缩，做为随机访问的参考点，可以当成图象。I帧可以看成是一个图像经过压缩后的产物。I frame 自身可以通过视频解压算法解压成一张单独的完整的图片。
- P frame: 前向预测编码帧，通过充分将低于图像序列中前面已编码帧的时间冗余信息来压缩传输数据量的编码图像，也叫预测帧。P frame 需要参考其前面的一个 I frame 或者 B frame 来生成一张完整的图片。
- B frame: 双向预测内插编码帧，既考虑与源图像序列前面已编码帧，也顾及源图像序列后面已编码帧之间的时间冗余信息来压缩传输数据量的编码图像，也叫双向预测帧。B frame 要参考其前一个 I 或者 P 帧及其后面的一个 P 帧来生成一张完整的图片。

`PTS`, `DTS`：

1. PTS：Presentation Time Stamp。PTS 主要用于度量解码后的视频帧什么时候被显示出来。
2. DTS：Decode Time Stamp。DTS主要是标识读入内存中的帧数据在什么时候开始送入解码器中进行解码。

在没有 B 帧存在的情况下DTS 的顺序和 PTS 的顺序应该是一样的。DTS 主要用于视频的解码，在解码阶段使用。PTS 主要用于视频的同步和输出，在显示的时候使用。

![dts与pts](images/dts与pts.jpg)

如上图：I frame 的解码不依赖于任何的其它的帧，而 p frame 的解码则依赖于其前面的 I frame 或者 P frame，B frame 的解码则依赖于其前的最近的一个 I frame 或者 P frame 及其后的最近的一个 P frame.
