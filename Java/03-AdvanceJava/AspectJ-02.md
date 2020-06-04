# Aspectj 学习

---
## 1 基本概念

| 名词 |  含义 |
| --- | --- |
| 通知（Advice） | 通知描述和连接点相关的信息，即执行点的方位，包括（Before、After、Around...等），结合执行点方位和和切点信息，我们就可以找到连接点。 |
| 连接点（JoinPoint） | 程序执行过程中的某个特定的执行点，这些点是代码注入目标的入口。例如方法的调用开始、结束，或者特定的异常被抛出。|
| 切入点（Pointcut） | 连接点是程序中客观存在的事物，而切入点是**一个连接点的集合、以及收集的连接点的上下文信息**（例如方法参数、被执行方法和对象），AOP 框架通过切入点来定位特定的连接点，通知在这些切入点被触发。AOP框架允许开发者以多种方式定义切入点，简单理解切入点为告诉 AspectJ 对那些连接点进行切入。 |
| 目标对象（Target Object） | 被增强逻辑织入的目标类 |
| 织入（Weaving） | 织入是将 Advance 添加到目标类具体连接点的过程。 |
| 切面（Aspect） | 切面由切点和通知组成，它既包括横切逻辑定义，也包括切入点的定义。 |
| AOP代理（AOP Proxy） | AOP 框架创建的对象，以目标对象为基础，织入了通知逻辑代理主要包括动态代理、字节码增强两种类型 |

### Join Points

JointPoint 就是程序运行时的一些连接点。在连接点可以插入切面功能代码。**构造方法调用、调用方法、方法执行、异常、设置一个变量，或者读取一个变量等等**，这些都是 Join Points

AspectJ 中具体的连接点表现为：

Join Points | 说明 | 语法
---|---|---
method call | 函数调用 | execution(方法签名)
method execution|函数执行|call(方法签名)
constructor call|构造函数调用|call(构造器签名)
constructor execution|构造函数执行|execution(构造器签名)
field get|获取某个变量|get(字段签名)
field set|设置某个变量|set(字段签名)
static initialization|类初始化，包括静态成员初始化部分|staticinitialization(类型签名)
initialization|对象初始化，在构造器中的对象初始化。包含：从一个父构造器返回，到当前构造器执行完成的部分（不包括调用父构造器的部分）|initialization(构造器签名)
pre-initialization|对象预初始化，在构造器中的对象初始化之前：从当前构造器调用，到父构造器调用结束为止|preinitialization(构造器签名)
handler|异常处理|handler(类型签名)
advice execution|通知的执行：环绕某个通知的整个执行。可以对通知进行通知|adviceexecution()

注意 call 和 execution 的区别：

1. method call 是调用某个函数的地方。而 execution 是某个函数执行的内部。
2. call 捕获的 JoinPoint 是签名方法的调用点，而 execution 捕获的则是执行点

```java
// call
call(before)
Pointcut{
    pointcut method
}
Call(after)

// execution
Pointcut{
    execution(before)
    pointcut method
    execution(after)
}
```

### Pointcuts(切入点)

不是所有类型的JointPoint都是我们关注的。Pointcuts的目标是提供一种方法使得开发者能够选择自己感兴趣的JoinPoints。

pointcut选择基于正则的语法，Pointcuts的主要类型有：

- Methods and Constructors
  - `call(Signature)`: 方法和构造函数的调用点
  - `execution(Signature)`: 方法和构造函数的执行点
- Fields
  - `get(Signature)`: 属性的读操作
  - `set(Signature)`: 属性的写操作
- Exception Handlers
  - 异常处理执行
- Advice
  - `adviceexecution()`: Advice执行
- Initialization
  - `staticinitialization(TypePattern)`    : 类初始化
  - `initialization(Signature)`: 对象初始化
  - `preinitialization(Signature)`: 对象预先初始化
- Lexical
  - `within(TypePattern)`: 捕获在指定类或者方面中的程序体中的所有连接点，包括内部类
  - `withincode(Signature)`: 用于捕获在构造器或者方法中的所有连接点，包括在其中的本地类
- Instanceof checks and context exposure
  - `this(Type or Id)`: 所有Type or id 的实例的执行点，匹配所有的连接点，如方法调用，属性设置
  - `target(Type or Id)`: 配所有的连接点，目标对象为Type或Id
  - `args(Type or Id)`: 参数类型为Type
