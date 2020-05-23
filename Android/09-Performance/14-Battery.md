# 耗电优化

## 耗电分析

- 耗电分析：[battery-historian](https://github.com/google/battery-historian) 是 google 开源的电池历史数据分析工具。
- [Android 功耗分析之wakelock](https://www.jianshu.com/p/67ccdac38271)

## 优化方案

- JobScheduler
  - 把工作任务放到合适的时间再去执行，比如充电时间，wifi连接后。
  - 也可以把多个任务合并到一起，再选择时间去执行。
- Doze 和 App Standby 模式。
