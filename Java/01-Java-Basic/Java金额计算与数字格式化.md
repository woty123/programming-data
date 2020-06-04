# 金额计算与数字格式化

---

## 1 float和double不能用于精度计算

编写如下程序执行：

```java
public class Test {
    public static void main(String[] args) {
        System.out.println(0.06+0.01);
        System.out.println(1.0-0.42);
        System.out.println(4.015*100);
        System.out.println(303.1/1000);
    }
}
```

输出的结果为：

```java
0.06999999999999999
0.5800000000000001
401.49999999999994
0.30310000000000004
```

原因是：我们的计算机是二进制的。浮点数没有办法是用二进制进行精确表示。我们的CPU表示浮点数由两个部分组成：指数和尾数，这样的表示方法一般都会失去一定的精确度，有些浮点数运算也会产生一定的误差。如：2.4的二进制表示并非就是精确的2.4。反而最为接近的二进制表示是 `2.3999999999999999`。浮点数的值实际上是由一个特定的数学公式计算得到的。

java的float只能用来进行科学计算或工程计算，在大多数的商业计算中，一般采用java.math.BigDecimal类来进行精确计算。

---

## 2 BigDecimal的使用

   在使用BigDecimal类来进行计算的时候，主要分为以下步骤：

1. 用float或者double变量构建BigDecimal对象。
2. 通过调用BigDecimal的加，减，乘，除等相应的方法进行算术运算。
3. 把BigDecimal对象转换成float，double，int等类型。

```java
//常用的计算方法
public BigDecimal add(BigDecimal value);                        //加法
public BigDecimal subtract(BigDecimal value);                   //减法
public BigDecimal multiply(BigDecimal value);                   //乘法
public BigDecimal divide(BigDecimal value);                     //除法
//转换方法
floatValue()//to float
doubleValue()to double
//取值
max (b) //比较取最大值
min(b) //比较取最小值
abs()//取最绝对值
negate()//取相反数
```

### 2.1 除法细节

```java
    new BigDecimal(1).divide(new BigDecimal(3))
```

上面代码回抛出异常

```java
    Exception in thread "main" java.lang.ArithmeticException: Non-terminating decimal expansion; no exact representable decimal result.
```

原因: 通过BigDecimal的divide方法进行除法时当不整除，出现无限循环小数时，就会抛异常。解决方法：设置精确度;就是给divide设置精确的小数点。

```java
// - setScale(int newScale, int roundingMode)方法
// - newScale：表示保留小数点后的位数
// - roundingMode：表示舍去多余小数的计算方式，如：四舍五入
new BigDecimal(1).divide(new BigDecimal(3),3 ,BigDecimal.ROUND_CEILING)
```

- ROUND_DOWN 直接删除多余的小数
- ROUND_CEILING 进一位，如：2.33->2.34
- ROUND_FLOOR
- ROUND_HALF_UP 四舍五入
- ROUND_HALF_DOWN
- ROUND_HALF_EVEN
- ROUND_UNNECESSARY

---

## 3 BigDecimal的创建与比较

### 3.1 构建

EffectiveJava中说到equals方法时，强烈建议equals和compareTo方法返回相同的结果，但是也提到了BigDecimal没有遵守这样的规定。

```java
BigDecimal aDouble =new BigDecimal(1.22);
System.out.println("construct with a double value: " + aDouble);
BigDecimal aString = new BigDecimal("1.22");
System.out.println("construct with a String value: " + aString);

//输出结果如下：
construct with a doublevalue:1.2199999999999999733546474089962430298328399658203125
construct with a String value: 1.22
```

 JDK的描述：

- 参数类型为double的构造方法的结果有一定的不可预知性。有人可能认为在Java中写入`newBigDecimal(0.1)`所创建的BigDecimal正好等于 0.1（非标度值 1，其标度为 1），但是它实际上等于`0.1000000000000000055511151231257827021181583404541015625`。这是因为0.1无法准确地表示为 double（或者说对于该情况，不能表示为任何有限长度的二进制小数）。这样，传入到构造方法的值不会正好等于 0.1（虽然表面上等于该值）。
- 另一方面，String 构造方法是完全可预知的：写入 `newBigDecimal("0.1")` 将创建一个 BigDecimal，它正好等于预期的 0.1。因此，比较而言，**通常建议优先使用String构造方法**。

### 3.2 比较

所以：**我们如果需要精确计算，非要用String来够造BigDecimal不可！！！**

```java
/*
结果为：

    false
    0

原因：
    equals不仅比较大小，还比较精度
    compareTo只比较大小
*/
System.out.println(new BigDecimal("1").equals(new BigDecimal("1.0")));
System.out.println(new BigDecimal("1").compareTo(new BigDecimal("1.0")));
```

---

## 4 使用NumberFormat格式化数字

```java
public static String formatValue(Object value) {
    String content = null;
    if (value == null) {
        content = "";
    } else {
        if (value instanceof BigDecimal) {
            //conver to fortmat String
            NumberFormat nf = NumberFormat.getInstance();
            nf.setMinimumFractionDigits(2);//小数点最少保留多少位
            nf.setMaximumFractionDigits(3);//小数点最多保留多少位
            nf.setRoundingMode(RoundingMode.UP);//小数点保留算法
            content = nf.format(value);
        } else {
            content = String.valueOf(value);
        }
    }
    return content;
}
```

扩展：格式化科学计算法的数字

```java
DecimalFormat df = new DecimalFormat("0.00");
df.setRoundingMode(RoundingMode.HALF_UP);
String format = df.format(8.8889065331E8);
System.out.println(format);
//结果：8.89
```

---

## 5 使用总结

- 商业计算使用BigDecimal。
- 尽量使用参数类型为String的构造函数。
- BigInteger与BigDecimal都是不可变的（immutable）的，在进行每一步运算时，都会产生一个新的对象，使用新的对象接收计算结果。
