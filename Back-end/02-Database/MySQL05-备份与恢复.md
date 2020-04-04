# MySQL备份

## 备份

mysql\bin\mysqldump.exe备份工具

```sql
//比如要备份 study数据库
mysqldump -h localhost -u root -p study > D:/study.txt
```

## 恢复

恢复前对应名称的数据库必须存在：

方式一：

```sql
//study为数据名
crate database study;
use study
source D:/study.txt

//如果备份中自动包含了创建数据库的命令，则直接
source D:/study.txt
```

方式二：

```sql
//study为数据名
mysql  -u root -p study < D:/study.txt
```
