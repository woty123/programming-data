# RTTI（run-time type identification, 运行时类型识别）

在程序设计中，所谓的运行期类型信息（Runtime type information，RTTI）指的是在程序运行时保存其对象的类型信息的行为。某些语言实现仅保留有限的类型信息，例如继承树信息，而某些实现会保留较多信息，例如对象的属性及方法信息。运行期类型信息是一个电脑术语，用以标示一个电脑语言是否有能力在运行期保持或判别其对象或变量的类型信息。——[维基百科-运行期类型信息](https://zh.wikipedia.org/wiki/%E5%9F%B7%E8%A1%8C%E6%9C%9F%E5%9E%8B%E6%85%8B%E8%A8%8A%E6%81%AF)

## 1 C++ RTTI 简介

RTTI 的功能由两个运算符实现：

- typeid 运算符：用于返回表达式的类型。
- dynamic_cast 运算符：用于将基类的指针或引用安全地转换成派生类的指针或引用。

使用场景：想使用基类对象的指针或引用执行某个派生类操作并且该操作不是虚函数。

## 2 dynamic_cast 运算符

使用形式：

```cpp
dynamic_cast<type*>(e);
dynamic_cast<type&>(e);
dynamic_cast<type&&>(e);
```

- type 必须是一个类类型，并且该类型应该还有至少一个虚函数。
- 形式 1 中，e 必须是一个有效指针。
- 形式 2 中，e 必须是一个左值。
- 形式 3 中，e 不能是左值。

e 必须满足以下三个条件的任意一个：

- e 的类型是目标 type 的共有派生类。
- e 的类型是目标 type 的共有基类。
- e 的类型就是是目标 type 的类型。

### dynamic_cast 转换指针

定义类型：

```cpp
class BaseWithVirtual {

private:
    std::string name;
    int age;
public:

    BaseWithVirtual(std::string &_name, int _age) : name(_name), age(_age) {

    }

    virtual void printInfo() {
        std::cout << "name = " << name << ", age = " << age << std::endl;
    }

    std::string getName() const {
        return name;
    }

    int getAge() const {
        return age;
    }

};

class DeriveWithVirtual : public BaseWithVirtual {
private:
    std::string address;
public:
    DeriveWithVirtual(std::string &_name, int _age, std::string &_address)
            : BaseWithVirtual(_name, _age), address(_address) {

    }

    void printInfo() override {
        std::cout << "name = " << getName() << ", age = " << getAge() << ", address = " << address << std::endl;
    }
};
```

进行转换：

```cpp
BaseWithVirtual baseWithVirtual(name1, 90);
DeriveWithVirtual deriveWithVirtual(name2, 89, address1);

BaseWithVirtual *baseWithVirtualTempP = &deriveWithVirtual;
if (auto *tempP = dynamic_cast<DeriveWithVirtual *>(baseWithVirtualTempP)) {
    cout << "dynamic_cast<DeriveWithVirtual *>(&baseWithVirtual) success" << endl;
} else {
    cout << "dynamic_cast<DeriveWithVirtual *>(&baseWithVirtual) failed" << endl;
}

//输出结果：dynamic_cast<DeriveWithVirtual *>(&baseWithVirtual) success
```

- 对于指针类型的转换，如果转换失败，则 dynamic_cast 语句返回 0。
- 可以对空指针执行 dynamic_cast，结果是所需类型的空指针。

### dynamic_cast 转换引用

因为不存在空引用，所以引用类型转换错误时将会抛出 std::bad_cast 的异常。

```cpp
    BaseWithVirtual &baseWithVirtualTempR = deriveWithVirtual;
    try {
        auto &deriveWithVirtual1 = dynamic_cast<DeriveWithVirtual &>(baseWithVirtualTempR);
        cout << "dynamic_cast<DeriveWithVirtual &>(baseWithVirtualTempR) success" << endl;
    } catch (bad_cast) {
        cout << "dynamic_cast<DeriveWithVirtual &>(baseWithVirtualTempR) failed" << endl;
    }
```

## 3 typeid 运算符

使用方式：

```cpp
//e 是任意表达式或类型的名字
typeid(e);
```

- typeid 的返回值是 typeinfo 类型或其派生类型的一个常量引用，typeinfo 定一个在标准库 typeinfo 头文件中。
- typeid 可以作用于任意表达式，但是会忽略顶层 const。
- 如果 e 是一个引用类型，则 typeid 返回该引用所引用的对象的类型。
- 如果 e 是数组和函数，并不会执行向指针的标准类型转换（不会转换为首元素的地址），即 typeid 作用于数组时返回的是数组类型而不是指针类型。
- 当 e 不是类类型或者是一个不包含虚函数的类时，typeid 返回对象的静态类型，此时编译器无需对 e 进行动态检查和求值。
- 当 e 是一个定义了至少一个虚函数的类时，typeid 会进行动态检查，对 e 进行求值。
- 如果 e 是一个空指针，则 typeid 将抛出一个名为 bad_typeid 的异常。
- 当 typeid 作用于指针时（而非指针所指向的对象），返回的结果时该指针的静态编译类型，**typeid 应该作用于对象**。

```cpp
//在运行时比较两个对象的类型
if (typeid(*baseWithVirtualP) == typeid(deriveWithVirtual)) {
    cout << "typeid(*baseWithVirtualP) == typeid(deriveWithVirtual) == true" << endl;
}

//检测运行时类型是否是某种指定的类型
if (typeid(*baseWithVirtualP) == typeid(DeriveWithVirtual)) {
    cout << "typeid(*baseWithVirtualP) == typeid(DeriveWithVirtual) == true" << endl;
}
```

## 4 type_info 类

type_info 类的具体定义随着编译器的不同而略有差异，但是 C++ 标准规定 type_info 必须定义在 typeinfo 头文件中，并且至少提供下列操作：

- `t1 == t2`：如果 type_info 对象 t1 和 t2 表示同一种类型，则返回 true，否则返回 false。
- `t1 != t2`：如果 type_info 对象 t1 和 t2 表示不同的类型，则返回 true，否则返回 false。
- `t.name()`：返回一个 C 风格的字符串，表示类型的名称。
- `t1.before(t2)`：返回一个 bool 值，表示 t1 是否位于 t2 之前，before 采用的顺序关系是依赖于编译器的。

type_info 没有默认的构造函数，其拷贝、移动构造函数以及赋值操作符都是定义为删除的，得到 type_info 唯一的途径就是 typeid 操作符，

## 5 参考

- [RTTI简介](https://blog.csdn.net/K346K346/article/details/49831841)
