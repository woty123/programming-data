# 集合框架

## 1 Java集合框架

框架是一个类的集。它奠定了创建高级功能的基础。Java集合类库构成了Java的集合框架。

**集合框架**：用于存储数据的容器

**特点：**

1：对象封装数据，但是对象多了也需要存储。**集合用于存储对象。**
2：对象的个数确定可以使用数组，但是不确定怎么办？可以用集合。因为**集合是可变长度的。**

**集合和数组的区别：**

1：数组是固定长度的；集合可变长度的。
2：数组可以存储基本数据类型，也可以存储引用数据类型；集合只能存储引用数据类型。
3：数组存储的元素必须是同一个数据类型；集合存储的对象可以是不同数据类型。

**数据结构：**就是容器中存储数据的方式。

对于集合容器，有很多种。因为每一个容器的自身特点不同，其实原理在于每个容器的内部数据结构不同。集合容器在不断向上抽取过程中。出现了集合体系。**在使用一个体系时，原则：参阅顶层内容。建立底层对象。**

**将集合的接口与实现分离**：容器接口是容器的基础。使用接口可以将容器的实现与容器接口分开，因而可以使用相同的方法访问容器而不需关心容器具体的数据结构。同理，Iterator接口也使用户能够使用相同的方法访问不同的容器类。

## 2 具体的集合实现

### 2.1 接口

#### Collection接口

Collection的直接子类接口有:

- List：表示有序(元素存入集合的顺序和取出的顺序一致)集合，元素都有索引。元素可以重复。
- Set：表示无序(存入和取出顺序有可能不一致)集合，不可以存储重复元素。必须保证元素唯一性。
- Queue队列

#### 迭代器

**迭代器：是一个接口。作用：用于取集合中的元素。**

每一个集合都有自己的数据结构，都有特定的取出自己内部元素的方式。为了便于操作所有的容器，取出元素。将容器内部的取出方式按照一个统一的规则向外提供，这个规则就是**Iterator接口

### 2.2 集合实现

#### 链表

LinkedList，在Java程序语言设计中，所有的链表都被设计为双向链表。链表是有序无界的集合，同时LinkedList还实现了Deque接口，其扩展于AbstractSequentialList。

#### 数组列表

ArrayList，ArrayList封装了一个动态再分配的对象数组

#### 散列集

- 有一种从所周知的数据结构，可以快速的查找所需要的对象，散列表(Hashtable)，散列表为每个对象计算一个整数，称为散列码。在Java中散列表用链表的数组实现，每个列表被称为桶(bucket)。
- **散列冲突**：当不同对象的散列码相同时，需要用桶中的对象与新对象进行毕竟，查看这个对象是否已经存在。如果散列码是随机合理分布的，桶的数目也足够大，需要比较的次数就会很少。
- 如果大致知道会有多少个元素，就可以设置桶数，通常将桶数设置为预计元素数量的75%到150%，有些研究表明，最好将桶数设置为一个素数，标准的集合使用的桶数是2的幂，默认值为16.
- 并不能总是知道有多少个元素，如果散列表太满，就需要**再散列(rehashed)**，如果需要再散列，就需要创建一个桶数更多的表，将所有的元素插入到新的列表中，然后丢弃原来的表。**装填因子(load factor)**决定何时对列表进行再散列。默认的状态因子为0.75，表示超过75%的位置已填入元素就需要进行再散列。
- Java集合类库提供了一个HashSet类，其实现了基于散列的集。
- 集中元素要求实现hashCode和equals方法。

#### 树集

TreeSet是一个有序集合，TreeSet要求元素具有可比性。Comparable和Comparator可以提供元素比较的能力。将元素插入TreeSet要比插入HashSet要慢，但是与将元素插入到数据列表或者链表的正确位置相比，要快得多。TreeSet实现了**NavigableSet**接口，这个接口添加了几个便于定位元素以及反向遍历的非法。

#### 队列与双端队列

Queue接口表示队列。Deque接口表示双端队列，其继承与Queue接口，LinkedList是Deque的一个实现

#### 优先级队列

PriorityQuque

#### 映射表

映射表存储的是键值对。Java将其抽象为Map，有两个通用的实现HashMap和TreeMap。

另外还有SortedMap

#### 弱散列表

WeakHashMap

#### 链接散列表和链接映射表

Java1.4提供了两个类：LinkedHashSet和LinkedHashMap。用于记住插入的元素顺序，LinkedHashMap可以比较方便的实现LRU缓存算法，构造其子类实现removeEldestEntry非法可以让其根据条件自动删除已存入的元素。

#### 枚举集和枚举表

- EnumSet
- EnumMap

#### 标识散列映射表

IdentityHashMap，IdentityHashMap在比较元素时，使用`==`而不是equals非法。

## 3 视图与包装器

这里的视图类似于数据库中的视图概念，通过视图可以获取其他的实现了集合接口和映射表接口的对象，比如Map的keySet非法，keySet方法返回的是一个实现Set接口的类对象，这个类的方法对原始映射表进行操作。这种集合称为**视图(Views)**

## 4 集合与数组的转换

```java
Arrays.asList
Object[] toArray()
<T> T[] toArray(T[] a)
```

## 5 Collections与Arrays

Collections与Arrays提供了一些有用的工具方法和简单的算法。

- RandomAccess随机访问列表,实现者有ArrayList，用来表明支持快速(通常是固定时间)随机访问
- SequenceAccess顺序访问列表， 抽象框架为AbstractSequentialList，具体实现有LinkedList。标表示适用于使用顺序方式(如迭代器)访问

主要应用：

```java
public static void accessList(List list) {
    long startTime = System.currentTimeMillis();
    if (list instanceof RandomAccess) {
        System.out.println("实现了 RandomAccess 接口...");
        for (int i = 0; i < list.size(); i++) {
            list.get(i);
        }
    } else {
        System.out.println("没实现 RandomAccess 接口...");
        for (Iterator iterator = list.iterator(); iterator.hasNext();) {
            iterator.next();
        }
    }
    long endTime = System.currentTimeMillis();
    System.out.println("遍历时间：" + (endTime - startTime));
}
```

## 6 遗留集合

- Hashtable
- Enumeration
- Properties
- Stack
- BitSet
- Vector
