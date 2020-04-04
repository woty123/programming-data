create table employees
(
    id        int auto_increment primary key,
    last_name varchar(100),
    email     varchar(100),
    dept_id   int
);

create table departments
(
    id   int auto_increment primary key,
    dept_name varchar(100)
)