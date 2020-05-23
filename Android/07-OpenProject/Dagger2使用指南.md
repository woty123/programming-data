# Dagger2学习

---
## 1 依赖注入与 Dagger2

Dagger2是一个依赖注入框架，在学习Dagger2前先来了解一下什么是依赖注入。说到依赖注入，首先肯定有一种依赖关系，比如士兵需要使用枪来进行射击训练，这时他肯定需要一把枪，那么怎么样让这个士兵持有一把枪呢？，可以直接 new 啊。

```java
    public class Soldiers {
    
        private HandGun mHandGun;
    
        public Soldiers() {
            mHandGun = new HandGun();
        }
    
        public void fire() {
            mHandGun.shoot();
        }    
    }
```

但是上面这个程序是有问题的，因为 Soldiers 可以使用很多种枪啊，不仅仅是手枪，而且 Soldiers 不是制造手枪的，所以他也不应该知道手枪的创建过程。这时候我们就有了注入之说，提供一个方法，来给 Soldiers 提供枪，而 Soldiers 只需要用枪射击即可。

注入的方式有很多种，比如说 **构造器注入**，**setter注入**，**注解注入**，这里肯定不能使用构造器注入，因为 Soldiers 是可以独立存在，他与枪不是强依赖关系。

```java
    public class Soldiers {
    
        private Gun mGun;
    
        public void setGun(Gun gun) {
            mGun = gun;
        }
    
        public void fire() {
            if (mGun != null)
                mGun.shoot();
        }
    

}
```

其实注入是很好理解的。除此之外，还有的注解注入方式：

```java
    public class Soldiers {
    
        @Inject
        private Gun mGun;        
        
        public void setGun(Gun gun) {
            xxx.inject(this);
        }
    
        public void fire() {
            if (mGun != null)
                mGun.shoot();
        }
    }
```

通过 `@Inject` 实现注入，这样连 setter 都省了。


### Dagger2 简介

Dagger2 是一个完全静态的编译时依赖注入框架，适用于 Java 和 Android。其前身是由 Square 创建的动态注入框架 Dagger。Dagger2 现在由 Google 维护。

依赖注入框架已存在多年，其中包含各种用于配置和注入的 API。为什么重新发明轮子？Dagger2 是第一个基于代码生成技术(APT)实现依赖注入的框架。其指导原则是生成代码，模仿用户可能手写的代码，以确保依赖注入简单、可追溯和高效。旨在解决基于反射的进行依赖注入导致的性能问题。

### 总结

在开发过程中，我们编写各种类并使它们相互协作来完成特定的功能，这样类与类之间肯定存在依赖关系，比如 A 类需要调用 B 类的某个方法或者获取它的某个属性，A 类对象怎么持有 B 类对象的引用呢？展开来讲就是怎么样灵活地处理好类与类之间的引用关系呢？

我们希望类与类之间的关系是松耦合的，对于单个类来讲，要尽量简单，不想知道它依赖的类是怎么创建的，对多个类来讲，希望尽量降低相互之间的耦合，手动维护这些可能是非常繁琐的，于是便有了类似 Dagger2 这样依赖注入的框架。

我们把对象的控制（创建与注入）较给 Dagger2 容器，容器中存储了众多我们需要的对象，然后我们就无需再手动在代码中创建对象。需要什么对象就直接告诉容器，容器会将对象以一定的方式注入到我们的代码中。除此之外，容器还提供了对象的生命周期的管理的特性。大大简化了我们的编码工作。

---
## 2 Dagger2 注解

首先来了解一下 Dagger2 中的注解，下面部分注解属于 Java 依赖注入标准（JSR-330）：

| 名称  | 作用  |
| ------------ | ------------ |
|`@Inject`|该注入有两个作用： <br/> 1. 通常在需要依赖的地方使用这个注解，比如给一个字段加上 `@Inject` 注解，就表示该字段将由容器提供注入 。<br/> 2. 该注解标注在构造函数上，表示该类的的对象是可以由 Dagger 创建并注入给需要该依赖的对象。|
`@Module`| Modules 类里面的方法用于提供依赖，定义一个类，用 `@Module` 注解，这样 Dagger 在构造类的实例的时候，就知道从哪里去找到需要的依赖。|
|`@Provide`|在 Modules 中定义的方法，需要加上这个注解，Dagger 将从这些方法中创建依赖。否则 Modules 中定义的方法就只是一个普通方法。|
|`@Component`|标注一个接口或抽象类，对于该接口或抽象类，要从一组 Module 中生成完整的依赖注入实现。|
|`@Scope`|Dagger2 可以通过自定义注解限定注解作用域，与注入对象的生命周期有关。|
|`@Named`|当同一个注入器有多个返回相同类型的方法时，使用 `@Named` 来区分不同依赖的注入。|
|`@Qualifier`|与 Named 相似，当类的类型不足以鉴别一个依赖的时候，我们就可以使用这个注解进行标示，它比 Named 更加强大。|


