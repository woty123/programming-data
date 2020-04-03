# ubuntu(18.x) 安装与配置

## 1 安装 ubuntu

### 双系统

预备设置：windiws关闭快速启动，bios关闭安全启动。

1. U盘启动
2. uefi警告时选择`后退`
3. 分区为：
   - `/Boot`(引导分区) ，1000M ，主分区
   - `/`(根分区) ，30760M ，这里不要设置的太小，毕竟可能安装许多软件
   - 交换分区，8000M。
   - `/home`(用户目录), 剩余所有容量
4. 安装完毕
5. 进入windows10，使用easyBCD添加引导项：`grub2-自动选择`

### 单系统

120G ssd + 1T硬盘：

1. 挂载点：109798（SSD）
1. boot：2046（SSD）
1. swap分区：7986（SSD）
1. home：1000203（SSD）

>UEFI 模式需要单独分一个 200M 左右的区给 EFI，格式为 FAT32，然后把 grub 安装在这个分区。不然会出现错误提示『无法将grub-eif-amd64-signed软件包安装到/target/中』。具体参考[UEFI 模式安装 Win10 + Ubuntu 18.04](https://maajiaa.wordpress.com/2018/05/16/installing-win10-ubuntu-in-uefi/)

## 2 ubuntu 相关配置

### 配置源

参考 [Ubuntu 18.04换国内源 中科大源 阿里源 163源 清华源](https://blog.csdn.net/xiangxianghehe/article/details/80112149)

### 安装主题与美化

1：安装优化工具

```shell
#安装美化管理器(中文名：优化)
sudo apt install gnome-tweak-tool
```

2：Gnome-shell Extensions

1. 用 firefox 打开 <https://extensions.gnome.org>，按照提示安装插件
2. sudo apt install chrome-gnome-shell
3. 安装以下扩展
   1. User Themes
   2. Dash to Dock
   3. Gnome Global Application Menu
   4. TopIcons Plus

3：安装相关主题和图标

- 网址：<https://www.gnome-look.org/>
- 下载相关主题后按照要求提取并放置于指定目录中，一般是`~/.themes` 中
- 推荐的 themes
  - <https://www.opendesktop.org/s/Gnome/p/1013714/>
  - <https://www.opendesktop.org/s/Gnome/p/1013741/>
  - <https://www.opendesktop.org/s/Gnome/p/1102582/>

具体参考：

- [Ubuntu18.04（Gnome桌面）主题美化，Mac私人定制](https://blog.csdn.net/zyqblog/article/details/80152016)
- [Ubuntu18.04 美化](https://www.jianshu.com/p/49ed3971170a)

### install aptitude

aptitude 工具是基于 apt 的一款安装工具，优点是可以自动解决安装和卸载时候的依赖关系。

```shell
sudo apt install aptitude
```

### install Shadowsocks

具体参考[Shadowsocks-Wiki](https://github.com/Shadowsocks-Wiki/shadowsocks)

### install vscode

参考[Installing Visual Studio Code on Ubuntu](https://linuxize.com/post/how-to-install-visual-studio-code-on-ubuntu-18-04/)

更新 VSCode

```shell
sudo apt upgrade code
```

### install jdk

```shell
//open jdk
sudo apt-get update
sudo apt-get install openjdk-8-jdk
```

配置 `JAVA_HOME` 参考 [how-to-set-java-home-for-java](https://askubuntu.com/questions/175514/how-to-set-java-home-for-java)

### oh-my-zsh

```shell
sudo apt-get install zsh
```

具体参考[oh-my-zsh,让你的终端从未这么爽过](https://www.jianshu.com/p/d194d29e488c)

### dos2unix

```shell
sudo apt-get install dos2unix
```

## 引用

- [ss 的安装与配置](https://github.com/Shadowsocks-Wiki/shadowsocks/blob/master/6-linux-setup-guide-cn.md)
- [how-to-install-visual-studio-code-on-ubuntu-18-04/](https://linuxize.com/post/how-to-install-visual-studio-code-on-ubuntu-18-04/)

## 3 ubuntu 下搭建 Android 开发环境

### gradle

```bash
sudo add-apt-repository ppa:cwchien/gradle
sudo apt-get update
sudo apt-get install gradle

export GRADLE_HOME=/opt/gradle-4.2.1
export PATH=$GRADLE_HOME/bin:$PATH
```

### SDK

配置SDK环境变量

```bash
# 下载
wget http://dl.google.com/android/android-sdk_r24.2-linux.tgz
tar -xvf android-sdk_r24.2-linux.tgz
cd android-sdk-linux/tools
# 执行 .android 打开图形化界面更新AndroidSDK

# 配置环境变量
export ANDROID_HOME=$HOME/android-sdk-linux
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
```

### AndroidStudio

1. 官网下载linux版本的AndroidStudio
2. 解压到文件夹下(放在HOME目录下即可)
3. 导航至`android-studio/bin/` 目录，并执行 `. studio.sh`。启动AndroidStudio，之后AndroidStudio设置向导将指导您完成余下的设置，包括下载开发所需的AndroidSDK组件

如果运行 AndroidStudio 构建项目时遇到问题

```bash
# 在Android Studio文件夹下执行下面命令
sudo chmod 777 * -R
```

如果运行的是64位版本Ubuntu，则需要使用以下命令安装一些32位库

```bash
# 执行下面命令
sudo apt-get install lib32z1 lib32ncurses5 lib32bz2-1.0 lib32stdc++6`
apt-get install libbz2-1.0
apt-get install lib32z1 lib32ncurses5 lib32stdc++6
# 或者上门运行错误的话执行下面命令
sudo apt-get install -y libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1
# 或者上门运行错误的话执行下面命令
# adb
sudo apt-get install libc6:i386 libstdc++6:i386
# aapt
sudo apt-get install zlib1g:i386
```

### 安装字体

```bash
apt-get install msttcorefonts

字体将会被安装到 /usr/share/fonts/truetype/msttcorefonts

　　分别是：
　　Andale Mono, Arial, Comic Sans MS, Courier New, Georgia
　　Impact, Times New Roman, Trebuchet MS, Verdana, Webdings
```

### 设置环境变量

按变量的生存周期来划分，Linux变量可分为两类：

1. 永久的：需要修改配置文件，变量永久生效。
2. 临时的：使用export命令声明即可，变量在关闭shell时失效。

配置方式：

- 1 在`/etc/profile`文件中添加变量【对所有用户生效(永久的)】

```bash
vim /etc/profile
添加环境变量：
    export PATH=$PATH:你的路径
退出后：
source /etc/profile
```

- 2 在用户目录下编辑`.bashrc`文件【对单一用户生效(永久的)】

```bash
vim ~/.bashrc #编辑配置文件
# 添加环境变量：
       export YOURPATH=xxx/xxx
       export PATH=$PATH:$YOURPATH
# 退出后
source ~/.bashrc #更新环境变量
```

- 3 直接运行export命令定义变量【只对当前shell(BASH)有效(临时的)】

```bash
# 该变量只在当前的shell(BASH)或其子shell(BASH)下是有效的，shell关闭了，变量也就失效了，再打开新shell时就没有这个变量，需要使用的话还需要重新定义
export PATH=$PATH:你的路径
```

### 参考

- [ubuntu-for-Android](https://github.com/gaoneng102/ubuntu-for-Android)
