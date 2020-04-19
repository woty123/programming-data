# Servlet3.0 新特性概要总结

运行环境要求：

- Tomcat7.0 及以上版本。
- JDK6.0 及以上版本。

---

## 1 添加注解的支持

Servlet3.0，可以不用配置 xml，直接使用注解配置 Servlet 等组件。

- `@WebServlet`
- `@WebInitParam`
- `@WebListener`
- `@WebFilter`

示例：

```java
@WebServlet(value = { "/servlet/ServletDemo1", "/servlet/ServletDemo11" }, initParams = {
        @WebInitParam(name = "encoding", value = "UTF-8"),
        @WebInitParam(name = "XXX", value = "YYY") })
public class ServletDemo1 extends HttpServlet {

}
```

---

## 2 Fragment

Servlet 3.0 引入了称之为 `Web 模块部署描述符片段的 web-fragment.xml` 部署描述文件，该文件必须存放在 JAR 文件的 META-INF 目录下，该部署描述文件可以包含一切可以在 web.xml 中定义的内容。JAR 包通常放在 WEB-INF/lib 目录下，除此之外，所有该模块使用的资源，包括 class 文件、配置文件等，只需要能够被容器的类加载器链加载的路径上，比如 classes 目录等。

---

## 3 ServletContainerInitializer

Servlet3.0 支持以下两种编程的方式来在应用启动时注册组件：

1. ServletContextListener。
2. ServletContainerInitializer：第三方 jar 服务，用于第三方库动态注册组件。

ServletContainerInitializer 在 Servle3.0 中被添加，用于支持第三方 jar 以编程的方式注册 Servlet、filter 合 Listener。要启动一个 ServletContainerInitializer ，则需要在 `WEB-INF/services/javax.servlet.ServletContainerInitializer` 中配置实现类的全路径名。

相关连接：

