# 获取命令帮助

---
## 1 获取命令帮助

### 1.1 help

比如

- `ls --help` 用于外部命令
- `help cd` 用于内部命令

使用 `type commad` 获取命令的类型。

### 1.2 man

使用man命令获取帮助，man指的是manual，示例：

```shell
# 相当于 man 1 ls
man ls
# 差开 printf 的第二个篇章
man 2 printf
```

man中各个section意义如下：

1. Standard commands（标准命令）
2. System calls（系统调⽤，如open,write）
3. Library functions（库函数，如printf,fopen）
4. Special devices（设备⽂件的说明，/dev下各种设备）
5. File formats（⽂件格式，如passwd）
6. Games and toys（游戏和娱乐）
7. Miscellaneous（杂项、惯例与协定等，例如Linux档案系统、⽹络协定、ASCII 码；environ全局变量）
8. Administrative Commands（管理员命令，如ifconfig）

为什么会设置这么多section呢？因为产生可能重名，bir passwd 既可能是命令也可能是 et/passwd 下的文件，所以 man 使用不同的章节区分同名参数。

`man`是按照⼿册的章节号的顺序进⾏搜索的。man设置了如下的功能键：

功能键 | 功能
---|---
空格键|显示⼿册⻚的下⼀屏
Enter键|⼀次滚动⼿册⻚的⼀⾏
b |回滚⼀屏
f |前滚⼀屏
q |退出man命令
h |列出所有功能键
/word |向下搜索word字符串
？word |向上查询字符串

另外使用

- `man -f command`可以查询该命令有哪些说明文件。
- `man -a command`可以根据关键字查看与之相关的信息。

### 1.3 info

使用info也可以获取命令帮助：`info info`

### 1.4 自动补全

使用tab键

### 1.5 历史命令

当系统执⾏过⼀些命令后，可按上下键翻看以前的命令，`history`将执⾏过的命令列举出来

---
## 2 X Window与命令行模式切换

快捷键：`Ctrl + Alt + F1-F7`，如果以纯文本环境启动linux的话，使用`start x`命令启动X窗口界面，修改`/ect/inittab`这个文件的内容，可以配置启动时使用的环境。

### 重要的热键

- `Ctrl + C`用于终止命令
- `Ctrl + D`表示键盘输入的结束

---
## 3 正确的关机方法

```shell
shutdown [-t 秒]
reboot
poweroff
run level0 关机
run level3 纯命令模式
run level5 图形界面模式
run level6 重启
init 0 关机
```
