# OkHttp(3.4)

---
## 1 okhttp 核心类介绍

OkHttpClient 客户端类，相当于配置中⼼心，所有的请求都会共享这些配置（例如出错是否重试、共享的连接池）。OkHttpClient中的配置主要有：

- `Dispatcher dispatcher`：度器器，⽤于调度后台发起的网络请求，有后台总请求数和单主机总请求数的控制。
- `List<Protocol> protocols`：支持的应用层协议，即 HTTP/1.1、HTTP/2 等。
- `List<ConnectionSpec> connectionSpecs`：连接规格，应⽤层⽀持的 Socket 设置，即使用明⽂文传输（⽤于 HTTP）还是某个版本的 TLS（用于 HTTPS）。
- `List<Interceptor> interceptors`：配置的拦截器，⼤多数时候使⽤的 Interceptor 都应该配置到这。
- `List<Interceptor> networkInterceptors`：直接和⽹络请求交互的 Interceptor 配置到这里，例如果你想查看返回的 301 报⽂文或者未解压的 Response Body，需要在这里看。interceptors 和 networkInterceptors 的本质区别就是在拦截器链中的位置不一致。
- `CookieJar cookieJar`：管理 Cookie 的控制器。OkHttp 提供了 Cookie 存取的判断支持（即什么时候需要存 Cookie，什么时候需要读取 Cookie，但没有给出具体的存取实现。如果需要存取 Cookie，我们需要⾃⼰写实现。
- `Cache cache`：Cache 存储的配置。默认是没有，如果需要用，需要⾃己配置出 Cache 存储的文件位置以及存储空间上限。
- `HostnameVerifier hostnameVerifier`：⽤于验证 HTTPS 握手过程中下载到的证书所属者是否和⾃己要访问的主机名一致。
- `CertificatePinner certificatePinner`：翻译为证书固定者，⽤于设置 HTTPS 握手过程中针对某个 Host 的 Certificate Public Key Pinner，即把⽹网站证书链中的每一个证书公钥直接拿来提前配置进 OkHttpClient ⾥去，以跳过本地根证书，直接从代码里进行认证。这种⽤法⽐较少见，⼀般⽤用于防止网站证书被⼈仿制。
- `Authenticator authenticator`：⽤于⾃动重新认证。配置之后，在请求收到 401 状态码的响应时，会直接调用 authenticator，⼿动加入Authorization header 之后自动重新发起请求。
- `boolean followRedirects`：遇到重定向的要求时，是否自动 follow。
- `boolean followSslRedirects`：在重定向时，如果原先请求的是 http ⽽重定向的目标是 https，或者原先请求的是 https 而重定向的目标是 http，是否依然⾃动 follow。
- `boolean retryOnConnectionFailure`：在请求失败的时候是否⾃动重试。注意，⼤多数的请求失败并不属于 OkHttp 所定义的「需要重试」，这种重试只适⽤于「同一个域名的多个 IP 切换重试」「Socket 失效重试」等情况。
- `int connectTimeout`：建立连接（TCP 或 TLS）的超时时间。
- `int readTimeout`：发起请求到读到响应数据的超时时间。
- `int writeTimeout`：发起请求并被目标服务器接受的超时时间。（为什什么？因为有时候对方服务器可能由于某种原因而不读取你的 Request）
- `ConnectionPool connectionPool`：连接池复用、回收算法

---
## 2 okhttp 同步与异步请求方法流程分析

### 请求方式

```java
//异步
OkHttpClient okHttpClient = new OkHttpClient();
        okHttpClient.newCall(new Request.Builder().url("https://baidu.com").build())
                .enqueue(new Callback() {
                    @Override
                    public void onFailure(Call call, IOException e) {
                        System.out.println(e);
                    }

                    @Override
                    public void onResponse(Call call, Response response) throws IOException {
                        if (response.isSuccessful()) {
                            System.out.println(response.body().string());
                        } else {
                            System.out.println("fail");
                        }
                    }
                });

//同步
 OkHttpClient okHttpClient = new OkHttpClient();
        try {
            Response response = okHttpClient.newCall(new Request.Builder().url("https://baidu.com").build()).execute();
            if (response.isSuccessful()) {
                System.out.println(response.body().string());
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
```

### 请求流程

![](index_files/0b04243a-0fb9-42f7-9ff7-9d28ad444f23.png)

同步请求处理方法：

```java
 public Response execute() throws IOException {
        synchronized (this) {
            //只能被执行一次
            if (executed) {
                throw new IllegalStateException("Already Executed");
            }
            executed = true;
        }
        try {
            //获取 dispatcher 调度类，加入到执行队列
            client.dispatcher().executed(this);
            //通过连接器链获取执行结果
            Response result = getResponseWithInterceptorChain(false);
            if (result == null) {
                throw new IOException("Canceled");
            }
            return result;
        } finally {
            //一个Call完成，不论是失败还是成功，都要调用dispatcher的finished方法
            client.dispatcher().finished(this);
        }
    }
```

异步请求处理：

```java
    /*异步执行*/
    void enqueue(Callback responseCallback, boolean forWebSocket) {
        synchronized (this) {
            if (executed) {
                throw new IllegalStateException("Already Executed");
            }
            executed = true;
        }
        //加入到dispatcher的队列中
        client.dispatcher().enqueue(new AsyncCall(responseCallback, forWebSocket));
    }
```

## 3 核心 Dispatcher 调度器

### Dispatcher 的职责

- 同步和异步请求都会在 Dispatchtor 中管理其状态
- Dispatcher 的作用为维护请求的状态，并维护一个线程池，用于执行请求

### Dispatcher 的队列

