# Linux 的软件安装与管理

## 1 基础软件包管理器：dpkg 与 rpm

在 Linux 上面，没有双击安装这一说，因此想要安装，我们还得需要命令。基础包管理器主要有 `rmp` 和 `dpkg`，为什么有两种呢？因为 Linux 现在常用的有两大体系，一个是 CentOS 体系，一个是 Debian 体系，前者使用 rpm 包，后者使用 deb 包。

- CentOS 下面使用`rpm -i jdk-XXX_linux-x64_bin.rpm`进行安装，软件包格式为 `rpm`。
- Debian 下面使用`dpkg -i jdk-XXX_linux-x64_bin.deb`。其中 -i 就是 install 的意思，软件包格式为 `deb`。

列出已安装软件：

- 凭借 `rpm -qa` 和 `dpkg -l` 就可以查看安装的软件列表，-q 就是 query，a 就是 all，-l 的意思就是 list。
- 常用命令示例：
  - `rpm -qa | more`
  - `rpm -qa | less`
  - `dpkg -l | grep jdk`

软件的卸载：

- 如果要删除，可以用`rpm -e`和`dpkg -r`。-e 就是 erase，-r 就是 remove。

## 2 软件包管理器：apt 与 yum

dpkg 和 rpm 都是底层工具，它们都有对应的上层工具，dpkg 对应 apt，rpm 对应 yum，它们是方便软件安装、卸载、解决软件依赖关系的重要工具。

CentOS 下面使用 yum：

- rpm 由 RedHat 公司开发，Fedora、CentOS、SuSe 等 Linux 发行版使用其管理软件安装。
- 由于 Linux 中的程序大多是小程序。程序与程序之间存在非常复杂的依赖关系。所以 rpm 无法解决软件包的依赖关系。
- yum 是基于 rpm 的在线升级机制。yum 客户端基于 rpm 包进行管理，可以通过 HTTP 服务器下载、FTP 服务器下载、本地软件池的等方式获得软件包，可以从指定的服务器自动下载 rpm 包并且安装，可以自动处理依赖性关系。

Debian 下面使用 apt：

- dpkg 机制最早由 Debian Linux 社区开发出来，派生于 Debian 的 Linux 发行版本大多使用 dpkg 这个机制来管理软件，比如 ubantu、B2D 等。
- 与 rpm 一样，dpkg 也是底层的包管理工具，无法解决软件包的依赖关系。
- apt 最早被设计成 dpkg 的前端，用来处理 deb 格式的软件包。现在经过 APT-RPM 组织修改，APT 已经可以安装在支持 rpm 的系统管理 rpm 包。

安装 JDK：

- `yum install java-11-openjdk.x86_64`
- `apt-get install openjdk-9-jdk`

卸载 JDK：

- `yum erase java-11-openjdk.x86_64`
- `apt-get purge openjdk-9-jdk`

## 3 rpm 包格式、rpm, yum 的使用

`vim-common-7.4.10-5.el7.x86_64.rpm`

- vim-common：名称
- 7.4.10-5：软件版本
- el7：系统版本
- x86_64：平台

操作

```shell
# 查询所有
rpm -qa

# 查询单个
rpm -q package_name

# 安装
rpm -i xxx.rpm

# 卸载
rpm -e package_name1 package_name12 package_name3
```

使用 rpm 只能安装本地包，且如果一个包依赖另一个包，则需要先手动安装依赖的包，这样就非常麻烦，我们使用使用 yum 包管理器，直接从网络安装软件包，且能自动解决软件包之间的依赖关系。

```shell
# 安装包
yum install package_name

# 查看已安装的包
yum list

# 更新已安装的包
yum update
```

## 3 apt 的使用

配置源：

- 首先备份原始的文件：`sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup`。
- 配置镜像：<https://mirrors.tuna.tsinghua.edu.cn/>，选择好对应的平台和版本，覆盖 `/etc/apt/sources.list` 中的文件即可。

apt-get常用命令：

```shell
sudo apt-get update  更新源
sudo apt-get upgrade 更新已安装的包（先执行 update，apt-get 才能知道每个软件包的最新信息，从而正确地下载最新版本的软件。）
sudo apt-get install package 安装包
sudo apt-get remove package 删除包
sudo apt-cache search package 搜索软件包
sudo apt-cache show package  获取包的相关信息，如说明、大小、版本等
sudo apt-get install package --reinstall   重新安装包
sudo apt-get -f install   修复安装
sudo apt-get remove package --purge 删除包，包括配置文件等
sudo apt-get build-dep package 安装相关的编译环境
sudo apt-get dist-upgrade 升级系统
sudo apt-cache depends package 了解使用该包依赖那些包
sudo apt-cache rdepends package 查看该包被哪些包依赖
sudo apt-get source package  下载该包的源代码
sudo apt-get clean && sudo apt-get autoclean 清理无用的包
sudo apt-get check 检查是否有损坏的依赖
```

## 4 其他安装方式

使用 wget 可以下载开源软件的源码，然后手动编译后安装。

```shell
wget https:/lopenresty.org/download/openresty-1.15.8.1.tar.gz
tar-zxf openresty-VERSION.tar.gz
cd openresty-VERSION/
# 运行脚本，自行配置一下缓解，--prefix=/usr/local/openresty 用于指定安装目录
./configure --prefix=/usr/local/openresty
// 编译，-j2 表示使用两个逻辑cpu进行编译
make -j2
# 安装
make install

```

