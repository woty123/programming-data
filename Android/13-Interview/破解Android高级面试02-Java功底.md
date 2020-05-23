>[大厂资深面试官 带你破解Android高级面试](https://coding.imooc.com/class/317.html) 笔记

# 2 Java 功底

---
## 2.1 Java 的 char 是两个字节，如何存储 UTF-8 字符？

### 考察什么

- 是否熟悉 Java Char 和字符串（初级）
- 是否了解字符串的隐射和存储细节（中级）
- 是否能触类旁通，横向对比其他语言（高级）

### 题目剖析

- 面试题经常故意设计陷阱
- 但你不能说题目错了
- 题目只是给定范围，是话题作为而不是命题作文

### 题目结论

- UTF-8 编码需要占用 1-3 个字节。（题目是个陷阱）
- Java中字符仅以一种形式存在，那就是 Unicode。由于 java 采用 unicode 编码，char 在 java 中占 2 个字节。2 个字节（16位）来表示一个字符。
- UTF-8 不是字符集，而是字符编码：`人类自然语言-->字符集(映射)-->计算机存储(编码)`
- Unicode 通用字符集占两个字节，例如“中”。
- **字节序标志**：`byte [] bytes = "中".getBytes("utf-16")` 的长度为 4, 内容为 `fe ff 4e 2d`，为什么会是四个呢？前面两个存储的是字节序标志。
- Unicode 扩展字符串需要用一对 char 表示，比如表情。
- Unicode 是字符集，不是编码，作用类似于 ASCII 码。
- Java String 的 length 不是字符的个数。
- Jave9 对 Latin 字符存储空间做了优化，但`字符串长度`依然不等于`字符个数`。

### 与 python 对比

```python
# 没问题
byteString = "abc"

# python 使用中文字符串，需要指定字符编码，否则 python 不支持采用什么编码节码。
# 使用 codeing = utf-8，*.py文件中存放的是 UTF-8 编码后的字节，字面量会用 utf-8 编码成字节存入字符串。
# codeing = utf-8
byteString = "中国"
```

Java 中的字节与字符串

```java
byte [] byteString = "中国".getBytes("uft-16")
String unicodeString = "中国"
```

python 中的字节与字符串

```python
byteString = "中国"
unicodeString = u"中国"
```

- `*.py` 文件中存放的是 `UCS2(≈UTF-16)` 编码后的字节，python 是解释执行的，源文件与执行时内存中的字符串一直
- Javac 指定编码将字符串统一转换为 `MUTF-8`
- PYthon 的 `len(字符串)` 等于字符的个数。

### 深入

- 计算机中储存的信息都是用二进制数表示的；而我们在屏幕上看到的英文、汉字等字符是二进制数转换之后的结果。通俗的说，按照何种规则将字符存储在计算机中，如'a'用什么表示，称为"编码"；反之，将存储在计算机中的二进制数解析显示出来，称为"解码"，如同密码学中的加密和解密。在解码过程中，如果使用了错误的解码规则，则导致'a'解析成'b'或者乱码。
- **字符集（Charset）**：是一个系统支持的所有抽象字符的集合。字符是各种文字和符号的总称，包括各国家文字、标点符号、图形符号、数字等。
- **字符编码（Character Encoding）**：是一套法则，使用该法则能够对自然语言的字符的一个集合（如字母表或音节表），与其他东西的一个集合（如号码或电脉冲）进行配对。即在符号集合与数字系统之间建立对应关系，它是信息处理的一项基本技术。通常人们用符号集合（一般情况下就是文字）来表达信息。而以计算机为基础的信息处理系统则是利用元件（硬件）不同状态的组合来存储和处理信息的。元件不同状态的组合能代表数字系统的数字，因此字符编码就是将符号转换为计算机可以接受的数字系统的数，称为数字代码。

具体参考[字符集和字符编码（Charset & Encoding）](https://www.cnblogs.com/skynet/archive/2011/05/03/2035105.html)

### 技巧点拨

- 抓住细节，有技巧地回避知识盲区
- 把我节奏，不要等面试官追问
- 主动深入，让面试管了解你的知识体系
- 触类旁通，让面试官眼前一亮

---
## 2.2 Java String 可以有多长

### 考察什么？

- 是否对字符串编码有深入了解（中级）
- 是否对字符串在内存中的存储形式有深入了解（高级）
- 是否对 Java 虚拟机字节码有足够的了解（高级）
- 是否对 Java 虚拟机指令有一定的了解（高级）

### 问题剖析

- 字符串有多长是指字符串数还是字节数？
- 字符串有几种存在的形式？
- 字符串的不同形式受到何种限制？

```java
//字面量，编译期决定，存储在栈上
String longString = "aaaa...aaaa"

//存储在堆上
byte[] bytes = loadFromFile(new File("x.txt"));
String supperLongString = new String(bytes);
```

**Java 栈**：

```java
//源文件
String longString = "aaaa...aaaa"

//字节码 *.class，字符串在字节码中是使用 u8 的结构存储的
CONSTANT_Utf8_info{
    u1 tag;
    u2 length;//2个字节，65535个
    u1 bytes[length];
}

//Java虚拟机内存：字面量加载到方法区中的常量池中
```

结论：栈上的字面量的`字节数`应该 `<= 65535`？

- 受字节码限制，字符串最终的 MUTF-8 字节数不能超过 65535 个。
- Latin 字符，受到 javac 代码限制，最多 65534 个(javac 的 bug)。
- 非 Latin 字符最终对于字节数差异较大，最多字节数个数是 65535 个。
- 如果运行时方法区设置较小，也会受到方法区大小的限制。

**Java 堆**：

- 受虚拟机指令限制，字符数理论上限为 `Integer.MAX_VALUE`
- 手虚拟机实现限制，实际上线可能小于 `Integer.MAX_VALUE`
- 如果堆内存较小，也会受到堆内存的限制

### 技巧点拨

- 思路很重要
  - 这种类型的问题最终往往结果不重要
  - 拿到问题，知道如何分析，知道从哪分析是关键
- 切不可眼高手低
  - 简单的问题背后藏着玄机
  - 尽一切可能将题目引向自己熟悉的领域

### 书籍推荐

- 《Java 虚拟机规范》
- 《Java 预言规范》

---
## 2.3 Java 匿名内部类有哪些限制

### 考察什么？

- 考察匿名内部类的概念和用法（中级）
- 考察语言规范以及横向对比等（中级）
- 作为考察内存泄漏的切入点（高级）

### 问题剖析

- 匿名内部类有名字：`com.xx.OuterClass$1`，$1 表示定义的第一个匿名内部类。
- 匿名内部类的继承结构，new 时不能再实现其他接口，(java内部类可以，kotlin 是可以的)。
- 非静态匿名内部类的构造方法由编译器定义，构造方法上有一个外部类类型的作为方法参数。
```java
class OuterClass{
    public abstract class InnerClass{
        abstract void test();
    }
}

public class Client{
    public void run(){
        InnrClass innerClas = new OuterClass.new InnerClass(){};
    }
}

//编译结果，注意 InnerClass 定义为接口，则不会有 OuterClass 作为构造参数
public class Client$1{
    //由编译器定制
    public Client$1(Client client, OuterClass outerClass){

    }
}
```
- 匿名内部类所引用的句部变量应该是 final 的
```java
class OuterClass{
    public interface InnerClass{
        void test();
    }
}

public class Client{
    public static void run(){
        final Object object = new Object();
        InnrClass innerClas = new OuterClass.new InnerClass(){
            @Override
            void test(){
                System.out.print(object.toString());
            }
        };
    }
}

//如果 object 不是 final 的，那么 object 就是可以被修改的，那就会造成局部的 object 与匿名内部类所引用的不是同一个对象，
//从而给开发者带来困惑，仅此而已。
public class Client$1{
    //由编译器定制
    public Client$1(Object obj){

    }
}
```

### 技巧点拨

- 关注语言版本变化
  - 体现堆技术的热情
  - 体现好学本质
  - 现得专业

---
## 2.4 怎么理解 Java 的方法分派

### 考察什么？

- 多态、虚方法表的认识（初级）
- 对编译和运行时的理解和认识（中级）
- 对 Java 语言规范和运行机制的深入认识（高级）
- 横向对比各类语言的能力（高级）
  - Groovy
  - C++，Native 程序开发

### 题目剖析

怎么理解 Java 的方法分派

- 就是确定调用了谁的方法，哪个方法
- 针对方法重载的情况进行分析
- 针对方法覆写的情况进行分析

```java
public SuperClass{
    public String getName(){
        return "Super";
    }
}

public SubClass{
    public String getName(){
        return "Sub";
    }
}

public class Client{
    public static void main(String... args){
        SuperClass superClass = new SubClass();
        printHello(superClass);
    }
}

public static void printHello(SuperClass superClass){
    System.out.println("Hello "+superClass.getName())
}
public static void printHello(SubClass subClass){
    System.out.println("Hello "+subClass.getName())
}
```

结论：

- 执行结果：`"Hello Sub"`，`getName` 方法的调用取决于变量运行时的实际类型。
- 重载方法的方法分派：程序如何执行，调用的方法取决于编译时期的类型，调用的是第一个。

**方法分派种类**：

静态分派-方法重载分派

- 编译期确定
- 依据调用者的声明类型和方法参数类型

动态分派-方法覆写分派

- 运行时确定
- 依据调用者的实际类型

**触类庞统**：

- groovy 运行上面代码时，所运行的函数是第二个，也就是 groovy 中重载方法的方法分派取决于参数的实际类型。
- c++ 中的方法分配

### 技巧点拨

- 横向对比
  - 体现扎实的语言功底
  - 体现对编程语言特性的专研精神
  - 现得专业

---
## 2.5 Java 泛型机制

### 考察什么？

- 对 Java 泛型使用是否停留在集合框架的使用(初级)
- 对 Javc 泛型的实现机制的认知和理解（中级）
- 是否有足够的项目开发实战经验和“踩坑”经验（中级）
- 对泛型（或模板）编程是否有深入的对比研究（高级）
- 对常见的框架原理是否有过深入剖析（高级）

### 题目剖析

- 题目区分度比较大
- 回答需要提及以下几个点才能突出亮点：
  - 类型擦除从编译角度的细节
  - 类型擦除对运行时的影响
  - 类型擦除对发射的影响
  - 对比类型不擦处的语言(C++/C#)
  - 为什么 Java 选择类型擦除
- 可从类型擦除的优劣来着手分析

**类型擦除的优势**：

- 运行时内存负担小
- 兼容性好，Java1.5 才推出泛型，此时 Java 的使用者已经很多。

**Java 泛型劣势**：

- 基本类型无法作为泛型实参，有装箱插箱的开销。
- 泛型类型无法用作方法重载（类型擦除后一致）
- 泛型类型无法当作真实的类型
  - 无法 new T()
  - 无法使用 instanceof 判断泛型类型
- 静态方法无法引用类泛型参数
- 类型强转的运行时开销（编译时插入强转代码）
  
**Java 泛型的附加的签名信息**：

- Gson 中的 TypeTOken
- Retrofit

```java
class SuperClass<T>{}

//反射 SubClass 时，是可以拿到 SuperClass 上的泛型实参 String 的信息的
class SubClass extends SuperClass<String>{

}
```

**关于 Koltin**：

- 扩展：Kotlin 中的反射更强大，有 mate 注解保留了很多编译期信息

### 技巧点拨

- 结合项目实战
  - 阐述观点，给出实际案例，例如 Gson、Retrofit
  - 实战中需要混淆，选哟注意哪些点以及原理

---
## 2.6 Activity 的 onActivityResult 为什么不设计成回调

### 考察什么？

- 是否熟悉 onActivityResult 的用法（初级）
- 是否思考过用回调代替 onActivityResult（中级）
- 是否实践过用回调代替 onActivityResult（中级）
- 是否意识到回调存在的问题（高级）
- 是否能给出匿名内部类对外部类引用的解决方案（高级）

### 题目剖析

Activity 的 onActivityResult 使用起来菲常麻烦，为什么不设计成回调？

- onActivityResult 的作用
- 回调在这样的场景下适用么？
- 如果适用，那为什么不适用回调？
- 如果不适用，给出理由

**onActivityResult 作用**：

- startActivityForResult --> onActivityResult

**onActivityResult 为什么麻烦**：

- 代码逻辑分离，容易出现遗漏和不一致问题（startActivityForResult 后需要在 onActivityResult 继续处理逻辑，使用回调可以解决该问题）
- 写法不够直观，且结果数据没有类型安全的保障（setResult，使用回调无法解决该问题）
- 结果种类较多时，onActivityResult 就会逐渐臃肿且难以维护（使用回调可以解决该问题）

```java
startActivityForResult(intent, onResultCallback(){

})
```

**回调不适用，为什么**：

- Activity 在后台是可能被回收的，如果被回收那么回收前后的 Activity 是不同的实例。

**解决方案**：

- 基于注解处理器和 DummyFragment 的解决方案。
- 使用一个 DummyFragment，转发 Activity 的 onActivityResult。
- 注意在 Activity 回收后，通过 DummyFragment 替换之前 Activity 的引用。
- Fragment 的 mWho 的字段用于标识自身。
