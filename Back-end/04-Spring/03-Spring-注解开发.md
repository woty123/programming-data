# Spring 注解开发

在 SpringBoot 和 SpringCluod 兴起之后，使用了大量的注解配置，所以掌握 Spring 注解开发非常有必要。

---

## 1 注解方式配置 Spring 容器

### 1.1 IOC

#### 1.1.1 使用注解配置 Spring IOC 容器

`@Configuration`：用于标注一个类是一个配置类。然后构建 AnnotationConfigApplicationContext 时，传入用 Configuration 标注的类即可完成容器构建。

#### 1.1.2 定制包的扫描规则

`@ComponentScan`：用于指定要扫描的包，相关属性如下。

- useDefaultFilters：用于表示是否使用默认的过滤器，默认会注册包下所有用`@Controller/@Service/@Repository/@Component`标注的类
- excludeFilters：指定扫描的时候按照什么规则排除那些组件
- includeFilters：指定扫描的时候只需要包含哪些组件
- FilterType 的类型：
  - FilterType.ASSIGNABLE_TYPE：按照给定的类型
  - FilterType.ASPECTJ：使用ASPECTJ表达式
  - FilterType.REGEX：使用正则指定
  - FilterType.CUSTOM：使用自定义规则，此时可以实现 TypeFilter 实现自定义过滤规则

#### 1.1.3 组件注册

`@Bean` 注解，标识在方法上，用于给容器中注册一个 Bean，类型为返回值的类型，id 默认是用方法名作为 id，可以通过 Bean 的 name 属性指定明确的 bean id。

#### 1.1.4 调整作用域：Scope、Lazy

默认情况下，向容器种注册的 Bean 都是单例的，可以通过 Scope 来修改作用域。Spring 提供了四种作用域：

- prototype：多实例的，ioc容器启动并不会去调用方法创建对象放在容器中。每次获取的时候才会调用方法创建对象。
- singleton：单实例的（默认值），ioc容器启动会调用方法创建对象放到ioc容器中，以后每次获取就是直接从容器中获取。
- request：同一次请求创建一个实例。
- session：同一个 session 创建一个实例。

懒加载：单实例 bean：默认在容器启动的时候创建对象；使用 Layz 注解标注可以实现懒加载，即容器启动不创建对象。第一次使用(获取) Bean 创建对象，并初始化。

#### 1.1.5 条件注册

`@Conditional` 用于实现条件注册，只有满足条件的 Bean 才会注册到容器中。

Conditional 的 value 属性接收 Condition 数组，Condition 用于做实际的条件判断，Conditional 可以标注在方法上，也可以标注在类上。

- 标注在方法上时，只要 Conditional 指定的 Condition 返回 true，Bean 就会注册到容器中。
- 标注在类上时，如果类上标注的 Conditional 所指定的 Condition 返回 false，那么该类中提供的所有 Bean 都不会注册到容器中。

#### 1.1.6 其他注入 Bean 的注解

1. @Import：快速给容器中导入一个组件，Import 接收三种类型的 Class：
   1. 直接指定某个类的 Class，容器中就会自动注册这个组件，id默认是全类名。
   2. 指定实现了 ImportSelector 的类，该类可以返回需要导入的组件的全类名数组。
   3. 指定实现了 ImportBeanDefinitionRegistrar 的类，通过该方式可以手动注册 bean 到容器中。
2. 使用 Spring 提供的 `FactoryBean`（工厂Bean），然后配置 @Bean 使用。如果要从容器容器中获取工厂 Bean 本身，我们需要给 id 前面加一个 &。

#### 1.1.7 生命周期处理

bean 的生命周期包含三个阶段：`bean创建--->初始化---->销毁`。容器管理 bean 的生命周期：我们可以自定义初始化和销毁方法；容器在 bean 进行到当前生命周期的时候来调用我们自定义的初始化和销毁方法。

1. 对象的创建
   1. 单实例：在容器启动的时候创建对象。
   2. 多实例：在每次获取的时候创建对象。
2. 初始化：对象创建完成，相关依赖属性被赋值，调用初始化方法。
3. 销毁：
   1. 单实例：容器关闭的时候。
   2. 多实例：容器不会管理这个 bean，容器不会调用销毁方法。

**指定 Bean 的初始化和销毁方法**：

