# 《深入理解 Java7 核心技术与最佳实践》

## 1 Java 7语法新特性

Java语言一直在不断改进自身的语法，以满足开发人员的需求。最大的改动发生在J2SE 5.0版本中。随后的Java SE 6并没有增加新的语法特性，而Java SE 7又增加了一些语法新特性。OpenJDK中的Coin项目（Project Coin）的目的是为了收集对Java语言的语法进行增强的建议。最终有6个语法新特性被加入到了Java 7中。这些语法新特性涉及`switch语句、整数字面量、异常处理、泛型、资源处理和参数长度可变方法的调用`等。

其他对Java平台所做的修改一样，Coin项目所建议的修改也需要通过JCP来完成。这些改动以`JSR 334（Small Enhancements to the JavaTM Programming Language）`的形式提交到JCP，Java 7语法新特性概要：

1. 在switch语句中使用字符串。（但还是推荐使用枚举类型）
2. 在Java 7之前，所支持的进制包括十进制、八进制和十六进制。十进制是默认使用的进制。八进制是用在整数字面量之前添加“0”来表示的，而十六进制则是用在整数字面量之前添加“0x”或“0X”来表示的。Java 7中增加了一种可以在字面量中使用的进制，即二进制。二进制整数字面量是通过在数字前面添加“0b”或“0B”来表示
3. Java 7对异常处理做了两个重要的改动：
   1. 一个是支持在一个catch子句中同时捕获多个异常
   2. 另外一个是在捕获并重新抛出异常时的异常类型更加精确。
4. try-with-resources 语句
5. @SafeVarargs 用于消除在可变参数中使用泛型带来的警告

Java 7 增加的 `try-with-resources` 新特性提供了另外一种管理资源的方式，这种方式能自动关闭文件。这个特性有时被称为自动资源管理(Automatic Resource Management, ARM)，该特性以 try 语句的扩展版为基础。自动资源管理主要用于，当不再需要文件（或其他资源）时，可以防止无意中忘记释放它们。

自动资源管理基于try 语句的扩展形式：

```java
try(需要关闭的资源声明){
    //可能发生异常的语句
} catch(异常类型变量名){
    //异常的处理语句
}......
 finally{
    //一定执行的语句
}
```

当try 代码块结束时，自动释放资源。因此不需要显示的调用 `close()` 方法。该形式也称为“带资源的try 语句”。注意：

- try 语句中声明的资源被隐式声明为final ，资源的作用局限于带资源的try 语句
- 可以在一条try 语句中管理多个资源，每个资源以“;” 隔开即可。
- 需要关闭的资源，必须实现了AutoCloseable 接口或其自接口Closeable

## 2 Java7 新增对动态性的支持

1. Java 7为所有与反射操作相关的异常类添加了一个新的父类 `java.lang.ReflectiveOperationException`。在处理与反射相关的异常的时候，可以直接捕获这个新的异常。而在Java 7之前，这些异常是需要分别捕获的。
2. Java7 修改了JVM规范，虚拟机中新的方法调用指令 invokedynamic，以及Java SE 7核心库中的java.lang.invoke包。这一个新特性对应的修改内容包含在JSR 292（Supporting Dynamically Typed Languages on the JavaTM Platform）中。Java虚拟机本身并不知道Java语言的存在，它只理解Java字节代码格式，即class文件。一个class文件包含了Java虚拟机规范中所定义的指令和符号表。Java虚拟机只是负责执行class文件中包含的指令。而这些class文件可以由Java语言的编译器生成，也可以由其他编程语言的编译器生成，还可以通过工具来手动生成。只要class文件的格式是符合规范的，Java虚拟机就能正确执行它。但是Java语言作为Java虚拟机上的第一个也是最重要的一种语言，它对Java虚拟机规范本身所产生的影响是最大的。事实上，Java虚拟机上的很多特性，是为了配合Java语言而产生的。Java语言作为一门静态类型的编程语言，也影响了Java虚拟机本身的动态性。可以说Java虚拟机本身又缺乏对动态性的支持，而Java 7中的动态语言支持，就是在Java虚拟机规范这个层次上进行修改，使Java虚拟机对于动态类型编程语言来说更加友好，性能也更好。

## 3 Java7 NIO.2

参考

- [](../02-IO&Network/01-JavaIO.md)
- [](../02-IO&Network/03-NIO.md)
- [](../02-IO&Network/04-NIO2.md)
