# Windows 平台 FFmepg 编译

依赖库下载：<https://ffmpeg.zeranoe.com/builds/>

- 下载 Dev 压缩包。需要用到里面的`头文件`和`lib`，
- 下载 Shared，需要用到里面的 dll，解压 shared 后，将 bin 目录添加到环境变量中。

注意：

1. 配置管理设置为x64：`右键项目->配置管理器-->新建-->选择x64`
2. 添加头文件：`右键项目->C/C++常规->附加包含目录，添加dev中提供的头文件`
3. 添加lib：`右键项目->链接器->附加库目录，添加dev中提供的lib`
4. 添加需要链接的dll，`右键项目->链接器->附加依赖项`添加如下内容：

```log
avcodec.lib
avformat.lib
avutil.lib
avdevice.lib
avfilter.lib
postproc.lib
swresample.lib
swscale.lib
```

遇到编译报错，参考：<https://stackoverflow.com/questions/21278141/unexpected-end-of-file-error-in-ffmpeg-libavutils-common-h-while-compiling>
