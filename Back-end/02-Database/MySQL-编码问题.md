# MySQL 编码问题

## 1 查看编码

查看 MySQL 编码：`SHOW VARIABLES LIKE 'char%';`

```sql
mysql> SHOW VARIABLES LIKE 'char%';
+--------------------------+-------------------------------------------+
| Variable_name            | Value                                     |
+--------------------------+-------------------------------------------+
| character_set_client     | utf8                                      |
| character_set_connection | utf8                                      |
| character_set_database   | utf8                                      |
| character_set_filesystem | binary                                    |
| character_set_results    | utf8                                      |
| character_set_server     | utf8                                      |
| character_set_system     | utf8                                      |
| character_sets_dir       | D:\dev_tools\MySQL\Server\share\charsets\ |
+--------------------------+-------------------------------------------+
```

安装时指定了字符集为 UTF8，所以所有的编码都是 UTF8。

- character_set_client：MySQL 服务器以该编码方式解码客户端传过来的数据，所以要保证客户端采用的编码与此设置一致。
- character_set_connection：mysqld 收到客户端的语句后，要转换到的编码。
- character_set_database：数据库默认编码，在创建数据库时，如果没有指定编码，那么默认使用 database 编码。
- character_set_server：MySQL 服务器默认编码。
- character_set_results：响应的编码，即查询结果返回给客户端的编码。

一般建议保持编码完全一致，即统一为 UTF-8 即可，当然也可以修改部分编码。

```sql
set character_set_client=UTF8;
set character_set_results=UTF8;
-- 同时设置 character_set_client, character_set_connection, character_set_results
set names UTF8;
```

## 2 Windows 控制台编码

由于 Windows 的命令行窗口默认为 GBK，查询数据的如果是 UTF8 的，则显示出来会出现乱码问题。

解决方案：

1. 修改 mysql 编码。（不推荐）
2. 修改 cmd 窗口编码。
   1. 运行 `chcp 936` 切换到 GBK 编码
   2. 运行 `chcp 65001` 切换到 UTF8 编码

## 3 文件配置

在 mysql 运行时，通过命令修改编码只对当前连接有效，可以通过修改配置文件来处理这一问题，配置文件路径：

- Windows 为：MySql 的安装目录下，新建一个 `my.ini` 文件。
- Linux 为：`/etc/my.cnf`

配置内容：

```sql
[client]
default-character-set=utf8

[mysql]
default-character-set=utf8
```

具体参考

- [深入了解mysql数据传输编码原理](https://www.cnblogs.com/jave1ove/p/7454966.html)
- [MySQL：windows中困扰着我们的中文乱码问题](https://www.cnblogs.com/wj-1314/p/9147166.html)
- [set names的含义](https://hokkaitao.github.io/set-names)
