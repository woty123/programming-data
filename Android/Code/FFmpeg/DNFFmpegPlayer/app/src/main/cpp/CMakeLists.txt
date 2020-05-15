cmake_minimum_required(VERSION 3.4.1)

# 创建一个变量 source_file 它的值就是src/main/cpp/ 所有的.cpp文件
file(GLOB source_file ./*.cpp)
add_library(native-lib SHARED ${source_file})

#FFmpeg
include_directories(./include)
set(FFmpegLibDir libs)

add_library(avcodec STATIC IMPORTED)
set_target_properties(avcodec PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/${FFmpegLibDir}/${ANDROID_ABI}/libavcodec.a)

add_library(avfilter STATIC IMPORTED)
set_target_properties(avfilter PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/${FFmpegLibDir}/${ANDROID_ABI}/libavfilter.a)

add_library(avformat STATIC IMPORTED)
set_target_properties(avformat PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/${FFmpegLibDir}/${ANDROID_ABI}/libavformat.a)

add_library(avutil STATIC IMPORTED)
set_target_properties(avutil PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/${FFmpegLibDir}/${ANDROID_ABI}/libavutil.a)

add_library(swresample STATIC IMPORTED)
set_target_properties(swresample PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/${FFmpegLibDir}/${ANDROID_ABI}/libswresample.a)

add_library(swscale STATIC IMPORTED)
set_target_properties(swscale PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/${FFmpegLibDir}/${ANDROID_ABI}/libswscale.a)

#链接库时，需要注意依赖顺序：avfilter avformat avcodec  avutil  swresample swscale
#ffmepg 使用了libz，务必要加上
target_link_libraries(native-lib avformat avcodec avfilter avutil swresample swscale log z)