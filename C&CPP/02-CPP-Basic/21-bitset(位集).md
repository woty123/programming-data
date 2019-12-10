# bitset(位集)

使用 bitset 做标记处理，可以节约内存空间，因为标记只有`是/不是`两个状态，仅使用一个位即可表示，一个字节就可以表示八个标记，这个技术在 Android 中就有大量使用。

C++ 标准库提供的 bitset 类简化了位集的处理。要使用 bitset 类就必须包含相关的头文件：

```cpp
include <bitset>
using std::bitset;
```

## bitset 的初始化

初始化bitset对象的方法：

方法 | 说明
---|---
`bitset<n> b;` | b 有 n 位，每位都 0
`bitset<n> b(u);` | b 是 unsigned long 型 u 的一个副本
`bitset<n> b(s);` | b 是 string 对象 s 中含有的位串的副本
`bitset<n> b(s, pos, n);` | b 是 s 中从位置 pos 开始的 n 个位的副本。

用unsigned值初始化bitset对象:

- 给出的长度 n 值必须是常量表达式。
- 当用 unsigned long 值作为 bitset 对象的初始值时，该值将转化为二进制的位模式。而 bitset 对象中的位集作为这种位模式的副本。
  - 如果 bitset 类型长度大于 unsigned long 值的二进制位数，则其余的高阶位将置为 0。
  - 如果 bitset 类型长度小于 unsigned long 值的二进制位数，则只使用 unsigned 值中的低阶位，超过 bistset 类型长度的高阶位将被丢弃。

```cpp
itset<32> bitvec; // 32位，全部为 0；
// bitset 类型长度小于 unsigned long 值的二进制位数
bitset<16> bitvec1(0xffff);// 0-15 位为 1
// bitset 类型长度等于 unsigned long 值的二进制位数
bitset<32> bitvec2(0xffff);// 0-15 位为 1，16 到 31 位为 0
```

用string对象初始化bitset对象

- 字符串 s 必须是类似 `111111000000011001101"`的形式。
- string 对象和 bitsets 对象之间是反向转化的：string 对象的最右边字符（即下标最大的那个字符）用来初始化 bitset 对象的低阶位（即下标为 0 的位）。

```cpp
string strval();
bitset<32> bitvec4(strval);

sring str("1111111000000011001101");
bitset<32> bitvec5(str, 5, 4); // bitvec5 的从 3 到 0 的二进制位置为 1100 ，其他二进制位都置为 0。
bitset<32> bitvec6(str, str.size() - 4);// 使用最后四个字符。
```

## bitset 的操作

方法 | 说明
---|---
`b.any()` | b 中是否存在置为 1 的二进制位？
`b.none()` | b 中不存在置为 1 的二进制位吗？
`b.count()` | b 中置为 1 的二进制位的个数
`b.size()` | b 中二进制位的个数
`b[pos]` | 访问 b 中在 pos 处二进制位
`b.test(pos)` | b 中在 pos 处的二进制位置为 1 么？
`b.set()` | 把 b 中所有二进制位都置为 1
`b.set(pos)` | 把 b 中在 pos 处的二进制位置为 1
`b.reset()` | 把 b 中所有二进制位都置为 0
`b.reset(pos)` | 把 b 中在 pos 处的二进制位置为 0
`b.flip()` | 把 b 中所有二进制位逐位取反
`b.flip(pos)` | 把 b 中在 pos 处的二进制位取反
`b.to_ulong()` | 用 b 中同样的二进制位返回一个 unsigned long 值
`os << b` | 把 b 中的位集输出到 os 流
