# MySQL

----

## 1 简介

MySQL是流行的开放源码SQL数据库管理系统。

简介：

- MySQL是一种数据库管理系统。
- MySQL软件是一种开放源码软件。
- MySQL数据库服务器具有快速、可靠和易于使用的特点。
- MySQL服务器工作在客户端/服务器模式下，或嵌入式系统中。
- 有大量可用的共享MySQL软件。

MySQL特性：

- 内部构件和可移植性
- 使用C和C++编写
- 提供了用于C、C++、Eiffel、Java、Perl、PHP、Python、Ruby和Tcl的API
- 采用核心线程的完全多线程 如果有多个CPU，它能方便地使用这些CPU。

### 使用MySQL

MySQL命令行的基本语法：

- 连接MySql：mysql命令格式： `mysql -h 主机地址 -u 用户名 －p用户密码`，比如在本地主机的命令行输入：`mysql -h localhost -u root -p`
- 退出数据库：`exit`
- 修改密码：`mysqladmin -u root -p oldpassword password newpassword`
- `SELECT User, Host FROM mysql.user;`：查看所有用户

## 2 SQL语言分类

SQL：Structured Query Language的缩写，结构化查询语言， 作用是一种定义、操作、管理关系数据库的句法。大多数关系型数据库都支持。结构化查询语言的工业标准由ANSI(美国国家标准学会，ISO的成员之一)维护。

- 数据定义语言：简称DDL(Data Definition Language)，用来定义数据库对象：数据块、表、列等，常用关键字：create、alter、drop。
- 数据操作语言：简称DDL(Data Manipulation Language)，用来对数据库中表的记录进行更新，常用关键字：insert、delete、update。
- 数据查询语言：简称DQL(Data Query Language)，用来查询数据库中表的记录，常用关键字：select、from、where。。
- 数据控制语言：简称DCL(Data Control Language)，用来定数库的访问权限和安全级别和创建用户，常用关键字：grant等
- 事务处理语言：TPL。
- 指针控制语言：CCL。

## MySQL 教程

- [w3school-sql](http://www.w3school.com.cn/sql/index.asp)
- 《SQL必知必会》
- 《sql权威指南第4版》
- 《MySQL从入门到精通》
- 《MySQL开发者SQL权威指南》