## 5 配置环境变量

可以通过 export 命令配置：

```shell
export JAVA_HOME=/root/jdk-XXX_linux-x64
export PATH=$JAVA_HOME/bin:$PATH

# 将配置持久化
source .bashrc
```

export 命令仅在当前命令行的会话中管用，一旦退出重新登录进来，就不管用了，如果想要永久配置，则可以配置在 `.hashrc` 中，在当前用户的默认工作目录，例如 `/root` 或者 `/home/username` 下面，有一个.bashrc 文件，每次登录的时候，这个文件都会运行，因而把它放在这里。这样登录进来就会自动执行。当然也可以通过 `source .bashrc` 手动执行。

## 6 软件安装位置

apt-get 下载后，软件所在路径是什么：`/var/cache/apt/archives`，ubuntu 默认的PATH为：`PATH=/home/brightman/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games`

**apt-get install安装目录是包的维护者确定的，不是用户**。

`dpkg -L 软件包的名字`，获取这个软件包包含了哪些文件。

- 系统安装软件一般在 `/usr/share`
- 文档一般在 `/usr/share`
- 可执行文件 `/usr/bin`
- 配置文件 `/etc`
- lib文件 `/usr/lib`

## 7 运行软件

### 直接运行

Linux 不是根据后缀名来执行的。它的执行条件是这样的：只要文件有 x 执行权限，都能到文件所在的目录下，通过./filename运行这个程序。当然，如果放在 PATH 里设置的路径下面，就不用./ 了，直接输入文件名就可以运行了，Linux 会帮你找。

### 后台运行

- nohup命令。这个命令的意思是 no hang up（不挂起），也就是说，当前交互命令行退出的时候，程序还要在。
- 在命令行命令的最后加上 &，就表示该程序不能独占当前窗口的交互命令行，而是应该在后台运行。

示例：

```shell
# “1”表示文件描述符 1，表示标准输出，“2”表示文件描述符 2，意思是标准错误输出，“2>&1”表示标准输出和错误输出合并到 out.file 里。
nohup command >out.file 2>&1 &

# 关闭上面命令启动的程序
# ps -ef 可以单独执行，列出所有正在运行的程序。
# awk 工具可以很灵活地对文本进行处理，这里的 awk '{print $2}'是指第二列的内容，是运行的程序 ID。
# 然后通过 xargs 传递给 kill -9，也就是发给这个运行的程序一个信号
ps -ef |grep 关键字  |awk '{print $2}'|xargs kill -9
```

### 以服务方式运行

Linux 也有相应的服务，这就是程序运行的第三种方式，以服务的方式运行。例如常用的数据库 MySQL，就可以使用这种方式运行。

在 ubuntu上：

- `apt-get install mysql-server` 的方式安装 MySQL，然后通过命令 `systemctl start mysql`启动 MySQL，通过`systemctl enable mysql`设置开机启动。之所以成为服务并且能够开机启动，是因为在 `/lib/systemd/system` 目录下会创建一个 `XXX.service` 的配置文件，里面定义了如何启动、如何关闭。

在 CentOS 上（MySQL 被 Oracle 收购后，因为担心授权问题，改为使用 MariaDB，它是 MySQL 的一个分支。）

- 通过命令 `yum install mariadb-server mariadb` 进行安装，命令 `systemctl start mariadb` 启动，命令 `systemctl enable mariadb` 设置开机启动。同理，会在 `/usr/lib/systemd/system` 目录下，创建一个 `XXX.service` 的配置文件，从而成为一个服务。

## 8 升级内核

使用 yum 升级内核：（由于依赖于远程仓库，不一定能安装到最新的内核版本）

1. 查看内核版本：`uname -r`
2. 升级内核：
   1. yum 仓库和国内的镜像可能没有那么高的内部版本，可用使用 epel 仓库，安装即可使用：`yum install epel-release -y`
   2. 指定内核版本 `yum install kernel-3.10.0`，安装最新内核版本 ``yum install kernel`。
3. 升级已安装的其他软件包和补丁：`yum update`

源代码编译安装升级内核版本：

1. 安装依赖包：`yum install gcc gcc-c++ make ncurses-devel openssl-devel elfutils-libelf-devel`
2. 下载内核
3. `tar xvf linux-xxx.tar.xz -C /usr/src/kernels`
4. 配置内核编译参数
   1. 方式1：重新配置内核：`cd /usr/src/kernels/linux-5.1.10`，`make menuconfig | allyesconfig | allnoconfig`（内核很多东西需要进行配置）
      1. menuconfig 交互式配置
      2. allyesconfig 全部配置
      3. allnoconfig 最小内核版本
   2. 方式2：使用原有配置：`cp /boot/config-kernelversion.platform-name /usr/src/kernels/linux-5.1.10/.config`
5. make -j2 all（可用 `lscpu` 查看cpu个数）
6. make modules_install（先安装内核所支持的模块）
7. make install

## 9 grub 配置文件

grub 是启动引导软件。

1. 如何设置默认引导项
2. 忘记 root 密码如何重置

具体参考：《Linux实战技能100讲》-36 讲

## 10 引用

- [Ubuntu(Debian)的 aptitude 与 apt-get 的区别和联系](http://www.cnblogs.com/yuxc/archive/2012/08/02/2620003.html)
- [apt 和 apt-get 的区别](https://juejin.im/post/5d7731e15188257e8c4d974d)
