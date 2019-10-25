# 1 FFmpeg常用命令实战

## 2.1 FFmpeg常用命令分类讲解

分类：

![](images/02-ffmpeg-commands.png)

下面所有命令，具体参考：[FFMPEG常用命令](https://www.imooc.com/article/254520)

## 2.2 FFmpeg音视频处理流程讲解

![](images/02-ffmpeg-process.png)

1. 输入文件，比如 MP4，就像一个盒子里面有音频、视频、字幕、打开这个盒子的过程就叫 demuxer。
2. 打开盒子后得到的是编码数据包。
3. 对编码数据包进行解码，得到的是高度还原采集数据。
4. 对采集数据处理后，再进行编码。
5. 最后要给别人用，需要再次进行封装（封装成一种流行的格式）。

格式转换的过程相对简单，比如 MP4 转 FLV：

1. 对 MAP4 进行 demuxer 得到编码数据包。
2. 对编码数据包进行 muxer（安装FLV规格）得到 FLV 格式视频。

视频压缩（比如 1080P 转 320P）则要走完整个流程。

## 2.3 FFmpeg基本信息查询命令实战

![](images/02-ffmpeg-commands-1.png)

`ffmpeg -codecs` 命令列出的前缀说明

```log
Codecs:
 D..... = Decoding supported 解码器
 .E.... = Encoding supported 编码器
 ..V... = Video codec 视频
 ..A... = Audio codec 音频
 ..S... = Subtitle codec 字幕
 ...I.. = Intra frame-only codec 帧内压缩
 ....L. = Lossy compression 有损压缩
 .....S = Lossless compression 无损压缩
```

## 2.4 FFmpeg录制命令实战

步骤：

1. `ffmpeg -devices` 查看支持的设备
2. `ffmpeg -list_devices true -f dshow -i dummy` 查看 dshow 支持的输出输出
3. 使用具体的输入输出录制音视频

参考：

- [ffmpeg命令大全.docx](02-ffmpeg命令大全.docx)
- [FFMPEG常用命令](https://www.imooc.com/article/254520)
- [官方文档：Capture/Desktop](https://trac.ffmpeg.org/wiki/Capture/Desktop)

## 2.5 ffmpeg分解与复用命令实战

分解与复用即文件格式转换。

![](images/02-ffmpeg-分解复用流程.png)

实战操作：

- 格式转换：`ffmpeg -i out.mp4 -vcodec copy -acodec copy out.flv`
- 抽取音频：`ffmpeg -i input.mp4 -acodec copy -vn out.aac`
- 抽取视频：`ffmpeg -i input.mp4 -vcodec copy -an out.h264`
- 音频和视频合并：`ffmpeg -i out.h264 -i out.aac -vcodec copy -acodec copy out.mp4`

参考：

- [ffmpeg命令大全.docx](02-ffmpeg命令大全.docx)
- [FFMPEG常用命令](https://www.imooc.com/article/254520)

## 2.6 ffmpeg 处理原始数据命令实战

什么是原始数据？FFmpeg解码后的数据，音频就是 PCM 数据，视频就是 YUV 数据。

实战操作：

- 抽取 YUV 视频：`ffmpeg -i input.mp4 -an -c:v rawvideo -pixel_format yuv420p out.yuv`
- 抽取 PCM 音频：`ffmpeg -i out.mp4 -vn -ar 44100 -ac 2 -f s16le out.pcm`

注意：

- 在使用 ffplay 播放 YUV 数据时，要指定视频的 size，否则无法播放，因为 YUV 中并不存放视频的 size。`ffplay -s 1920x1080 1.yuv`
- 在使用 ffplay 播放 PCM 数据时，要指定采样率、存储格式、升到，否则无法播放。`ffplay -ar 44100 -ac 2 -f s16le out.pcm`

参考：

- [ffmpeg命令大全.docx](02-ffmpeg命令大全.docx)
- [FFMPEG常用命令](https://www.imooc.com/article/254520)

## 2.7 ffmpeg滤镜命令实战

## 2.8 ffmpeg音视频的裁剪与合并命令实战

## 2.9 ffmpeg图片与视频互转实战

## 2.10 ffmpeg直播相关的命令实战