基本的使用规则：

- Module 上必须使用 `@Module` 注解，注明本类属于 Module，Module 里想要提供依赖的方法必须使用 `@Provides` 注解，注明该方法是用来提供依赖对象的特殊方法。
- Component 上必须使用 `@Component` 注解， 指明 Component 在哪些 Module 中查找依赖，Component 必须声明为接口，最后提供注入方法。
- 如果在依赖者中使用 `@Inject` 声明了需要 Dagger 为其注入依赖，用来注入的 Component 又提供对此依赖者进行注入的方法，Component 无法从它绑定的 Module 中找到依赖者所需的依赖（即从 Module 中标注了 `@Providers` 注解的方法中找），则编译无法通过。

主要概念：

- 依赖者：需要被注入依赖的对象，比如 Android 中的 Activity/Fragment 依赖 Presenter 或 ViwModel。
- 依赖：被依赖者依赖的对象，比如 Presenter 或者 ViewModel，依赖同时也可以是依赖者。
- 容器：容器是一个抽象的概念，它存储了依赖者需要的对象。被 `@Component` 标注的接口或抽象类，Dagger 根据其绑定的一组 Module 生成完整的依赖注入实现。

编写好代码之后，使用AndroidStudio的`make app`命令，即可生成代码，比如为定义的 Component 生成具体实现，其名称为：DaggerYourComponentName

### Dagger 示例

```java
    //使用 @Module 来声明一个 Module
    @dagger.Module
    public class PeopleModule {

        //被 @Provides 标准的方法可以提供该方法返回类型的依赖。
        @Provides
        People getPeople() {
            return new ChinesePeople();
        }
    }

    //使用 @Component 来声明一个注入容器，Dagger2 将为我们生成具体的实现，其名称是 DaggerPeopleComponent。
    @Component(modules = {PeopleModule.class})//指定在哪些module中查找依赖
    public interface PeopleComponent {

        ///定义这样的一个方法，返回类型为 void，且只有一个参数，表示 Dagger2 要为才参数类型的实例提供依赖注入。
        void inject(DaggerFragment daggerFragment);
    }

    //使用依赖注入的容器
    public class DaggerFragment extends Fragment {

        //在依赖者中，使用 @Inject 标注一个字段，表示希望该字段由 Dagger2 提供注入。
        @Inject
        People mPeople

         @Override
        public void onCreate(@Nullable Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            //Dagger2 为我们生成了注入容器 DaggerPeopleComponent，然后调用 inject 方法来进行依赖注入。
            DaggerPeopleComponent.builder().build().inject(this);
        }

        @OnClick(R.id.frag_dagger_people_btn)
        public void showPeople(View view) {
            mPeople.showInfo();
         }
    }
```

实例中：

- PeopleModule 可以提供 People 类型的依赖
- PeopleComponent 绑定了 PeopleModule，并声明了要为 DaggerFragment 提供依赖注入
- DaggerFragment 中的 People 字段需要被容器注入，而 PeopleComponent 绑定的 PeopleModule 正好可以提供 People 类型的依赖

这写要素缺一不可。

---
## 3 Dagger2 注入规则

### 如果 Providers 方法需要参数

Module中`@Provides`方法可以带输入参数，这个参数可以有以下方式提供：

- 1：其参数由Module集合中的其他`@Provides`方法提供
```java
    //在module中
    @providers
    ObjectA objcetA(ObjectB b){
       return new ObjectA(b);
    }

    @providers
    ObjectB objcetA(){
       return new ObjectB();
    }
```
- 2：如果Module集合中的其他`@Provides`方法没有提供，但是所依赖的参数类型有带`@Inject`注解的构造方法，而自动调用它的构造方法创建。
- 3：如果都没有的话，只能显式的提供方法所需要的参数

