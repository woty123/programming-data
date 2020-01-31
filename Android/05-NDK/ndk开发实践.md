# ndk开发实践

## 1 静态库还是动态库

- 使用链接静态库：假设静态库中有 `a b c`，而我们只是用到其中的 `a`，那么在链接的时候，只会将静态库中的 `a` 连接到我们生成的库中。
- 链接动态库：如果使用动态库，那么整个动态库都要打包进 apk 中。

所以不一定使用静态库生成的包就比使用动态库的大，开源框架使用动态库的一大好处是方便使用和分发，因为 jni 无法直接使用静态库。

## 2 动态库依赖问题

- 从 6.0 开始 使用 `Android.mk` 如果来引入一个预编译动态库，链接路径有问题，无法修复。
- 在 4.4 的系统上如果 load 一个动态库 ，需要先将这个动态库的依赖的其他动态库 load 进来，而后续版本会自动查找依赖。即：
  - 在 6.0 以下  System.loadLibrary 不会自动为我们加载依赖的动态库。
  - 在 6.0以上  System.loadLibrary 会自动为我们加载依赖的动态库。

假设存在两个动态库 `libhello-jni.so` 与 `libTest.so`。`libhello-jni.so` 依赖于 `libTest.so` (使用NDK下的`ndk-depends`可查看依赖关系)，则：

```java
//在 <=5.0 的系统上，需要手动加载依赖
System.loadLibrary("Test");
System.loadLibrary("hello-jni");
//在 >=6.0 的系统上不需要
System.loadLibrary("hello-jni");
```

### 使用 `Android.mk` 的情况

使用Android.mk在 >=6.0 设备上不能再使用预编译动态库，而静态库没问题：

```makefile
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := Test
#libTest.so放在当前文件同目录
LOCAL_SRC_FILES := libTest.so
#预编译库
include $(PREBUILT_SHARED_LIBRARY)


include $(CLEAR_VARS)
#引入上面的Test模块
LOCAL_SHARED_LIBRARIES := Test
LOCAL_MODULE := hello-jni
LOCAL_SRC_FILES := hello-jni.c
include $(BUILD_SHARED_LIBRARY)
```

上面这段配置生成的`libhllo-jni`在 >=6.0 设备中无法执行，原因是生成的因为 >=6.0 的系统会自动加载 so 所依赖的其他 so，所以生成的目标 so 中会保存所以来 so 的路径，但是使用这种方式生成的目标 so 所配置的依赖 `libTest.so` 的路径是错误的，无法修复。

### 使用 CMake 的情况

使用 CMakeList.txt 在 >=6.0 设备上引入预编译动态库:

```shell
cmake_minimum_required(VERSION 3.4.1)

file(GLOB SOURCE *.c )
add_library(hello-jni SHARED ${SOURCE} )

#这段配置在6.0依然没问题
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -L[SO所在目录]")

#这段配置只能在6.0以下使用 原因和android.mk一样
#add_library(Test SHARED IMPORTED)
#set_target_properties(Test PROPERTIES IMPORTED_LOCATION [SO绝对地址])

target_link_libraries(hello-jni Test)
```

## 3 CMake基本配置与注意事项

在 android studio 2.2 及以上，构建原生库的默认工具是 CMake。CMake是一个跨平台的构建工具，可以用简单的语句来描述所有平台的安装(编译过程)。能够输出各种各样的 makefile 或者 project 文件。Cmake 并不直接建构出最终的软件，而是产生其他工具的脚本（如Makefile ），然后再依这个工具的构建方式使用。

​CMake 是一个比 make 更高级的编译配置工具，它可以根据不同平台、不同的编译器，生成相应的 Makefile 或者 vcproj 项目。从而达到跨平台的目的。Android Studio 利用 CMake 生成的是 ninja，ninja 是一个小型的关注速度的构建系统。我们不需要关心 ninja 的脚本，知道怎么配置 cmake 就可以了。从而可以看出 cmake 其实是一个跨平台的支持产出各种不同的构建脚本的一个工具。

### 基础配置

CMake 的脚本名默认是 CMakeLists.txt

```cmake
#cmake最低版本
cmake_minimum_required(VERSION 3.6.0)

#指定项目
project(Main)

#生成可执行文件 main
add_executable(main main.c)
```

