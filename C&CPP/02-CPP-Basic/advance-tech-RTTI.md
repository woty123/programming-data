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

- [ ] todo