**注意是 Module 集合而不是单个 Module，因为 component 可以指定多个 Module**，也就是说多个 Module 可以互补。

### 添加多个 Module 与 Module 实例的创建

一个Component可以包含多个Module，这样Component获取依赖时候会自动从多个Module中查找获取，Module间不能有重复方法。添加多个Module有两种方法：

- 1：直接在Component上指定

```java
    @Component(modules={ModuleA.class,ModuleB.class,ModuleC.class}) //添加多个Module
    public interface XXComponent{
        ...
    }
```

- 2：在一个新的module中，include多个子module

```java
         @Module(includes={ModuleA.class,ModuleB.class,ModuleC.class})
         public class XXModule{
             ...
         }
```

Component的创建有两种方法:

- 1 直接调用 create 方法：`DaggerXXX.create();`。其 等价于 `DaggerXXX.builder().build();`，但是使用这种方式是有条件的：
    - Component 绑定到的 Module 中的标注了 `@providers` 的方法都是静态的。
    - Component 绑定到的 Module 中的标注了 `@providers` 的方法不是是静态的。但是它们都有默认的构造函数。
- 2 利用 builder 模式，可以传入特定的 module，而且以下情况下，必须使用buidler模式传入。
    - 当 Component 需要的 module 没有无参的构造方法时。此时 Dagger2 无法自动创建该 Module 实例。

```java
        mPeopleComponent = DaggerPeopleComponent.builder()
                    .peopleModule(new PeopleModule(
                            new NameFactory()
                    )).build();
```

### 用 Named 或 Qualifie r来区分返回类型相同的 `@Provides` 方法

如果 Component 指定的 Module 集合中有多个返回相同类型的 `@Providers` 方法，则需要使用 Named 或 Qualifier 来对这些方法进行区分：

#### Named

```java
    //Module中
          @Named("A")
          @Provides
          People getPeople() {
             return new ChinesePeople();
          }
          @Named("B")
          @Provides
          People getPeopleB() {
          return new JapanPeople();
          }

    //容器中
             @Named("A")
             @Inject
             People mPeople;

    //对于容器中mPeople调用使用了相同@Named的注解的Provides方法来创建依赖。
```

#### Qualifier

Qualifier更加强大，允许我们自定义，注意格式

```java
    //实现一个用int类型区分的IntPeopleNamed
    @Qualifier//元注解
    @Documented//规范要求
    @Retention(RetentionPolicy.RUNTIME)//规范要求
    public @interface IntPeopleNamed {
        int value();
    }

    //然后再Module中使用
       @IntPeopleNamed(1)
        @Provides
        People getPeople() {
            return new ChinesePeople(mNameFactory.createName(), mRandom.nextInt(100));
        }

        @IntPeopleNamed(2)
        @Provides
        People getPeopleB() {
            return new ChinesePeople(mNameFactory.createName(), mRandom.nextInt(100));
        }

    //在容器中定义区分
        @IntPeopleNamed(1)
        @Inject
        People mPeople;
        @IntPeopleNamed(2)
        @Inject
        People mPeopleB;
```

### Component 中方法定义规则

#### 1 Component 一般定义一个方法，用来提供注入，必须有需要注入的容器作为参数

```java
    @Component(modules = {PeopleModule.class})
    public interface PeopleComponent {
        void inject(DaggerFragment daggerFragment);
    }
```

#### 2 如果 Component 中定义了没有参数的方法，则方法必须有返回值

Component也可以代替Module中的`@Provides`方法来提供依赖，而不需要`@Provides`注解，对于Component中方法的返回值，需要在指定的Moudle集合中提供返回这个类型的`@Provides`方法。但是如果返回值的类型有带有inject注解的构造函数，则会调用这个构造函数返回对象,这时指定的Moudle集合中可以没有返回这个类型值的`@Provides`方法。

#### 3 Component 可以依赖另一个 Component

- 如果 ComponentA 依赖于 ComponentB，ComponentB 中必须定义带返回值的方法来提供 ComponentA 缺少的依赖，也就是说 ComponentB 要显式提供 ComponentA 中缺少的依赖，则必须声明依赖类型返回值的方法。