1. 指定初始化和销毁方法：通过 @Bean 指定 `init-method` 和 `destroy-method`。
2. 通过让 Bean 实现InitializingBean（定义初始化逻辑）、DisposableBean（定义销毁逻辑）。
3. 使用JSR250；
   1. `@PostConstruct`：在 bean 创建完成并且属性赋值完成，来执行初始化方法。
   2. `@PreDestroy`：在容器销毁 bean 之前通知我们进行清理工作。

**Hook bean 的创建**：实现 BeanPostProcessor，然后将其注册到容器中，IOC 容器会识别到它是一个 bean 后置处理器, 并调用其方法对于的方法。

1. BeanPostProcessor.postProcessBeforeInitialization：在 Bean 初始化之前调用。
2. BeanPostProcessor.postProcessAfterInitialization：在 Bean 初始化之后调用。

Spring 会遍历得到容器中所有的 BeanPostProcessor，逐个执行 beforeInitialization，一但返回 null，跳出 for 循环，不会执行后面的 BeanPostProcessor.postProcessorsBeforeInitialization。Spring 底层很多功能都使用了 BeanPostProcessor，比如 bean 的赋值、注入其他组件、`@Autowired`处理，生命周期注解功能，`@Async***BeanPostProcessor`等的处理。

#### 1.1.8 Bean 的属性赋值

`@Value` 用于给 bean 的成员指定初始化值。其可以处理三种类型的参数：

1. 基本数值
2. SpEL`#{}`
3. `${}`；取出配置文件【properties】中的值（在运行环境变量里面的值）

`@PropertySource` 用于配置属性文件，比如配置 `@PropertySource(value={"classpath:/person.properties"})` 的话，person.properties 中 的值将会被添加到运行环境中，可以通过 System.getProperty() 获取。

#### 1.1.9 自动装配：Autowired、Resource、Inject

Spring 利用依赖注入（DI），完成对 IOC 容器中中各个组件的依赖关系赋值，我们可以使用`@Autowired`、`@Resource`、`@Inject` 注解来指定容器中组件之间的依赖关系：

**`@Autowired`** 自动注入：

1. 默认优先按照类型去容器中找对应的组件:`applicationContext.getBean(BookDao.class);`，找到就赋值。
2. 如果找到多个相同类型的组件，再将属性的名称作为组件的 id 去容器中查找 `applicationContext.getBean("bookDao")`。
3. 配合 `@Qualifier("bookDao")` 使用：使用 `@Qualifier` 指定需要装配的组件的 id，而不是使用属性名。
4. 自动装配默认一定要将属性赋值好，没有就会报错，可以使用 `@Autowired(required=false)` 指定为可选属性。
5. `@Primary`：让 Spring 进行自动装配的时候，默认使用首选的 bean，也可以继续使用 `@Qualifier` 指定需要装配的 bean 的名字。
6. Autowired 标注可以标注在参数，方法，属性上：
   1. 对于 Bean 的构造器：如果组件只有一个有参构造器，而容器中有构造器需要的参数类型，那么这个构造器上的 @Autowired 可以省略，参数位置的组件还是可以自动从容器中获取。
   2. 在配置类中使用 @Bean 向容器注册 Bean 时，Bean 所标注的方法也可以声明方法参数，然后使用 Autowired 标注，Spring 就会在容器中找对应类型的 Bean，甚至我们可以不使用 @Autowired 标注参数，Spring 也会能从容器中找到对应类型的参数然后调用注册 Bean 的方法。

**Spring 还支持使用 `@Resource`(JSR250) 和 `@Inject(JSR330)` java 规范的注解**：

- @Resource：可以和 `@Autowired`一样实现自动装配功能，默认是按照组件名称进行装配的，但是没有能支持 `@Primary` 功能，也没有 reqiured 属性。
- @Inject：需要导入 javax.inject 的包，和 Autowired 的功能一样，没有 required 的功能。
- @Autowired 是 Spring 定义的； @Resource、@Inject 都是 java 规范。

**AutowiredAnnotationBeanPostProcessor**：用于解析和完成自动装配，本质上它是一个 BeanPostProcessor 的实现。

#### 1.1.10 自动装配 Spring 底层的组件

自定义组件想要使用 Spring 容器底层的一些组件，比如 ApplicationContext、BeanFactory 等，那么自定义组件可以实现特定类型的 `org.springframework.beans.factory.Aware` 然后注册到容器中，在 Spring 创建对象的时候，会调用接口规定的方法注入相关组件。Spring 提供了很多类型的 Aware：