- Control Flow
  - `cflow(Pointcut)`: 捕获所有的连接点在指定的方法执行中，包括执行方法本身
  - `cflowbelow(Pointcut)`: 捕获所有的连接点在指定的方法执行中，除了执行方法本身
- Conditional
  - `if(Expression)`
- Combination(多Pointcut的逻辑结合操作)
  - `!Pointcut`
  - `Pointcut0 && Pointcut1`
  - `Pointcut0 || Pointcut1`

### Advice

通过 pointcuts 来选择合适的 JointPoin t后，就可以在 JointPoint 处插入的代码，Advice 用于指定在 JPoint 之前还是之后插入代码，具体包括以下具体的 Advice：

- After 包括三个 Advice
  - After：在切入点执行之后执行，不论其结果
  - AfterReturning：在切入点执行成功后执行
  - AfterThrowing：在切入点执行失败后执行
- Before：在切入点前插入代码
- Around：环绕切入点的执行过程，具有修改连接点执行上下文的能力
  - 在连接点之前/之后添加额外的逻辑，例如性能分析
  - 跳过原先逻辑还执行备选的逻辑，例如缓存。只要不调用 `proceed()`，即不执行原有的逻辑
  - 使用 try-catch 包裹原先逻辑，提供异常处理策略，例如事务管理
- AfterRunning: 返回通知, 在方法返回结果之后执行
- AfterThrowing: 异常通知, 在方法抛出异常之后

注意：

- Advice 为 Before 和 After 时，切入方法的参数应该是 JoinPoint
- Advice 为 Around 时，方法参数应该为 ProceedingJoinPoint，ProceedingJoinPoint 继承 JoinPoint，多了 proceed 功能，此时如果我们不调用 proceed 方法，被切入的方法将不会被调用，
- Around 和 After 是不能同时作用在同一个方法上的，会产生重复切入的问题。

---
## 2 Pointcuts语法

Pointcuts 语法支持两种语法：1、完全使用AspectJ 的语言；2、使用纯 Java 语言开发，然后使用 AspectJ 注解。

Pointcuts 语法包括：

- AspectJ 切入点声明语法
- AspectJ 通知定义语法：由通知声明、切入点定义、通知体三部分组成

具体的语法内容：

- 通配符
- 类型签名语法
  - 基于注解的类型签名
  - 基于泛型的类型签名
  - 联合类型签名
- 方法和构造器签名语法
  - 基本方法签名
  - 基于注解的方法签名
- 字段签名语法

### 通配符

通配符 `*` 用于匹配一系列的连接点

### Java语法示例

#### call 和 execution

语法结构：`execution([修饰符] 返回值类型 方法名(参数)［异常模式］)`，其中修饰符和异常模式可选

示例|说明
---|---
`execution(public *.*(..))` | 所有的 public 方法。
`execution(* hello(..))` | 所有的 hello 方法
`execution(String hello(..))` | 所有返回值为 String 的 hello 方法。
`execution(* hello(String))` | 所有参数为 String 类型的 hello
`execution(* hello(String..))` | 至少有一个参数，且第一个参数类型为 String 的 hello 方法
`execution(* com.aspect..*(..))` | 所有 `com.aspect` 包，以及子孙包下的所有方法
`execution(* com..*.*Dao.find*(..))` | com 包下的所有以 Dao 结尾的类的以 find 开头的方法

- call 在切入点匹配的方法的调用点插入代码、execution 在切入点匹配的方法内部插入代码。
- 对于继承类来说，如果它没有覆盖父类的方法，那么 execution 不会匹配子类中没有覆盖父类的方法。比如们有一个类 B 继承于A，但没有覆盖 A 类的 `foo()`，那么对于B的实例的foo()方法，`execution(* B.foo())`将不会被匹配。
- 如果想跟踪连接点的内部代码运行情况可以考虑使用 execution，但如果你只关心连接点的签名，则使用 call。

#### within 和 withincode

- within用于捕获类型，示例`within(HelloAspectDemo)`表示在HelloAspectDemo类中
- withincode用于捕获在构造器或者方法中的所有连接点，用法与 within 类似，`withcode()`接受的 signature 是方法

#### cflow

cflow 获取的是一个控制流程。一般与其他的 pointcut 进行`&&`运算。