```java
      //假如PeopleComponent中缺少对String的依赖
        @Component(dependencies = JapanComponent.class ,modules = PeopleModule.class)
        public interface PeopleComponent {
            void inject(DaggerFragment daggerFragment);
        }

        //JapanModule有返回String的@Provides方法，如果JapanComponent要提供依赖给PeopleComponent，则在JapanComponent中必须暴露方法提供依赖
        @Component(modules = JapanModule.class)
        public interface JapanComponent {
            String getName();
        }
```

这时也只能用 Builder 的方式构造依赖注入器了：

```java
     DaggerPeopleComponent.builder()
            .japanComponent(new JapanComponent())
            .activityModule(new ActivityModule())
            .build();
```

需要注意的是：**有依赖关系的 Component 不能使用相同的 Scope**


---
## 4 关于 Inject 注解

在需要注入依赖的地方使用 `@Inject` 注解，有三种 inject 方式：constructor、field、method injection。

### constructor

1.  在类的 Constructor 加上 `@Inject` 注解，表示该类的的对象是可以由 Dagger 创建并注入给需要该依赖的对象。（这里是提供依赖）
2.  但是类的 Constructor 上的参数（依赖）需要由注入容器提供。（这里是需要依赖）
3.  injection 发生在对象创建时。

### Method(在 Android 中没有用到)

1.  在 methods 上加上 `@Inject`。
2.  表示 method 的参数需要 dependency。
3.  injection 发生在对象被完全建立之后。

### Field

1.  在 fields上加上 `@Inject`。
2.  field不 能为 private 或是 final，至少是缺省的访问权限。
3.  injection 发生在对象完全建立之后。

---
## 5 Scope 控制注入对象的声明周期

首先要明白 Scope 的作用范围是绑定在一个 Component 实例上的。

创建某些对象有时候是耗时浪费资源或者没有完全必要的，比如说我们的Android中，有很多的东西是全局的比如：

```java
      Context//全局的上下文：ApplicationContext
      ThreadExecutor threadExecutor();//全局的子线程调度器
      PostExecutionThread postExecutionThread();//全局主线程转发器
```

而这些全局的对象需要在多个地方实现注入，ActivitA，ActivitB，FragmentA......等，但是Dagger2默认是对于每一次注入都会创建一些新的依赖对象，这时如果要控制依赖对象的创建，可以使用Scope：

### step 1

在Application中初始化一个全局的注入器ApplicationComponent，暴露方法提供ApplicationComponent给其他模块。

```java
    public class AppContext extends Application {
        private static AppContext appContext;
        private AppComponent mAppComponent;
        @Override
        public void onCreate() {
            super.onCreate();
            appContext = this;
            mAppComponent = DaggerAppComponent.create();
        }
        public static AppContext get() {
            return appContext;
        }
        public AppComponent getAppComponent() {
            return mAppComponent;
        }
    }
```

### step 2

给ApplicationComponent定义一个语义上的全局Scope

```java
    @Scope
    @Documented
    @Retention(RetentionPolicy.RUNTIME)
    public @interface AppScope {
    }
```

### step 3

使用AppScope

- 第一步在AppComponent使用@AppScope注解

```java
    //在AppComponent使用@AppScope注解
    @AppScope
    @Component(modules = AppModule.class)
    public interface AppComponent {
        void inject(BaseActivity activity);
    }
```

- 在被注入的依赖上使用，这里由分为两种方式：

直接在需要注入的类上声明scope注解

```java
    @AppScope
    public class JobExecutor implements Executor{
        @Inject
        public JobExecutor() {
        }
        public void exe(Runnable runnable) {
           //......
        }
    }
```

在Module中的 `@provides` 方法上使用

```java
    @Module
    public class AppModule {

        @Provides
        @AppScope
        Job jobExecutor(JobExecutor jobExecutor) {
            return  jobExecutor;
        }
    }
```

### step 4

使用AppContenxt获取全局的依赖注入器，进行注入

```java
    public class BaseActivity extends AppCompatActivity {
        @Inject
        Executor mJobExecutor;
        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            AppContext.get().getAppComponent().inject(this);
        }
    }
```

这样虽然每个继承了BaseActivity的子Activity都会调用到BaseActivity的onCreate方法，注入Executor对象，但是由于在使用了Scope注解，所以对于同一个Component实例多次注入只会生成一个依赖对象，那么是不是所注入的依赖对象的生命周期是不是与它的Component实例一样呢。应该就是这样的

### 对 scope 的理解

