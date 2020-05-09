# FFmeng 资料

- [ffmpeg 官网](https://ffmpeg.org/)
- [ffmpeg 官方 wiki](https://trac.ffmpeg.org/wiki)

## 1 编译 FFmeng

### 1.1 编译方式

配置：

- configure详细指令说明可以从`./configure --help`命令获取。
- configure文件中描述了各个模块之间的依赖关系等。

编译前需要修改以下 `configure` 文件。具体的编译脚本，参考下面链接。

```shell
# configure文件中的下面内容：
SLIBNAME_WITH_MAJOR='$(SLIBNAME).$(LIBMAJOR)'
LIB_INSTALL_EXTRA_CMD='$$(RANLIB)"$(LIBDIR)/$(LIBNAME)"'
SLIB_INSTALL_NAME='$(SLIBNAME_WITH_VERSION)'
SLIB_INSTALL_LINKS='$(SLIBNAME_WITH_MAJOR)$(SLIBNAME)'

# 替换为：
SLIBNAME_WITH_MAJOR='$(SLIBPREF)$(FULLNAME)-$(LIBMAJOR)$(SLIBSUF)'
LIB_INSTALL_EXTRA_CMD='$$(RANLIB)"$(LIBDIR)/$(LIBNAME)"'
SLIB_INSTALL_NAME='$(SLIBNAME_WITH_MAJOR)'
SLIB_INSTALL_LINKS='$(SLIBNAME)'
```

在 Android 中使用 FFmpeg 的方式：

1. 只编译出共享库和头文件，然后自己编写 c/c++ 代码调用相关的 API。
2. 编译出共享库和头文件后，将 `ffmpeg.h, ffmpeg.c` 等相关文件也集成到项目中，这样我们就可以在 Android 中执行 FFmpeg 命令。
3. 编译出可以在 Android 平台运行的 FFmpeg 可执行文件，这样我们就只能在 Android 中使用 FFmpeg 命令。

### 1.2 编译相关教程

编译教程：

- [FFmpeg官方编译指引](https://trac.ffmpeg.org/wiki/CompilationGuide)
- [编译FFmpeg4.1.3并移植到Android app中使用（最详细的FFmpeg-Android编译教程）](https://blog.csdn.net/bobcat_kay/article/details/80889398?utm_medium=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1)
- [Android最简单的基于FFmpeg的例子](http://www.ihubin.com/archives/)

已经编译好的项目：

- [BlogDemo](https://github.com/burgessjp/BlogDemo)：CMake 方式编译的 FFmpeg
- [ffmpeg-android-java](https://github.com/WritingMinds/ffmpeg-android-java)：在 Android 端运行 FFmpeg 命令行。
- [FFmpeg4Android](https://github.com/mabeijianxi/FFmpeg4Android)：这是一个编译 Android 下可用的 FFmpeg 的项目，内含代码示例。包含 libx264 全平台编译脚本、libfdk-aac 全平台编译脚本。

## 2 相关资料

### 库

- [VideoCompression](https://github.com/RudreshJR/VideoCompression)，Android Library for VideoCompressionLibrary for VideoCompression
- [RxFFmpeg](https://github.com/microshow/RxFFmpeg)

### 项目

- [WeiXinRecordedDemo](https://github.com/Zhaoss/WeiXinRecordedDemo)

### 学习

- [Android 音视频开发学习思路](https://www.cnblogs.com/renhui/p/7452572.html)
- [FFMPEG视音频编解码零基础学习方法](http://blog.csdn.net/leixiaohua1020/article/details/15811977)
- [Android 音视频开发打怪升级-系列文章](https://github.com/ChenLittlePing/LearningVideo)
- [WliveTV](https://github.com/wanliyang1990/WliveTV) 付费视频教程
- [FFmpeg音视频开发实战5 iOS/Android/windows/Linux](https://edu.csdn.net/course/detail/2314) 付费视频教程
