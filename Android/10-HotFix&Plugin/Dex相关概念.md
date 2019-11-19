# Dex 相关概念

- class：java 编译后的文件，每个类对应一个 class 文件
- dex： Dalvik Executable 把 class 打包在一起，一个 dex 可以包含多个 class 文件
- odex：Optimized DEX 针对系统的优化，例如某个方法的调用指令，会把虚拟的调用转换为使用具体的 index，这样在执行的时候就不用再查找了。
- oat：Optimized Android file Type，使用 AOT 策略对 dex 预先编译（解释）成本地指令，这样在运行阶段就不需再经历一次解释过程，程序的运行可以更快
- AOT： Ahead-Of-Time compilation 预先编译
