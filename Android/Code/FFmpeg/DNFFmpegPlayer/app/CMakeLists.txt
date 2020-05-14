cmake_minimum_required(VERSION 3.4.1)
set(cpp_dir ${CMAKE_SOURCE_DIR}/src/main/cpp)

file(GLOB source_files src/main/cpp/*.cpp)
add_library(native-lib SHARED source_files)

# FFmpeg
include_directories(src/main/cpp/include)
set(FFmpegLibDir libs)

add_library(avcodec STATIC IMPORTED)
set_target_properties(avcodec PROPERTIES IMPORTED_LOCATION ${cpp_dir}/${FFmpegLibDir}/${ANDROID_ABI}/libavcodec.a)

add_library(avfilter STATIC IMPORTED)
set_target_properties(avfilter PROPERTIES IMPORTED_LOCATION ${cpp_dir}/${FFmpegLibDir}/${ANDROID_ABI}/libavfilter.a)

add_library(avformat STATIC IMPORTED)
set_target_properties(avformat PROPERTIES IMPORTED_LOCATION ${cpp_dir}/${FFmpegLibDir}/${ANDROID_ABI}/libavformat.a)

add_library(avutil STATIC IMPORTED)
set_target_properties(avutil PROPERTIES IMPORTED_LOCATION ${cpp_dir}/${FFmpegLibDir}/${ANDROID_ABI}/libavutil.a)

add_library(swresample STATIC IMPORTED)
set_target_properties(swresample PROPERTIES IMPORTED_LOCATION ${cpp_dir}/${FFmpegLibDir}/${ANDROID_ABI}/libswresample.a)

add_library(swscale STATIC IMPORTED)
set_target_properties(swscale PROPERTIES IMPORTED_LOCATION ${cpp_dir}/${FFmpegLibDir}/${ANDROID_ABI}/libswscale.a)

find_library(log-lib log)

target_link_libraries(native-lib avcodec avfilter avformat avutil swresample swscale log)