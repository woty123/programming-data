# 24-HTTP网络编程与JSON解析

一个好的移动应用，不仅需要有良好的界面和易用的交互体验，也需要具备和外界进行信息交互的能力。**通过网络，信息隔离的客户端与服务端间可以建立一个双向的通信通道，从而实现资源访问、接口数据请求和提交、上传下载文件等操作**。

## 1 Http 网络编程

在通过网络与服务端数据交互时，不可避免地需要用到三个概念：**定位、传输与应用**

- 定位，定义了如何准确地找到网络上的一台或者多台主机（即 IP 地址）；
- 传输，主要负责在找到主机后如何高效且可靠地进行数据通信（即 TCP、UDP 协议）；
- 应用，负责识别双方通信的内容（即 HTTP 协议）。

传输层传输的都是二进制数据，通常我们会使用应用层协议来解析这些数据，移动应用通常使用 HTTP 协议作应用层协议，来封装 HTTP 信息。在编程框架中，一次 HTTP 网络调用通常可以拆解为以下步骤：

1. 创建网络调用实例 client，设置通用请求行为（如超时时间）；
2. 构造 URI，设置请求 header、body；
3. 发起请求, 等待响应；
4. 解码响应的内容。

在 Flutter 中，Http 网络编程的实现方式主要分为三种：

- dart:io 里的 HttpClient 实现
- Dart 原生 http 请求库实现
- 第三方库 dio 实现

## 2 HttpClient

HttpClient 是 dart:io 库中提供的网络请求类，实现了基本的网络编程功能。

使用示例：

```dart
get() async {
  // 创建网络调用示例，设置通用请求行为 (超时时间)
  var httpClient = HttpClient();
  httpClient.idleTimeout = Duration(seconds: 5);
  
  // 构造 URI，设置 user-agent 为 "Custom-UA"
  var uri = Uri.parse("https://flutter.dev");
  var request = await httpClient.getUrl(uri);
  request.headers.add("user-agent", "Custom-UA");
  
  // 发起请求，等待响应
  var response = await request.close();
  
  // 收到响应，打印结果
  if (response.statusCode == HttpStatus.ok) {
    print(await response.transform(utf8.decoder).join());
  } else {
    print('Error: \nHttp status ${response.statusCode}');
  }
}
```

需要注意的是：**由于网络请求是异步行为，因此在 Flutter 中，所有网络编程框架都是以 Future 作为异步请求的包装，所以我们需要使用 await 与 async 进行非阻塞的等待。当然，也可以注册 then，以回调的方式进行相应的事件处理**。

HttpClient 库使用相对简单，但是也存在缺点，其接口却暴露了不少内部实现细节。比如：

- 异步调用拆分得过细
- 链接需要调用方主动关闭
- 请求结果是字符串但却需要手动解码等。

## 3 http 库

http 是 Dart 官方提供的另一个网络请求类，相比于 HttpClient，易用性提升了不少。

首先，在 pubspec 中引入 http 库：

```yaml
dependencies:
  http: '>=0.11.3+12'
```

使用 http 库实现上面请求：

```dart
httpGet() async {
  // 创建网络调用示例
  var client = http.Client();

  // 构造 URI
  var uri = Uri.parse("https://flutter.dev");
  
  // 设置 user-agent 为 "Custom-UA"，随后立即发出请求
  http.Response response = await client.get(uri, headers : {"user-agent" : "Custom-UA"});

  // 打印请求结果
  if(response.statusCode == HttpStatus.ok) {
    print(response.body);
  } else {
    print("Error: ${response.statusCode}");
  }
}
```

可以看到 http 库的使用比较简介，但是其暴露的定制化能力都相对较弱，很多常用的功能都不支持（或者实现异常繁琐），比如：

- 取消请求
- 定制拦截器
- Cookie 管理等

## 4 dio 库

以上两种网络请求方式所暴露的功能相对简单，因此对于复杂的网络请求行为，推荐使用目前在 Dart 社区人气较高的第三方 dio 来发起网络请求。

首先需要把 dio 加到 pubspec 中的依赖里：

```dart
dependencies:
  dio: '>2.1.3'
```

### dio 库的基本使用

使用 dio 库实现上面请求：

```dart
void getRequest() async {
  // 创建网络调用示例
  Dio dio = new Dio();
  
  // 设置 URI 及请求 user-agent 后发起请求
  var response = await dio.get("https://flutter.dev", options:Options(headers: {"user-agent" : "Custom-UA"}));
  
 // 打印请求结果
  if(response.statusCode == HttpStatus.ok) {
    print(response.data.toString());
  } else {
    print("Error: ${response.statusCode}");
  }
}
```

