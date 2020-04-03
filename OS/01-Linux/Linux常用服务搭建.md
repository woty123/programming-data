# Linux 常用服务器搭建

## 1 ftp

FTP 是File Transfer Protocol（文件传输协议）的英文简称，而中文简称为“文传协议”。用于Internet上的控制文件的双向传输。同时，它也是一个应用程序（Application）。基于不同的操作系统有不同的FTP应用程序，而所有这些应用程序都遵守同一种协议以传输文件。在FTP的使用当中，用户经常遇到两个概念："下载"（Download）和"上传"（Upload）。"下载"文件就是从远程主机拷⻉文件至自己的计算机上；"上传"文件就是将文件从自己的计算机中拷⻉至远程主机上。用Internet语言来说，用户可通过客户机程序向（从）远程主机上传（下载）文件。

**安装vsftpd服务器** `sudo apt-get install vsftpd`

### 1.1 配置ftp

- 配置ftp，`/etc/vsftpd.conf`

```shell
anonymous_enable=NO   //不允许匿名登录
local_enable=YES   //允许本地用户登录
local_root=/home/ztiany/ftp   //指定上传下载的目录
chroot_list_enable=YES   //允许vsftpd.chroot_list文件中的用户登录FTP服务器
chroot_list_file=/etc/vsftpd.chroot_list //记录可以登录的用户
write_enable=YES   //允许用户上传文件
```

- 添加用户

```shell
mkdir -p /home/ztiany
useradd ztiany -g ftp -d /home/ztiany -s /sbin/nologin #添加用户，-s表示指定用户登入后所使用的shell
passwd ztiany #设置密码
chmod 777 -R /home/ztiany
```

- 设置`etc/shells`，如果没有则加上下面两项

```shell
# 命令 vim /etc/shells
/usr/sbin/nologin
/sbin/nologin
```

- 创建并编辑`/ect/vsftpd.chroot_list`文件，加入刚刚创建的用户

```shell
ztiany #此时表示ztiany可以登录ftp服务器
```

- 配置好后需要重启vsftpd服务

```shell
service vsftp restart
```

### 1.2 远程登录ftp服务器

```shell
ftp ipAddress
put localfile targetFile 上传文件
get targetFile localFile 拉取文件
```

## 2 SSH

SSH为Secure Shell的缩写，由 IETF 的网络工作小组（Network Working Group）所制定；SSH 为建立在应用层和传输层基础上的安全协议。SSH是目前较可靠，专为远程登录会话和其他网络服务提供安全性的协议。常用于远程登录，以及用户之间进行资料拷⻉。利用SSH协议可以有效防止远程管理过程中的信息泄露问题。SSH最初是 UNIX 系统上的一个程序，后来又迅速扩展到其他操作平台。SSH 在正确使用时可弥补网络中的漏洞。SSH 客户端适用于多种平台。几乎所有 UNIX 平台—包括 HP-UX、Linux、AIX、Solaris、Digital UNIX、Irix，以及其他平台，都可运行SSH。使用SSH服务，需要安装相应的服务器和客户端。客户端和服务器的关系：如果，A机器想被B机器远程控制，那么，A机器需要安装SSH服务器，B机器需要安装SSH客户端。

### 2.1 安装ssh

```shell
sudo apt-get install openssh-server//安装ssh(Secure Shell)服务
```

### 2.2 远程登录ssh

```shell
ssh 用户名@IP使用
```

![](images/ssh.jpg)

### 2.3 SCP

远程拷⻉文件,scp -r 的常用方法：

本地文件复制到远程：

```shell
scp FileName RemoteUserName@RemoteHostIp:RemoteFile
scp FileName RemoteHostIp:RemoteFolder
scp FileName RemoteHostIp:RemoteFile
scp -r FolderName RemoteUserName@RemoteHostIp:RemoteFolder
scp -r FolderName RemoteHostIp:RemoteFolder
```

远程文件复制到本地：

```shell
scp RemoteUserName@RemoteHostIp:RemoteFile FileName
scp RemoteHostIp:RemoteFolder FileName
scp RemoteHostIp:RemoteFile FileName
scp -r RemoteUserName@RemoteHostIp:RemoteFolder FolderName
scp -r RemoteHostIp:RemoteFolder FolderName
```

## 3 samba

Samba 是在 Linux 和 UNIX 系统上实现 SMB 协议的一个免费软件，能够完成在 windows、mac 操作系统下访问 linux 系统下的共享文件。

## 4 MySQL

```shell
apt-get update
apt-get install mysql-server mysql-client
测试是否安装成功：netstat -tap | grep mysql

启动MySQL服务：service mysql start
停止MySQL服务：service mysql stop
服务状态：service mysql status
修改 MySQL 的管理员密码：mysqladmin -u root password newpassword

正常情况下，mysql占用的3306端口只是在IP 127.0.0.1上监听，拒绝了其他IP的访问（通过netstat可以查看到）取消本地监需要修改 my.cnf 文件：

  1 vim /etc/mysql/my.cnf，把 bind-address = 127.0.0.1注释掉，如果配置文件中没有bind-address = 127.0.0.1，则添加下面内容：
       [mysqld]
       bind-address = 0.0.0.0
  2 重启MySQL服务器
  3 重新登录 mysql -uroot -p
  4 在mysql命令行中运行下面两个命令
  grant all privileges on *.* to 'root'@'%' identified by '远程登录的密码';
    flush privileges;
  5 检查MySQL服务器占用端口 netstat -nlt|grep 3306

数据库存放目录： /var/lib/mysql/
相关配置文件存放目录：/usr/share/mysql
相关命令存放目录：/usr/bin(mysqladmin mysqldump等命令
启动脚步存放目录：/etc/rc.d/init.d/
```

sql授权说明

语法：`grant 权限1,权限2, ... 权限n on 数据库名称.表名称 to 用户名@用户地址 identified by '连接口令';`

- `权限1，权限2，... 权限n` 代表 `select、insert、update、delete、create、drop、index、alter、grant、references、reload、shutdown、process、file` 等14个权限。
- 当`权限1，权限2，... 权限n` 被 `all privileges` 或者 `all` 代替时，表示赋予用户全部权限。
- 当 `数据库名称.表名称` 被 `*.*` 代替时，表示赋予用户操作服务器上所有数据库所有表的权限。
- 用户地址可以是localhost，也可以是IP地址、机器名和域名。也可以用 `'%'` 表示从任何地址连接。
- '连接口令'，远程连接时使用的密码，不能为空，否则创建失败。

>privileges 即特权的意思。

## 5 Tomcat

从官网下载tomcat，然后解压即可，远程连接时要开放对应的端口。

```shell
# 创建tomcat存放目录，比如 /usr/local 目录下
cd /usr/local
mkdir tomcat

# 下载tomcat
wget http://mirrors.shu.edu.cn/apache/tomcat/tomcat-8/v8.5.31/bin/apache-tomcat-8.5.31.tar.gz

# 解压
tar -xvf apache-tomcat-8.5.31.tar.gz

# 启动tomcat(记得开放8080端口)
./startup.sh
./shutdown.sh
```