- [Tomcat - won't load my META-INF\services\javax.servlet.ServletContainerInitializer file?](https://stackoverflow.com/questions/7692497/tomcat-wont-load-my-meta-inf-services-javax-servlet-servletcontainerinitializ)

示例：

```java
package com.ztiany.servlet3;

import com.ztiany.servlet3.service.HelloService;

import java.util.EnumSet;
import java.util.Set;

import javax.servlet.DispatcherType;
import javax.servlet.FilterRegistration;
import javax.servlet.ServletContainerInitializer;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRegistration;
import javax.servlet.annotation.HandlesTypes;

@HandlesTypes(
        {
                //容器启动的时候会将@HandlesTypes指定类型的所有子类（实现类，子接口等）传递过来。
                HelloService.class
        }
)
public class TestServletContainerInitializer implements ServletContainerInitializer {

    /*
     * 应用启动的时候，会运行onStartup方法：
     *
     * Set<Class<?>> arg0：感兴趣的类型的所有子类型。
     * ServletContext arg1：代表当前Web应用的ServletContext，一个Web应用只有一个ServletContext。
     *
     * 1）、使用ServletContext可以注册Web组件（Servlet、Filter、Listener）
     * 2）、使用编码的方式，在项目启动的时候给ServletContext里面添加组件，必须在项目启动的时候来添加。
     * 		1）、ServletContainerInitializer得到的ServletContext；
     * 		2）、ServletContextListener得到的ServletContext；
     */
    @Override
    public void onStartup(Set<Class<?>> c, ServletContext ctx) throws ServletException {
        System.out.println("onStartup classes：");
        for (Class<?> clazz : c) {
            System.out.println(clazz);
        }
        System.out.println();

        //注册组件  ServletRegistration
        ServletRegistration.Dynamic servlet = ctx.addServlet("testRegisterServlet", new TestRegisterServlet());
        //配置servlet的映射信息
        servlet.addMapping("/testRegister");

        //注册Listener
        ctx.addListener(TestRegisterListener.class);

        //注册Filter  FilterRegistration
        FilterRegistration.Dynamic filter = ctx.addFilter("testRegisterFilter", TestRegisterFilter.class);
        //配置Filter的映射信息
        filter.addMappingForUrlPatterns(EnumSet.of(DispatcherType.REQUEST), true, "/*");
    }

```

配置路径：`WEB-INF/services/javax.servlet.ServletContainerInitializer`，内容为：`com.ztiany.servlet3.TestServletContainerInitializer`。

---

## 4 异步处理

在 Servlet3.0 之前，Servlet 采用 Thread-Per-Request的方式处理请求。即每一次 Http 请求都由某一个线程从头到尾负责处理。如果一个请求需要进行IO 操作，比如访问数据库、调用第三方服务接口等，那么其所对应的线程将同步地等待 IO 操作完成， 而 IO 操作是非常慢的，所以此时的线程并不能及时地释放回线程池以供后续使用，在并发量越来越大的情况下，这将带来严重的性能问题。即便是像 Spring、Struts 这样的高层框架也脱离不了这样的桎梏，因为它们都是建立在 Servlet 之上的。为了解决这样的问题，Servlet3.0 引入了异步处理，然后在 Servlet 3.1 中又引入了非阻塞 IO 来进一步增强异步处理的性能。

AsyncContext 的 complete() 方法用于通知 Tomcat 我们异步线程已经执行结束了，Tomcat 才会及时的断开与浏览器的连接。

```java
//首先要配置Servlet，添加asyncSupported=true
 @WebServlet(urlPatterns="/AServlet", asyncSupported=true)
public class AsyncDemoServlet extends HttpServlet {

    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse resp)
    throws IOException, ServletException {
        //在子线程中执行业务调用，并由其负责输出响应，主线程退出
        AsyncContext ctx = req.startAsync();
        //在异步线程中通过ctx可以继续向客户端写数据
        new Thread(new Executor(ctx)).start();
    }

}
```

---

## 5 文件上传支持

使用`@MultipartConfig`注解标注的Servlet将文件上传，读取和保存上传文件将变得异常简单：

```java
@WebServlet("/servlet/UploadServlet")
@MultipartConfig/
public class UploadServlet extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        System.out.println(name);
        //上传字段
        Part photoPart = request.getPart("photo");
        //取文件名  Content-Disposition: form-data; name="photo"; filename="2.jpg"

        String value = photoPart.getHeader("Content-Disposition");
        int filenameIndex = value.indexOf("filename=")+10;
        String filename = value.substring(filenameIndex, value.length()-1);
        photoPart.write(getServletContext().getRealPath("/WEB-INF/files")+"/"+filename);
    }

}
```

---

## 6  Http-Only

Cookie是如果处理不好，是有安全隐患的，3.0为Cookie添加了Http-Only属性，如果Cookie的HttpOnly为true，则客户端的脚本无法读取该cookie。

服务端

```java
        Cookie c = new Cookie("c1", "wj");
        c.setPath(request.getContextPath());
        c.setMaxAge(Integer.MAX_VALUE);
        c.setHttpOnly(true);
        response.addCookie(c);
```

客户端

```js
  <script type="text/javascript">
        alert(document.cookie);
  </script>
```

---

## 附不同版本的servlet标准的web.xml配置

```xml
<!-- servlet 3.1 -->
<?xml version="1.0" encoding="UTF-8"?>  
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"   
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
        xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee  
         http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"  
        version="3.1">

</web-app>

<!-- servlet 3.0 -->
<?xml version="1.0" encoding="UTF-8"?>  
<web-app xmlns="http://java.sun.com/xml/ns/javaee"  
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
          xsi:schemaLocation="http://java.sun.com/xml/ns/javaee  
          http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"  
          version="3.0">

</web-app>

<!-- servlet 2.5 -->
<?xml version="1.0" encoding="UTF-8"?>  
<web-app xmlns="http://java.sun.com/xml/ns/javaee"  
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
          xsi:schemaLocation="http://java.sun.com/xml/ns/javaee  
          http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"  
          version="2.5">

</web-app>
```

---

## 引用

- [Servlet3.0 新特性详解 - IBM](https://www.ibm.com/developerworks/cn/java/j-lo-servlet30/index.html)
- [Servielt3.0 规范](https://download.oracle.com/otn-pub/jcp/servlet-3.0-fr-eval-oth-JSpec/servlet-3_0-final-spec.pdf?AuthParam=1587286154_c07ed05a6cf198b1b36ae931a4266ff5)
