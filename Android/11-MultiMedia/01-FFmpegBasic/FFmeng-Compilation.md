# 编译 FFmeng

---

## 1 编译相关资料

编译教程：

- [FFmpeg官方编译指引](https://trac.ffmpeg.org/wiki/CompilationGuide)
- [编译FFmpeg4.1.3并移植到Android app中使用（最详细的FFmpeg-Android编译教程）](https://blog.csdn.net/bobcat_kay/article/details/80889398?utm_medium=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1)
- [音视频学习 (六) 一键编译 32/64 位 FFmpeg 4.2.2](https://juejin.im/post/5e1eace16fb9a02fec66474e)
- [Android最简单的基于FFmpeg的例子](http://www.ihubin.com/archives/)

已经编译好的项目：

- [BlogDemo](https://github.com/burgessjp/BlogDemo)：CMake 方式编译的 FFmpeg
- [ffmpeg-android-java](https://github.com/WritingMinds/ffmpeg-android-java)：在 Android 端运行 FFmpeg 命令行。
- [FFmpeg4Android](https://github.com/mabeijianxi/FFmpeg4Android)：这是一个编译 Android 下可用的 FFmpeg 的项目，内含代码示例。包含 libx264 全平台编译脚本、libfdk-aac 全平台编译脚本。

---

## 2 编译方式

在 Android 中使用 FFmpeg 的方式：

1. 只编译出共享库和头文件，然后自己编写 c/c++ 代码调用相关的 API。
2. 编译出共享库和头文件后，将 `ffmpeg.h, ffmpeg.c` 等相关文件也集成到项目中，这样我们就可以在 Android 中执行 FFmpeg 命令。
3. 编译出可以在 Android 平台运行的 FFmpeg 可执行文件，这样我们就只能在 Android 中使用 FFmpeg 命令。

---

## 3 编译参数说明

下载好 FFmpeg 源码后，可以通过 configure 获取帮助。

- configure 详细指令说明可以从`./configure --help`命令获取。
- configure 文件中描述了各个模块之间的依赖关系等。

尝试运行以下 configure 会得到

```shell
# 使用方式：configure + 选项。
Usage: configure [options]
Options: [defaults in brackets after descriptions]

# 帮助命令
Help options:
  --help                   print this message
  --quiet                  Suppress showing informative output
  --list-decoders          show all available decoders
  --list-encoders          show all available encoders
  --list-hwaccels          show all available hardware accelerators
  --list-demuxers          show all available demuxers
  --list-muxers            show all available muxers
  --list-parsers           show all available parsers
  --list-protocols         show all available protocols
  --list-bsfs              show all available bitstream filters
  --list-indevs            show all available input devices
  --list-outdevs           show all available output devices
  --list-filters           show all available filters

# 标准选项
Standard options:
  --logfile=FILE           log tests and output to FILE [ffbuild/config.log]
  --disable-logging        do not log configure debug information
  --fatal-warnings         fail if any configure warning is generated
  #编译出的文件保存位置，必须指定。
  --prefix=PREFIX          install in PREFIX [/usr/local]
  --bindir=DIR             install binaries in DIR [PREFIX/bin]
  --datadir=DIR            install data files in DIR [PREFIX/share/ffmpeg]
  --docdir=DIR             install documentation in DIR [PREFIX/share/doc/ffmpeg]
  --libdir=DIR             install libs in DIR [PREFIX/lib]
  --shlibdir=DIR           install shared libs in DIR [LIBDIR]
  --incdir=DIR             install includes in DIR [PREFIX/include]
  --mandir=DIR             install man page in DIR [PREFIX/share/man]
  --pkgconfigdir=DIR       install pkg-config files in DIR [LIBDIR/pkgconfig]
  --enable-rpath           use rpath to allow installing libraries in paths
                           not part of the dynamic linker search path
                           use rpath when linking programs (USE WITH CARE)
  --install-name-dir=DIR   Darwin directory name for installed targets

# 许可证选项
Licensing options:
  --enable-gpl             allow use of GPL code, the resulting libs
                           and binaries will be under GPL [no]
  --enable-version3        upgrade (L)GPL to version 3 [no]
  --enable-nonfree         allow use of nonfree code, the resulting libs
                           and binaries will be unredistributable [no]
# 编译配置选项
Configuration options:
  # 禁用编译为静态库
  --disable-static         do not build static libraries [no]
  # 编译为共享库
  --enable-shared          build shared libraries [no]
  # 用于优化库的大小
  --enable-small           optimize for size instead of speed
  --disable-runtime-cpudetect disable detecting CPU capabilities at runtime (smaller binary)
  --enable-gray            enable full grayscale support (slower color)
  --disable-swscale-alpha  disable alpha channel support in swscale
  --disable-all            disable building components, libraries and programs
  --disable-autodetect     disable automatically detected external libraries [no]

# 程序选项，下面执行用于指定是否编译出可执行程序。
Program options:
  # 不编译出命令行程序
  --disable-programs       do not build command line programs
  # 不编译出 ffmepg 程序
  --disable-ffmpeg         disable ffmpeg build
  # 不编译出 ffplay 播放器
  --disable-ffplay         disable ffplay build
  --disable-ffprobe        disable ffprobe build

# 文档选项
Documentation options:
  --disable-doc            do not build documentation
  --disable-htmlpages      do not build HTML documentation pages
  --disable-manpages       do not build man documentation pages
  --disable-podpages       do not build POD documentation pages
  --disable-txtpages       do not build text documentation pages

# 组件选项，可以开启或者关闭组件
Component options:
  #操控我们的摄像头-（Android中是不支持））
  --disable-avdevice       disable libavdevice build
  #audio video codec(编码 和 解码)
  --disable-avcodec        disable libavcodec build
  #音视频格式生成和解析相关
  --disable-avformat       disable libavformat build
  #音频重采样（如果想把单声道，变成双声道）
  --disable-swresample     disable libswresample build
  #对视频显示相关（对视频的缩放，放大 缩小）
  --disable-swscale        disable libswscale build
  #后期处理，很少用，可以关闭掉
  --disable-postproc       disable libpostproc build
  #给视频加水印，加字幕，特殊效果
  --disable-avfilter       disable libavfilter build
  --enable-avresample      enable libavresample build (deprecated) [no]
  --disable-pthreads       disable pthreads [autodetect]
  --disable-w32threads     disable Win32 threads [autodetect]
  --disable-os2threads     disable OS/2 threads [autodetect]
  --disable-network        disable network support [no]
  --disable-dct            disable DCT code
  --disable-dwt            disable DWT code
  --disable-error-resilience disable error resilience code
  --disable-lsp            disable LSP code
  --disable-lzo            disable LZO decoder code
  --disable-mdct           disable MDCT code
  --disable-rdft           disable RDFT code
  --disable-fft            disable FFT code
  --disable-faan           disable floating point AAN (I)DCT code
  --disable-pixelutils     disable pixel utils in libavutil

# 独立组件选项
Individual component options:
  --disable-everything     disable all components listed below
  ...

# 第三方扩展库支持，比如 x264，opengl 等等
External library support:

  Using any of the following switches will allow FFmpeg to link to the
  corresponding external library. All the components depending on that library
  will become enabled, if all their other dependencies are met and they are not
  explicitly disabled. E.g. --enable-libwavpack will enable linking to
  libwavpack and allow the libwavpack encoder to be built, unless it is
  specifically disabled with --disable-encoder=libwavpack.

  Note that only the system libraries are auto-detected. All the other external
  libraries must be explicitly enabled.

  Also note that the following help text describes the purpose of the libraries
  themselves, not all their features will necessarily be usable by FFmpeg.

  ...
  --enable-libwebp         enable WebP encoding via libwebp [no]
  --enable-libx264         enable H.264 encoding via x264 [no]
  --enable-libx265         enable HEVC encoding via x265 [no]
  --enable-opengl          enable OpenGL rendering [no]
  --enable-openssl         enable openssl, needed for https support
                           if gnutls, libtls or mbedtls is not used [no]
  ...

  # 下面的库提供了硬件加上功能
  The following libraries provide various hardware acceleration features:
  --disable-amf            disable AMF video encoding code [autodetect]
  ...

# 工具链支持
Toolchain options:
  # 指定CPU架构
  --arch=ARCH              select architecture []
  --cpu=CPU                select the minimum required CPU (affects
                           instruction selection, may crash on older CPUs)
  # 用于设置编译工具，这里需要指定为 Android 平台的交叉编译工具。
  --cross-prefix=PREFIX    use PREFIX for compilation tools []
  --progs-suffix=SUFFIX    program name suffix []
  --enable-cross-compile   assume a cross-compiler is used
  --sysroot=PATH           root of cross-build tree
  --sysinclude=PATH        location of cross-build system headers
  --target-os=OS           compiler targets OS []
  --target-exec=CMD        command to run executables on target
  --target-path=DIR        path to view of build directory on target
  --target-samples=DIR     path to samples directory on target
  --tempprefix=PATH        force fixed dir/prefix instead of mktemp for checks
  # 指定编译器
  --toolchain=NAME         set tool defaults according to NAME
                           (gcc-asan, clang-asan, gcc-msan, clang-msan,
                           gcc-tsan, clang-tsan, gcc-usan, clang-usan,
                           valgrind-massif, valgrind-memcheck,
                           msvc, icl, gcov, llvm-cov, hardened)
  --nm=NM                  use nm tool NM [nm -g]
  --ar=AR                  use archive tool AR [ar]
  --as=AS                  use assembler AS []
  --ln_s=LN_S              use symbolic link tool LN_S [ln -s -f]
  --strip=STRIP            use strip tool STRIP [strip]
  --windres=WINDRES        use windows resource compiler WINDRES [windres]
  --x86asmexe=EXE          use nasm-compatible assembler EXE [nasm]
  --cc=CC                  use C compiler CC [gcc]
  --cxx=CXX                use C compiler CXX [g++]
  --objcc=OCC              use ObjC compiler OCC [gcc]
  --dep-cc=DEPCC           use dependency generator DEPCC [gcc]
  --nvcc=NVCC              use Nvidia CUDA compiler NVCC or clang []
  --ld=LD                  use linker LD []
  --pkg-config=PKGCONFIG   use pkg-config tool PKGCONFIG [pkg-config]
  --pkg-config-flags=FLAGS pass additional flags to pkgconf []
  --ranlib=RANLIB          use ranlib RANLIB [ranlib]
  --doxygen=DOXYGEN        use DOXYGEN to generate API doc [doxygen]
  --host-cc=HOSTCC         use host C compiler HOSTCC
  --host-cflags=HCFLAGS    use HCFLAGS when compiling for host
  --host-cppflags=HCPPFLAGS use HCPPFLAGS when compiling for host
  --host-ld=HOSTLD         use host linker HOSTLD
  --host-ldflags=HLDFLAGS  use HLDFLAGS when linking for host
  --host-extralibs=HLIBS   use libs HLIBS when linking for host
  --host-os=OS             compiler host OS []
  # 添加 c 编译选项
  --extra-cflags=ECFLAGS   add ECFLAGS to CFLAGS []
  # 添加 cpp 编译选项
  --extra-cxxflags=ECFLAGS add ECFLAGS to CXXFLAGS []
  --extra-objcflags=FLAGS  add FLAGS to OBJCFLAGS []
  # 设置连接选项
  --extra-ldflags=ELDFLAGS add ELDFLAGS to LDFLAGS []
  --extra-ldexeflags=ELDFLAGS add ELDFLAGS to LDEXEFLAGS []
  --extra-ldsoflags=ELDFLAGS add ELDFLAGS to LDSOFLAGS []
  --extra-libs=ELIBS       add ELIBS []
  --extra-version=STRING   version string suffix []
  --optflags=OPTFLAGS      override optimization-related compiler flags
  --nvccflags=NVCCFLAGS    override nvcc flags []
  --build-suffix=SUFFIX    library name suffix []
  --enable-pic             build position-independent code
  --enable-thumb           compile for Thumb instruction set
  --enable-lto             use link-time optimization
  --env="ENV=override"     override the environment variables

# 高级选项
Advanced options (experts only):
  --malloc-prefix=PREFIX   prefix malloc and related names with PREFIX
  ...

# 优化选项（供专家使用）
Optimization options (experts only):
  --disable-asm            disable all assembly optimizations

# 开发者选项
Developer options (useful when working on FFmpeg itself):
  --disable-debug          disable debugging symbols
  ...

NOTE: Object files are built at the place where configure is launched.
