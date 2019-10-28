# 5 FFmpeg多媒体文件处理

## 5-1 ffmpeg初级开发介绍

- FFmpeg 日志的使用及目录操作
- FFmpeg 的基本概念及常用结构体
- 对复用/解复用及流操作的各种实战

FFmpeg 代码结构：

![](images/05-ffmepg-code-struct.png)

## 5-2 ffmpeg开发入门Log系统

## 5-3 ffmpeg文件的删除与重命名

## 5-4 ffmpeg操作目录及list的实现

## 5-6 ffmpeg处理流数据的基本概念

相关概念：

- 多媒体文件其实是个容器
- 在容器的有很多流（Stream/Track）
- 每种流是由不同的编码器编码的
- 从流中读取的数据称之为包
- 在一个包中包含者一个或多个帧

重要的结构体：

- AVFormatContext 格式上下文，多个 API 的桥梁
- AVStream 对应流/轨
- AVPacket 对应包

对流操作的基本步骤：

![](images/05-ffmepg-process-stream.png)

## 5-7 ffmpeg打印音视频Meta信息

- `avregister_all()` 将FFmpeg所以定义的编解码库等注册到程序中，一个必须的API。
- `avformat_open_input()/avformat_close_input()` 读取与释放
- `av_dump_format()` 打印音视频文件元信息

## 5-8 ffmpeg抽取音频数据

- `av_init_packet()` 初始化数据包结构体
- `av_find_best_stream()` 从数据包中找到最好的流
- `av_read_frame/av_packet_unref()` 读取与释放（为什么这里是 readframe 而不是 readstream 呢？历史遗留问题 ）

## 5-11 ffmpeg抽取视频H264数据

- Start code：用以区分一帧一帧的视频数据，Start code 是一个特征码，每一帧前面都要有特征码，特征码为 `00 00 01` 或者 `00 00 00 01`（关键帧）。
- SPS/PPS：存储视频的宽高，帧率等数据。SPS/PPS 数据非常小，每个关键帧前面都添加一个 SPS/PPS 可以防止因为丢包而无法解析的问题。每个 SPS/PPS 前面也要有一个 Start code。
- 获取SPS/PPS：`codec -> extradata`

## 5-14 ffmpeg将mp4转成flv

- `avformat_alloc_output_context2()`/`avformat_free_context()` 用于输出
- `avformat_new_stream()` 创建新的 stream
- `avcodec_parameters_copy()` 拷贝视频信息
- `avformat_write_header()`写多媒体文件头，用以标识FFmpeg支持的多媒体文件
- `avformat_write_frame()`/`av_interleaved_write_frame()` 写数据
- `av_write_trailer()` 写尾部信息

## 5-16 ffmpeg音视频裁剪

## 5-17 作业：ffmpeg实现小咖秀