执行cmake . 生成makefile，再执行make即可生成main程序。

### 多源文件

如果源文件很多，那么一个个写进去是一件很麻烦的事情，这时候可以：

```cmake
cmake_minimum_required(VERSION 3.6.0)
project(Main)

#查找当前目录所有源文件 并将名称保存到 DIR_SRCS 变量，不能查找子目录
aux_source_directory(. DIR_SRCS)
message(${DIR_SRCS})

#也可以
file(GLOB DIR_SRCS *.c)

add_executable(main ${DIR_SRCS})
```

### 子项目

如果在 cmake 中需要使用其他目录的 cmakelist

```cmake
cmake_minimum_required (VERSION 3.6.0)
project (Main)
aux_source_directory(. DIR_SRCS)
# 添加 child 子目录下的cmakelist
add_subdirectory(child)
# 指定生成目标
add_executable(main ${DIR_SRCS})
# 添加链接库
target_link_libraries(main child)

#===========================================================================================
#子目录下的 cmake：

cmake_minimum_required (VERSION 3.6.0)
aux_source_directory(. DIR_LIB_SRCS)

# 生成链接库 默认生成静态库
add_library (child ${DIR_LIB_SRCS})
# 或指定编译为静态库
add_library (child STATIC ${DIR_LIB_SRCS})
# 或指定编译为动态库
add_library (child SHARED ${DIR_LIB_SRCS})
```

### 生产库文件

在上面的例子中都是生成可执行文件，而在到 android studio 中是使用 cmakelist 生成库文件，只需将 `add_executable` 改为 `add_library` 接口。

```cmake
#NDK中已经有一部分预构建库 ndk 库已经是被配置为 cmake 搜索路径的一部分 所以可以
findLibrary(log-lib log)
target_link_libraries(native-lib ${log-lib} )

#设置 cflag（c语言） 和 cxxflag（c++语言）
#定义预编译宏：TEST
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DTEST")
set(CMAKE_Cxx_FLAGS "${CMAKE_Cxx_FLAGS} -DTEST")

#其实直接这样就行
target_link_libraries(native-lib log)
```

添加其他第三方预编译库(已经提前编译好的库)

```cmake
#使用 IMPORTED 标志告知 CMake 只希望将库导入到项目中

#如果是静态库则将shared改为static
add_library(imported-lib SHARED MPORTED )
# 参数分别为：库、属性、导入地址、so所在地址
set_target_properties(imported-lib PROPERTIES IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/src/${ANDROID_ABI}/libimported-lib.so)

#为了确保 CMake 可以在编译时定位头文件
#这样就可以使用 #include <xx> 引入
#否则需要使用 #include "path/xx"
include_directories( imported-lib/include/ )

#native-lib 是自己编写的源码最终要编译出的so库
target_link_libraries(native-lib imported-lib)

#===========================================================================================
#添加其他预编译库还可以使用这种方式：使用 -L 指导编译时库文件的查找路径
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Lxx")
#为了确保 CMake 可以在编译时定位您的标头文件
include_directories(imported-lib/include/)

#native-lib 是自己编写的源码最终要编译出的so库
target_link_libraries(native-lib imported-lib)
```

常用指令：

```cmake
#set命令表示声明一个变量source 变量的值是后面的可变参数
set（source a b c）

#打印日志
message(${source})

#逻辑判断：计较字符串
set(ANDROID_ABI "areambi-v7a")

if(${ANDROID_ABI} STREQUAL "areambi") message("armv5")
elseif(${ANDROID_ABI} STREQUAL "areambi-v7a") message("armv7a")
else()
endif()
```

其次还可以在 build.gradle 中配置一些编译属性：

```groovy
//还可以在gradle中使用 arguments  设置一些配置
externalNativeBuild {
      cmake {
        arguments "-DANDROID_TOOLCHAIN=clang",//使用的编译器clang/gcc
                  "-DANDROID_STL=gnustl_static"//cmake默认就是 gnustl_static
        cFlags "" //这里也可以指定cflag和cxxflag,效果和之前的cmakelist里使用一样
        cppFlags ""
      }
    }
```