```java
 private final Deque<AsyncCall> readyAsyncCalls = new ArrayDeque<>();//等待执行的异步请求队列。
 private final Deque<AsyncCall> runningAsyncCalls = new ArrayDeque<>();//正在执行的异步请求，包括取消了但还没完成Call。
 private final Deque<RealCall> runningSyncCalls = new ArrayDeque<>();//正在执行的同步请求。
```

- 两个队列，同步与异步
- 为什么需要两个队列：生产者消费者模型

控制最大并发数：

```java
    /*限制最大的请求数量为 64*/
    private int maxRequests = 64;
    /*同一个主机只能同时有 5 个请求*/
    private int maxRequestsPerHost = 5;
```

### 执行结果处理

任何一个请求执行完毕后，需要移除出队列，并调整现有任务调度

```java
    synchronized void finished(AsyncCall call) {
        if (!runningAsyncCalls.remove(call)) {
            throw new AssertionError("AsyncCall wasn't running!");
        }
        promoteCalls();
    }

   /**
     * 非常重要的方法，当一个Call被执行完成后，需要调用此方法把对应的Call移除出对象，然后检测须有需要将等待队列中的Call加入到执行队列中去。
     * 该方法在 synchronized 方法的中调用。
     */
    private void promoteCalls() {
        if (runningAsyncCalls.size() >= maxRequests) {
            return; // Already running max capacity.
        }
        if (readyAsyncCalls.isEmpty()) {
            return; // No ready calls to promote.
        }

        for (Iterator<AsyncCall> i = readyAsyncCalls.iterator(); i.hasNext(); ) {

            AsyncCall call = i.next();

            if (runningCallsForHost(call) < maxRequestsPerHost) {
                i.remove();
                runningAsyncCalls.add(call);
                executorService().execute(call);
            }

            if (runningAsyncCalls.size() >= maxRequests) {
                return; // Reached max capacity.
            }
        }
    }
```

---
## 4 拦截器

### 拦截器的作用

拦截器是 OkHttp 中提供的一种强大的机制，它可以实现网络监听、请求以及响应重写、请求失败重试等功能，OkHttp中的拦截器分为两类：

- 应用拦截器
- 网络连接器

同时OkHttp内置了很多用于实现Http核心功能的拦截器

### 拦截器链

OkHttp 在执行请求时，由多个拦截器组成的拦截器链处理，参考下面代码:

```java
   //由Call调用，用于获取请求结果
  private Response getResponseWithInterceptorChain() throws IOException {
    // Build a full stack of interceptors.
    List<Interceptor> interceptors = new ArrayList<>();
    //用户添加的 Interceptor
    interceptors.addAll(client.interceptors());
    //重试和重定向
    interceptors.add(retryAndFollowUpInterceptor);

    interceptors.add(new BridgeInterceptor(client.cookieJar()));
    //缓存拦截器
    interceptors.add(new CacheInterceptor(client.internalCache()));
    //拦截拦截器
    interceptors.add(new ConnectInterceptor(client));

    if (!retryAndFollowUpInterceptor.isForWebSocket()) {
      interceptors.addAll(client.networkInterceptors());
    }

    interceptors.add(new CallServerInterceptor(retryAndFollowUpInterceptor.isForWebSocket()));

    //构成了一个拦截器链
    Interceptor.Chain chain = new RealInterceptorChain(interceptors, null, null, null, 0, originalRequest);

    return chain.proceed(originalRequest);
  }
```

核心在于 Chain 的 processed 方法，有多少个拦截器就会调用多少次 proceed 方法：

```java
//proceed的核心逻辑
 public Response proceed(Request request, StreamAllocation streamAllocation, HttpStream httpStream,
                            Connection connection) throws IOException {

        //重新构造一个链条，但是Index + 1，下一次proceed方法就会获取下一个拦截器
        RealInterceptorChain next = new RealInterceptorChain(interceptors, streamAllocation, httpStream, connection, index + 1, request);

        //获取
        Interceptor interceptor = interceptors.get(index);
        //调用interceptor的intercept方法，把chain传入，intercept方法中必须调用chain的proceed方法
        Response response = interceptor.intercept(next);

        //最后返回响应
        return response;
    }
```

流程总结：

- 创建一系列拦截器，将其放入到一个拦截器list中
- 创建一个拦截器链RealInterceptorChain，并执行拦截器的proceed方法
- 在发起请求前对 request 进行处理
- 调用下一个拦截器获取Response
- 对Response进行处理，返回给上一个拦截器

### 内置的核心拦截器

- `RetryAndFollowUpInterceptor`：用于进行网络重连和失败重试，还有重定向处理。
- `BridgeInterceptor`：它负责⼀一些不不影响开发者开发，但影响 HTTP 交互的⼀一些额外预处理理。
  - 补充 Http 请求必要的头部信息，将用户构建的一个 Request 请求转化为能够进行网络访问的请求。
  - 将网络请求回来的响应 Response 转化为用户可用的 Responnse。
  - 自动 gzip 压缩解压缩处理。
- `CacheInterceptor`：它负责 Cache 的处理。把它放在后面的网络交互相关 Interceptor 的前面的好处是，如果本地有了可用的 Cache，⼀个请求可以在没有发⽣实质网络交互的情况下就返回缓存结果，⽽完全不需要开发者做出任何的额外工作，让 Cache 更加无感知。
- `ConnectInterceptor`：负责建⽴连接。在这里，OkHttp 会创建出网络请求所需要的TCP 连接（如果是 HTTP），或者是建立在 TCP 连接之上的 TLS 连接（如果是 HTTPS），并且会创建出对应的HttpCodec对象（用于编码解码 HTTP 请求）；
- `CallServerInterceptor`：它负责实质的请求与响应的 I/O 操作，按照 HTTP 协议规范往 Socket ⾥写⼊请求数据，和从 Socket ⾥读取响应数据。