同一个component实例中，对于提供的依赖，如果使用了scope注解，则这个依赖只会被生成一次，这个提供的依赖的生命周期与component保存一致，以后每次使用这个component进行注入，都只会返回同一个依赖对象，而没有使用scope的，则使用同一个component注入的话，每一次注入都会生成新的依赖。

至于 Singleton
```java
    @Scope
    @Documented
    @Retention(RUNTIME)
    public @interface Singleton {}
```

它与我们定义的AppScope没有两样，所以名称只是语义上的区别而已，允许我们自定以scope只是为了在名称上区分各种依赖的声明周期，比如ActivityScope，FragmentScope等等，而不管是什么样名称的scope，它们作用就是让依赖于注入器的生命周期保持一致。

我们可以利用全局的component实现单例，但是这个单利只是用起来像单例，并不是真正的单例，对象保存在全局的component中，而不是静态区中。

---
## 6 Subcomponent

一个项目往往是比较复杂的，可以分为多个模块，可能每个模块的组件都有各自的依赖，有些依赖是全局公用的，有些依赖又是模块内私有的，这就需要定义多个 Component 了，同时不同的 Component 之间可能还存在交互，比如某个模块的 Component 依赖全局的 Component，有两种方式可让 Component 之间进行交互：

- 一种办法是使用 Component 上的 dependencies 属性：`Component(dependencies=××.classs)`，上面已经介绍。
- 另外一种是使用 `@Subcomponent` ，Subcomponent 用于拓展原有 Component。让不同 Component 之间有了父子关系，一般是子 Component 依赖父 Component。

### Subcomponent 的特点

- 通过 Subcomponent 功能，子 Component 可以直接使用父 Component 中提供的依赖，而父 Component 中不再需要定义返回相关依赖类型的方法，只需要声明返回子 Component 的方法。
- 通过 Subcomponent 功能，子 Component 同时拥有两种 Scope，当注入的元素来自父Component，则这些元素的生命周期由父 Component 决定，当注入的元素来自子 Component，则这些元素的生命周期由子 Component 决定。

### 从 ParentComponent 获取 ChildComponent 的两种方式

- 1 直接在 ParentComponent 中定义返回 ChildComponent 的方法

```java
//1 定义子 Component
    @SubScrope
    @Subcomponent(modules=××××)
    public SubComponent{ void inject(SomeActivity activity); }

//2 父 Component 中声明返回子Component
    @ParentScrope
    @Component(modules=××××)
    public interface ParentComponent{
         //如果ChildComponent需要显式地添加Module时，定义在方法参数中
         ChildComponent getChildComponent(ChildModule childModule);
    }

//3 使用
    AppContext.getParentComponent()
        .getChildComponent(new ChildModule())
        .inject(this);
```

- 2 使用 Builder 模式

```java
//ChildComponent Component 声明
    @Subcomponent(modules = RequestModule.class)
    interface RequestComponent {

      RequestHandler requestHandler();

      @Subcomponent.Builder
      interface Builder {
        Builder requestModule(RequestModule module);
        RequestComponent build();
      }

    }

//ParentComponent 返回 ChildComponent 的 Builder
    public interface ParentComponent{
        ChildComponent.Builder getChildComponentBuilder();
    }
```

---
## 7 Reusable 和 CanReleaseReferences

- `@Reusable`也是一种Scrope注解，Reusable表示可重用的，`@Reusable`注解返回的对象绑定可能是(但也可能不是)重用，其可用于限制规定类型返回的数量。

- `@CanReleaseReferences`表示可以被释放引用的，配合ForReleasableReferences和ReleasableReferenceManager使用，用于优化内存

---
## 8  Lazy 与 Provider

Lazy 和 Provider 都是用于包装 Container 中需要被注入的类型，Lazy 用于延迟加载，Provide 用于强制重新加载：

```java
    public class Container{
        @Inject Lazy<PeopleA> mPeopleA; //注入Lazy元素
        @Inject Provider<PeopleB> mPeopleB; //注入Provider元素
        public void init(){
            DaggerComponent.create().inject(this);
            PeopleA pA=mPeopleA.get();  //在这时才创建f1,以后每次调用get会得到同一个f1对象
            PeopleB pB=mPeopleB.get(); //在这时创建f2，以后每次调用get会再强制调用Module的Provides方法一次，根据Provides方法具体实现的不同，可能返回跟f2是同一个对象，也可能不是。
        }
    }
```

值得注意的是：