>这里需要注意的是，创建 URI、设置 Header 及发出请求的行为，都是通过 dio.get 方法实现的。这个方法的 options 参数提供了精细化控制网络请求的能力，可以支持设置 Header、超时时间、Cookie、请求方法等。具体参考[dio-apis](https://github.com/flutterchina/dio#dio-apis)

### 使用 dio 上传和下载文件

对于常见的上传及下载文件需求，dio 也提供了良好的支持：文件上传可以通过构建表单 FormData 实现，而文件下载则可以使用 download 方法搞定。

示例代码：

```dart
// 使用 FormData 表单构建待上传文件
FormData formData = FormData.from({
  "file1": UploadFileInfo(File("./file1.txt"), "file1.txt"),
  "file2": UploadFileInfo(File("./file2.txt"), "file1.txt"),
});

// 通过 post 方法发送至服务端
var responseY = await dio.post("https://xxx.com/upload", data: formData);
print(responseY.toString());

// 使用 download 方法下载文件
dio.download("https://xxx.com/file1", "xx1.zip");

// 增加下载进度回调函数
dio.download("https://xxx.com/file1", "xx2.zip", onReceiveProgress: (count, total) {
    //do something
});
```

### 使用 dio 同时等待多个请求

有时，我们的页面由多个并行的请求响应结果构成，这就需要等待这些请求都返回后才能刷新界面。在 dio 中，我们可以结合 Future.wait 方法轻松实现：

```dart
// 同时发起两个并行请求
List<Response> responseX= await Future.wait(
    [dio.get("https://flutter.dev"),
    dio.get("https://pub.dev/packages/dio")]
);

// 打印请求 1 响应结果
print("Response1: ${responseX[0].toString()}");
// 打印请求 2 响应结果
print("Response2: ${responseX[1].toString()}");
```

### dio 拦截器

与 Android 的 okHttp 一样，dio 还提供了请求拦截器，通过拦截器，我们可以在请求之前，或响应之后做一些特殊的操作。比如可以为请求 option 统一增加一个 header，或是返回缓存数据，或是增加本地校验处理等等。

示例代码：

- 为 dio 增加了一个拦截器。在请求发送之前，不仅为每个请求头都加上了自定义的 user-agent，还实现了基本的 token 认证信息检查功能。
- 对于本地已经缓存了请求 uri 资源的场景，直接返回缓存数据，避免再次下载。

```dart
// 增加拦截器
dio.interceptors.add(InterceptorsWrapper(
    onRequest: (RequestOptions options){
      // 为每个请求头都增加 user-agent
      options.headers["user-agent"] = "Custom-UA";
      // 检查是否有 token，没有则直接报错
      if(options.headers['token'] == null) {
        return dio.reject("Error: 请先登录 ");
      }
      // 检查缓存是否有数据
      if(options.uri == Uri.parse('http://xxx.com/file1')) {
        return dio.resolve(" 返回缓存数据 ");
      }
      // 放行请求
      return options;
    }
));

// 增加 try catch，防止请求报错
try {
  var response = await dio.get("https://xxx.com/xxx.zip");
  print(response.data.toString());
}catch(e) {
  print(e);
}
```

需要注意的是：**由于网络通信期间有可能会出现异常（比如，域名无法解析、超时等），因此我们需要使用 try-catch 来捕获这些未知错误，防止程序出现异常**。

## 4 Json 解析

移动应用与 Web 服务器建立好了连接之后，接下来的两个重要工作分别是：

1. 服务器如何结构化地去描述返回的通信信息
2. 移动应用如何解析这些格式化的信息

### 如何结构化地描述返回的通信信息：Json

在如何结构化地去表达信息上，我们需要用到 JSON。JSON 是一种轻量级的、用于表达由属性值和字面量组成对象的数据交换语言。

```json
String jsonString = '''
{
  "id":"123",
  "name":" 张三 ",
  "score" : 95
}
''';
```

**Flutter 不支持自动解析**：由于 Flutter 不支持运行时反射，因此并没有提供像 Gson、Mantle 这样自动解析 JSON 的库来降低解析成本。在 Flutter 中，JSON 解析完全是手动的，开发者要做的事情多了一些，但使用起来倒也相对灵活。

### 如何解析格式化的信息

手动解析，是指使用 dart:convert 库中内置的 JSON 解码器，将 JSON 字符串解析成自定义对象的过程。使用这种方式，我们需要先将 JSON 字符串传递给 JSON.decode 方法解析成一个 Map，然后把这个 Map 传给自定义的类，进行相关属性的赋值。

以解析上面 Student json 数据为例：

1：我们根据 JSON 结构定义 Student 类，并创建一个工厂类，来处理 Student 类属性成员与 JSON 字典对象的值之间的映射关系：‘

```dart
class Student{
  // 属性 id，名字与成绩
  String id;
  String name;
  int score;

  // 构造方法  
  Student({
    this.id,
    this.name,
    this.score
  });

  //JSON 解析工厂类，使用字典数据为对象初始化赋值
  factory Student.fromJson(Map<String, dynamic> parsedJson){
    return Student(
        id: parsedJson['id'],
        name : parsedJson['name'],
        score : parsedJson ['score']
    );
  }

}
```

数据解析类创建好了，只需要把 JSON 文本通过 JSON.decode 方法转换成 Map，然后把它交给 Student 的工厂类 fromJson 方法，即可完成 Student 对象的解析：

```dart
loadStudent() {
  //jsonString 为 JSON 文本
  final jsonResponse = json.decode(jsonString);
  Student student = Student.fromJson(jsonResponse);
  print(student.name);
}
```

如果 JSON 下面还有嵌套对象属性，如何解析？比如下面的例子中，Student 还有一个 teacher 的属性。只需要在字段上再次使用 json.decode 即可：

```dart
class Teacher {
  //Teacher 的名字与年龄
  String name;
  int age;
  // 构造方法
  Teacher({this.name,this.age});
  //JSON 解析工厂类，使用字典数据为对象初始化赋值
  factory Teacher.fromJson(Map<String, dynamic> parsedJson){
    return Teacher(
        name : parsedJson['name'],
        age : parsedJson ['age']
    );
  }
}

class Student{
  ...
  // 增加 teacher 属性
  Teacher teacher;
  // 构造函数增加 teacher
  Student({
    ...
    this.teacher
  });
  factory Student.fromJson(Map<String, dynamic> parsedJson){
    return Student(
        ...
        // 增加映射规则
        teacher: Teacher.fromJson(parsedJson ['teacher'])
    );
  }
}
```

### 使用 compute 解析 json

在主 isolate 中解析 json 数据，如果 JSON 的数据格式比较复杂，数据量又大，这种解析方式可能会造成短期 UI 无法响应。对于这类 CPU 密集型的操作，我们可以使用上一篇文章中提到的 compute 函数，将解析工作放到新的 Isolate 中完成：

```dart
static Student parseStudent(String content) {
  final jsonResponse = json.decode(content);
  Student student = Student.fromJson(jsonResponse);
  return student;
}

doSth() {
 ...
 // 用 compute 函数将 json 解析放到新 Isolate
 compute(parseStudent,jsonString).then((student)=>print(student.teacher.name));
}
```

## 5 总结

1. 掌握 Flutter 应用与服务端通信的三种方式，即 HttpClient、http 与 dio。
2. dio 提供的功能更为强大，可以支持请求拦截、文件上传下载、请求合并等高级能力。推荐在实际项目中使用 dio 的方式。
3. JSON 解析在 Flutter 中相对比较简单，但由于不支持反射，所以我们只能手动解析，即：先将 JSON 字符串转换成 Map，然后再把这个 Map 给到自定义类，进行相关属性的赋值。

扩展，**为什么 dart 不支持反射**：

1. 运行时反射破坏了类的封装性和安全性，会带来安全风险。就在前段时间，Fastjson 框架就爆出了一个巨大的安全漏洞。这个漏洞使得精心构造的字符串文本，可以在反序列化时让服务器执行任意代码，直接导致业务机器被远程控制、内网渗透、窃取敏感信息等操作。
2. 运行时反射会增加二进制文件大小。因为搞不清楚哪些代码可能会在运行时用到，因此使用反射后，会默认使用所有代码构建应用程序，这就导致编译器无法优化编译期间未使用的代码，应用安装包体积无法进一步压缩，这对于自带 Dart 虚拟机的 Flutter 应用程序是难以接受的。

### 扩展：代码生成器

虽然 dart 不支持反射，没有类似 gson 这里的反序列化器，但是可以使用代码生成器，具体参考：

- <https://pub.dartlang.org/packages/json_serializable>
- <https://pub.dev/packages/built_value>

## 6 相关示例

- [24_network_demo](https://github.com/cyndibaby905/24_network_demo)

## 7 思考题

1.请使用 dio 实现一个自定义拦截器，拦截器内检查 header 中的 token：如果没有 token，需要暂停本次请求，同时访问"<http://xxxx.com/token"，在获取新> token 后继续本次请求。

2.为以下 Student JSON 写相应的解析类

```json
String jsonString = '''
  {
    "id":"123",
    "name":" 张三 ",
    "score" : 95,
    "teachers": [
       {
         "name": " 李四 ",
         "age" : 40
       },
       {
         "name": " 王五 ",
         "age" : 45
       }
    ]
  }
  ''';
```
