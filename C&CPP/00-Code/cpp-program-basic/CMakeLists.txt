cmake_minimum_required(VERSION 3.7)
project(cplusplus-program)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES geektime/02-smart-ptr.cpp)
add_executable(CPP_Basic ${SOURCE_FILES})