- Dagger2 只有在真正实施注入时才会为依赖者创建需并注入需要的对象，可以认为这已经是懒加载了，在这个基础上 Dagger2 还提供的 Lazy 注解用于延迟加载。可以认为这是二级懒加载。
- Provider 保证每次重新加载，但是并不意味着每次返回的对象都是不同的。只有 Module 的 Provide 方法每次都创建新实例时，Provider 每次 `get()` 的对象才不相同。

---
## 9 Multibindings

Dagger 允许将多个对象绑定到集合中，即使使用 mutlbindings 将对象绑定到不同的模块中也是如此。Dagger 组合集合，以便应用程序代码可以注入它而不依赖于单独的绑定。可以使用多绑定来实现插件架构，Multibindings 分为 set 和 map。

### 9.1 Set multibindings

关键注解：`@IntoSet, @ElementsIntoSet`

定义 Module

```java
    @Module
    class MyModuleA {
      @Provides
      @IntoSet//此时ABC将作为Set的元素返回
      static String provideOneString(DepA depA, DepB depB) {
        return "ABC";
      }
    }

    @Module
    class MyModuleB {
      @Provides
      @ElementsIntoSet//此时Set<String>将被添加到新的Set中返回
      static Set<String> provideSomeStrings(DepA depA, DepB depB) {
        return new HashSet<String>(Arrays.asList("DEF", "GHI"));
      }
    }
```

绑定这两个Module来注入Set：

```java
    class Bar {
      @Inject Bar(Set<String> strings) {
        assert strings.contains("ABC");
        assert strings.contains("DEF");
        assert strings.contains("GHI");
      }
    }
```

### 9.2 Map multibindings

关键注解：`@MapKey, @IntoMap, @LongKey, @StringKey`等等

Map multibindings 支持以下绑定方式：

- 注入Map
- 自定义MapKey
- 使用复合的Key，配合`@AutoAnnotation`自动生成符合Key
- Inherited subcomponent multibindings

关于 multibindings 以及相关拓展，可以参考：