```java
ApplicationEventPublisherAware (org.springframework.context)
MessageSourceAware (org.springframework.context)
ResourceLoaderAware (org.springframework.context)
NotificationPublisherAware (org.springframework.jmx.export.notification)
EnvironmentAware (org.springframework.context)
BeanFactoryAware (org.springframework.beans.factory)
ImportAware (org.springframework.context.annotation)
EmbeddedValueResolverAware (org.springframework.context)
BootstrapContextAware (org.springframework.jca.context)
LoadTimeWeaverAware (org.springframework.context.weaving)
BeanNameAware (org.springframework.beans.factory)
BeanClassLoaderAware (org.springframework.beans.factory)
ApplicationContextAware (org.springframework.context)
```

#### 1.1.11 Profile 注解

Spring为我们提供的可以根据当前环境，动态的激活和切换一系列组件的功能，比如我们有下面三种开发环境，分别对应着不同的数据源：

- 开发环境：数据源 A
- 测试环境：数据源 B
- 生产环境：数据源 C

我们可以使用 `@Profile` 指定组件在哪个环境的情况下才能被注册到容器中，对于没有用 Profile 指定的组件，则任何环境下都能注册这个组件。

1. 加了环境标识的 bean，只有这个环境被激活的时候才能注册到容器中。默认环境是 `default`。
2. 如果 `@Profile` 标注在配置类上，那么只有是在指定的环境的时候，整个配置类里面的所有配置才能生效。
3. 没有标注环境标识的 bean 在任何环境下都是加载的。

指定环境的方法：

1. 添加虚拟机参数：`-Dspring.profiles.active=test`
2. 在代码中指定：

```java
//1、创建一个applicationContext
AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext();
//2、设置需要激活的环境
applicationContext.getEnvironment().setActiveProfiles("dev");
//3、注册主配置类
applicationContext.register(MainConfigOfProfile.class);
//4、启动刷新容器
applicationContext.refresh();
```

### 1.2 AOP

相关注解：

1. `@EnableAspectJAutoProxy` 用于开启 AOP。
2. `@Before/@After/@AfterReturning/@AfterThrowing/@Around`
3. `@Pointcut`

### 1.3 声明式事务

相关注解：

1. `@EnableTransactionManagement` 用于开启事物
2. `@Transactional`

---

## 2 SpringMVC 与 Servlet3.0 注解开发

SpringMVC 基于 Servle3.0 中引入的 ServletContainerInitializer 提供了注解方式对 Spring 容器进行配置。

SpringWeb jar 包中就配置了一个 `org.springframework.web.SpringServletContainerInitializer`，而其配置的 HandlesTypes 是 WebApplicationInitializer 类型，WebApplicationInitializer 是一个接口，SpringWeb 提供了三个抽象类实现，我们可以选择实现其中的任一个来进行配置：

1. AbstractContextLoaderInitializer，其主要功能是：
   1. 创建根容器；`createRootApplicationContext();`
2. AbstractDispatcherServletInitializer，其主要功能是：
   1. 创建一个 web 的 ioc 容器：`createServletApplicationContext();`
   2. 创建 DispatcherServlet：`createDispatcherServlet();`，然后将创建的 DispatcherServlet 添加到 ServletContext 中；我们可以实现抽象方法 `getServletMappings()` 对 DispatcherServlet 的映射路径进行配置。
3. AbstractAnnotationConfigDispatcherServletInitializer：注解方式配置的 DispatcherServlet 初始化器，其主要功能是：
      创建根容器：`createRootApplicationContext()`，我们可以实现抽象方法 `getRootConfigClasses()` 传入一个根容器配置类。
      创建 web 的 ioc 容器：`createServletApplicationContext()`，我们可以实现抽象方法 `getServletConfigClasses()` 传入一个 Web 容器的配置类。

所以，如果要以注解方式来启动 SpringMVC；则继承 AbstractAnnotationConfigDispatcherServletInitializer，然后实现抽象方法指定DispatcherServlet 的配置信息。

---

## 3 Spring 注解配置原理分析

- [ ] todo

---

## 4 参考

以上笔记来自对 [尚硅谷JavaEE](http://www.atguigu.com/download.shtml#javaEE) 课程 **Spring注解开发** 部分的学习。