- [multibindings 文档](https://google.github.io/dagger/multibindings)
- [Activities Subcomponents Multibinding in Dagger 2](http://frogermcs.github.io/activities-multibinding-in-dagger-2/)
- [Dagger2Recipes-ActivitiesMultibinding](https://github.com/frogermcs/Dagger2Recipes-ActivitiesMultibinding)

### 注意

Lazy 和 Provider 注解同样适用于 multibinding。下面两种方式都是可以的。

```java
    @Inject
    Map<String, MapValue> mMapValueMap;

     @Inject
    Map<String, Provider<MapValue>> mMapValueMap;
```

---
## 10 Dagger For Android

**Dagger Android** 是基于 Dagger2 对 Android 平台的提供的扩展。提供了非常简单的方式来对安卓组件（Android 四大组件以及 Fragmengt）进行注入。可以让我们减少很多模板代码的编写。其内部原理是使用的 `Map multibindings`，并且还提供了`ContributesAndroidInjector`注解， 这是一个非常强大的注解，可以为注入目标自动生成 Component 实现， 不过只能用于 Android 中的组件(比如Activity、Service、Fragment等)。

具体如何使用？

1. 参考[官方文档](https://dagger.dev/android)
2. 参考我的[示例代码](../Code/Dagger2AndroidInjection-v2.24/README.md)

---
## 11 注入 Nullable 对象

有时候需要注入的对象是可null的，默认Dagger2对对注入的对象进行检测，如果是null的，则会抛出异常，标注注入的对象可null有两种方式：

### 使用 Nullable

Module 中是使用 `javax.annotation.Nullable` 注解：

```java
@Module
public class ServiceModule {

    @Provides
    @javax.annotation.Nullable
    AddressService provideAddressService(AppRouter appRouter) {
        return appRouter.navigation(AddressService.class);
    }

}
```

在被注入对象中也要标注该注入的对象可 null

```java
public class ShoppingCartRepository   {

    @Inject
    ShoppingCartRepository(ShoppingCartApi shoppingCartApi, @javax.annotation.Nullable AddressService addressService) {
        mShoppingCartApi = shoppingCartApi;
        mAddressService = addressService;
    }
}
```

>如果找不到 `javax.annotation.Nullable`，你可能需要添加依赖：`'com.google.code.findbugs:jsr305:2.0.1'`

### 使用 BindsOptionalOf

BindsOptionalOf 提供注入对象的方法上，表示此注入对象可能不存在，即可能不会被注入。使用方式：

```java
//step 1
@Module
public interface ApiServiceModule {
    @BindsOptionalOf ApiService bindApiServiceOptional();
}

//step 2 针对不同的Feature定义不同的FeatureModule
@Module(includes = ApiServiceModule.class)
public interface Feature1Module {
    @Binds
    Logger bindLogger(Feature1Logger feature1Logger);
}

@Module(includes = ApiServiceModule.class)
public abstract class Feature2Module {

}

//step 3 在被注入对象中使用Optional声明依赖
public class ToBeInjectObj{
    @Inject
    Optional<Foo>

    @Inject
    Optional<Provider<Foo>>

    @Inject
    Optional<Lazy<Foo>>

    @Inject
    Optional<Provider<Lazy<Foo>>>
}
```

Optional支持 `com.google.common.base.Optional` 和 `java.util.Optional`。

具体参考：

- [BindsOptionalOf文档](https://google.github.io/dagger/api/latest/dagger/BindsOptionalOf.html)
- [Avoid Nullable dependencies in Dagger2 with @BindsOptionalOf](https://medium.com/@birajdpatel/avoid-nullable-dependencies-in-dagger2-with-bindsoptionalof-c3ad8a8fde2c)

---
## 12 使用 BindsInstance

标记 Component 构建器或 SubComponent 构建器上的方法，该方法允许将实例绑定到组件中的某种类型。示例：

```java
//定义一个Component，并为其定义一个构建器
@Component(modules = AppModule.class)
interface AppComponent {

  App app();

  @Component.Builder
  interface Builder {

    //在构建器上可以使用BindsInstance来绑定自定义数据，@UserName是自定义的标识
    //然后String类型的userName可以为后面的注入构建所用
    @BindsInstance Builder userName(@UserName String userName);

    AppComponent build();
  }
}

//使用构建器来构建Component，此时可以传入userName
  App app = DaggerAppComponent
      .builder()
      .userName(name)
      .build()
      .app();

  app.run();
```

---
## 13 使用 `@Binds` 注解

`@Binds` 可作为 简单的`@Provider`方法的替代，它标注在抽象的 Module 的抽象方法上。例如：

```java
@Module
public abstract class RandomModule{

    @Binds 
    abstract Random bindRandom(SecureRandom secureRandom);

}
```

具体可以参考官方文档。

---
## 14 Producers

Producers是Dagger2的拓展，原有的注入方式都是同步的，Producers模块提供了异步注入的方式。具体参考[文档](https://google.github.io/dagger/producers)。

---
## 15 泛型支持

泛型可以应用于Dagger2中，在基类中定义泛型，然后在具体的子类确定实际参数类型，Dagger2依然可以提供正确的注入：

```java
//Activity
public abstract class BaseActivity<P extends IPresenter> extends AppCompatActivity{

    @Inject
    protected P mPresenter;

}


public class UserActivity extends BaseActivity<UserPresenter>{
    ...
}

public class UserPresenter implement IPresenter{

    @Inject
    public UserPresenter(){

    }
}
```

---
## 16 Dagger 更新

### 2.17

- Dagger 2.17 的更新可能会引发一些编译错误，官方解释原文为：If you start seeing missing binding errors in this release, check out [this wiki page](https://github.com/google/dagger/wiki/Dagger-2.17-@Binds-bugs) for information on how to debug the issues。

### 2.19

- 关于 dagger-android，`@ActivityKey，@ServiceKey，@FragmentKey` 等已经被废弃，推荐使用 `@ClassKey`。
- Module 中的方法应该同意返回 `AndroidInjector.Factory<?>`，而不再是 `AndroidInjector.Factory<? extends Activity>` 等类型。

---
## 引用

- [Users-Guide](https://google.github.io/dagger/users-guide)
- [API-Reference](https://google.github.io/dagger/api/latest/)
- [dagger-basics](https://developer.android.com/training/dependency-injection/dagger-basics)
- [让你的Daggers保持锋利](https://juejin.im/entry/5b8252d5e51d4538cd22834c)
- [Android常用开源工具（1）-Dagger2入门](http://blog.csdn.net/duo2005duo/article/details/50618171)
- [Android常用开源工具（2）-Dagger2进阶](http://blog.csdn.net/duo2005duo/article/details/50696166)
