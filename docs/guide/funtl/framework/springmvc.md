---
sidebar: auto
---

# SpringMVC

​	　**Spring MVC** (或称Spring Web MVC)属于**Spring**中的**展示层框架**，其提供了**MVC模式**使得Web应用在`输入逻辑`、`业务逻辑`和 `UI 逻辑`实现**松散耦合**。Spring MVC通过**DispatcherServlet组件类**处理所有的 HTTP 请求和响应， 具体的工作流如下图所示：

![ssm_dispatcherservlet](./images/ssm_dispatcherservlet.jpg)

​	　　`DispatcherServlet`分发器在接收到 HTTP 请求后，会先查询 `HandlerMapping` 调用相应的Controller。**Controller**根据请求的 `GET` 或 `POST` 方法调用相应的**服务方法**，服务方法将基于定义的业务逻辑设置模型数据，并将**模型**和**逻辑视图名称**返回给 DispatcherServlet。DispatcherServlet 通过**ViewResolver**（视图解析器） 获取请求的**定义视图**。最后，DispatcherServlet 将模型数据传递到最终的**视图**，并在浏览器上呈现。

​	　特别的， `HandlerMapping`，`Controller` 和 `ViewResolver` 是 `WebApplicationContext` 的一部分，它是普通 ApplicationContext 的扩展，带有 Web 应用程序所需的一些额外功能。



## Spring整合MVC

### 引入Jar包

```xml
<!--Spring MVC-->
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-webmvc</artifactId>
    <version>4.3.17.RELEASE</version>
</dependency>
```

​	　特别的，`spring-webmvc`已经依赖了`spring-web` 、`spring-context`等Jar包。所以，被依赖的这些Jar包可以删除，但是为了表明所使用的框架，建议保留。

### web.xml

​	　首先，需要在`web.xml`中配置`Spring MVC`需要的`DispatcherServlet` 拦截器 ，与Servlet拦截器可以直接访问`JSP页面`不同，SpringMvc提供的拦截器，访问`视图`和`业务请求`时，都需要经过`controller`转发给`视图解析器`，视图文件解析器会找到`视图名`的`前缀`和`后缀`，然后找到对应的页面，返回给用户。接着，还需要继续配置字符集过滤器`CharacterEncodingFilter`。

#### DispatcherServlet

```xml
<!--配置 Spring 的 Servlet 分发器DispatcherServlet处理所有 HTTP 的请求和响应-->
<servlet>
    <servlet-name>springServlet</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <init-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath*:/spring-mvc*.xml</param-value>
    </init-param>
    <!--优先启动，设置优先级为1（最高） -->
    <load-on-startup>1</load-on-startup>
</servlet>
<!--拦截所有请求，交于DispatchServlet处理 -->
<servlet-mapping>
    <servlet-name>springServlet</servlet-name>
    <url-pattern>/</url-pattern>
</servlet-mapping>
```



#### CharacterEncodingFilter

```xml {21-37,39-54}
<!--配置字符集过滤器CharacterEncodingFilter，用于解决中文编码问题-->
<filter>
    <filter-name>encodingFilter</filter-name>
    <filter-class>
        org.springframework.web.filter.CharacterEncodingFilter
    </filter-class>
    <init-param>
        <param-name>encoding</param-name>
        <param-value>UTF-8</param-value>
    </init-param>
    <init-param>
        <param-name>forceEncoding</param-name>
        <param-value>true</param-value>
    </init-param>
</filter>
<filter-mapping>
    <filter-name>encodingFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

​	　特别的，`UTF-8`中文字符占3-4个字节，英文占1个自字节；`GBK`一个字符占2个字节，是专门支持中文的字符集；`ISO-8859-1`一个字符占一个字节，仅能支持英文等；`utf8mb4`是UTF-8的扩展，一个字符占4个字节，可以用于存储emoji表情。

### spring-mvc.xml

​	　在`resource`目录下新建`sprin-mvc.xml`文件来配置 MVC。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd
        http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc.xsd">

    <description>Spring MVC Configuration</description>

    <!-- 加载配置属性文件 -->
    <context:property-placeholder ignore-unresolvable="true" 
                                  location="classpath:myshop.properties"/>

    <!-- 使用 Annotation 自动注册 Bean,只扫描 @Controller -->
    <context:component-scan base-package="com.shooter.funtl" use-default-filters="false">
        <context:include-filter type="annotation" 
                                expression="org.springframework.stereotype.Controller"/>
    </context:component-scan>

    <!-- 默认的注解映射的支持 -->
    <mvc:annotation-driven />

    <!-- 定义视图文件解析 -->
    <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="${web.view.prefix}"/>
        <property name="suffix" value="${web.view.suffix}"/>
    </bean>

    <!-- 静态资源映射，主要用于配置静态资源文件存放路径，如：JS、CSS、Image 等 -->
    <mvc:resources mapping="/static/**" location="/static/" cache-period="31536000"/>
</beans>
```



### 属性配置文件

​	　`context:property-placeholder`用于**动态加载属性配置文件**，使得`spring-mvc.xml`可以通过**变量的方式**引用属性配置文件的值。

```xml
<!-- 加载配置属性文件 -->
<context:property-placeholder ignore-unresolvable="true" 
                              location="classpath:myshop.properties"/>
```

​	　在`resource`目录下新建`myshop.properties`属性配置文件，将系统所需的一些配置信息进行封装便于统一的管理。

```properties
web.view.prefix=/WEB-INF/views/
web.view.suffix=.jsp
```

​	　`myshop.properties`中配置`web.view.prefix`和`web.view.suffix`属性，在`定义视图文件解析`中可以通过如`${web.view.prefix}`、`${web.view.suffix}` 的方式引用。

```xml
<!-- 定义视图文件解析 -->
<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
    <property name="prefix" value="${web.view.prefix}"/>
    <property name="suffix" value="${web.view.suffix}"/>
</bean>
```

​	　其中，`InternalResourceViewResolver`是**视图文件解析器**的一种，用于配置**视图资源的路径**和**需要解释的视图资源文件类型**，这里有两个需要配置的属性 `prefix`（前缀）以及 `suffix`（后缀）。`prefix`指配置**视图资源路径**，如：`/WEB-INF/views/`；`suffix`指配置**视图资源类型**，如：`.jsp`。



### spring-context.xml

​	　`context:component-scan`仅用于**指定扫描包含 `@Controller` 注解的目录**。此外，由于 `spring-mvc.xml` 中已经配置了 `@Controller` 注解的扫描，而 `spring-context.xml` 中配置的是扫描全部注解，故在这里需要将 `@Controller` 注解的扫描配置排除。

```xml{3,4}
<context:component-scan base-package="com.shooter.funtl">
    <!--@Controller交于spring-mvc.xml管理，扫描配置在从spring-context.xml中排除-->
    <context:exclude-filter type="annotation" 
                            expression="org.springframework.stereotype.Controller"/>
</context:component-scan>
```



## SpringMVC控制器

​	　在Spring MVC中只需使用 `@Controller` 标记一个类是 Controller ，然后使用 `@RequestMapping` 和 `@RequestParam` 等一些注解用以**定义 URL 请求**和 **Controller 方法之间的映射**。

​	　特别的，Spring MVC中 Controller 不会像Servlet一样，不仅需要通过`web.xml`配置`servlet拦截器`指明`类`和`请求路径`的对应关系，还需要继承`HttpServlet` 类， 实现`doPost` 或者 `doGet`接口，并直接依赖于`HttpServletRequest` 和 `HttpServletResponse` 等获取参数。



### @Controller

​	　`@Controller` 用于**定义了一个控制器类**，使用它标记的类就是一个 `Spring MVC Controller` 对象。分发处理器将会**扫描使用了该注解的类的方法**，并检测该方法是否使用了 `@RequestMapping` 注解。特别的，`@Controller` 只是定义了一个控制器类，而使用 `@RequestMapping` 注解的方法才是真正处理请求的处理器。

```java
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
public class MainController {

    @RequestMapping(value = "main", method = RequestMethod.GET)
    public String login() {
        return "main";
    }
}
```



### @RequestMapping

​	　`@RequestMapping` 是一个用来**处理请求地址映射**的注解，可用于 `类` 或 `方法` 上。**用于类上，表示类中的所有响应请求的方法都是以该地址作为父路径**，如下方法需要通过`/user/login`路径才能访问。

```java
@Controller
@RequestMapping("/user/")
public class MainController {

    @RequestMapping(value = "login", method = RequestMethod.GET)
    public String login() {
        return "login";
    }
}
```

​	　`@RequestMapping` 注解有六个属性，其中，`value` 和 `method`两个属性是必选的。

```
value：指定请求的实际地址，指定的地址可以是 URI Template 模式
method：指定请求的method类型， GET、POST、PUT、DELETE 等
consumes：指定处理请求的提交内容类型（Content-Type），例如 application/json, text/html
produces: 指定返回的内容类型，仅当 request 请求头中的(Accept)类型中包含该指定类型才返回
params：指定 request 中必须包含某些参数值是，才让该方法处理
headers：指定 request 中必须包含某些指定的 header 值，才能让该方法处理请求
```



### @RequestParam

​	　`@RequestParam` 是一个用来将**请求参数绑定到控制器的方法参数上**的注解，如：请求路径：`/login?loginId=admin&loginPwd=123`，可以解析出`loginId为admin`和`loginPwd值为123`。其中`required = true`表示必须包含该参数，才能让该方法处理请求，默认是false。

```java
@RequestMapping(value = "login", method = RequestMethod.GET)
public String login(@RequestParam(required = true) String loginId,
                    @RequestParam String loginPwd) {
    return "login";
}
```



### @ResponseBody

​	　仅使用`@RequestMapping` 注解，方法返回值通常会被解析为**视图**，例如：`return "main"`表示**跳转视图**，`return "redirect:/user/list"` 表示**重定向视图**。若`@RequestMapping`和`@ResponseBody`同时注解方法，可以将返回的对象，通过适当的 `HttpMessageConverter` 转换为指定格式（JSON、XML）后，写入到  `Response` 对象的 `body` 数据区。

```java
@RequestMapping(value = "login", method = RequestMethod.POST)
@ResponseBody
public User login() {
    return new User();
}
```

​	　如果需要返回**自定义对象**为 JSON 数据类型，需要增加 `jackson` 依赖，`pom.xml` 配置文件如下：

```xml
<!-- Json Begin -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-core</artifactId>
    <version>2.9.5</version>
</dependency>
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.9.5</version>
</dependency>
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-annotations</artifactId>
    <version>2.9.5</version>
</dependency>
<!-- Json End -->
```



### @ModelAttribute

​	　　`@ModelAttribute`注解用于将 **方法的参数** 或 **方法的返回值** 绑定到指定的模型属性上，并返回给Web视图。特别的，`@ModelAttribute`注解的方法会在**此controller每个方法执行前被执行**。

#### 注解参数

​	　简化绑定流程，不仅可以从　从`model`、`Form表单` 或 `URL参数`中**解析参数**（实际上，不做此注释也能拿到user对象），还可以**自动暴露**为模型数据用于视图页面展示时使用。注意这时候这个User类一定要有无参数的构造函数。

```java
@RequestMapping(value = "/helloWorld")
public String helloWorld(@ModelAttribute User user) {
    return "helloWorld";
}
```



#### 注解方法

##### 注释void方法

```java
@ModelAttribute
public void preHandle(@RequestParam String name, Model model) {
    //在执行helloWorld方法之前，将name加入model
	model.addAttribute("name", name);
}

@RequestMapping(value = "/helloWorld")
public String helloWorld() {
	return "helloWorld";
}
```

​	　在获得请求`/helloWorld?name=name`后，`preHandle`方法会在`helloWorld`方法之前被调用。返回视图名`helloWorld`时，model已由`@ModelAttribute`方法设置好了。其实不需要这个方法，完全可以把请求的方法写成下面的样子，这样缺少此参数也不会出错。

```java
@RequestMapping(value = "/helloWorld")
public String helloWorld(String name) {
   //name会被字段加入到model中
   return "helloWorld";
}
```



##### 注释有返回具体类的方法

​	　`@ModelAttribute`方法若存在返回值，**该返回值会自动加入到model属性中**。model属性的名称默认是**返回值名称**，也可以通过如`@ModelAttribute("attributeName")`的方式指定，但若返回的是常量，则必须指定名称；model属性对象的值就是**方法的返回值**。

```java
@ModelAttribute
public String getUser(@RequestParam String name) {
    //返回值字段会被加入到model中
    return name;
}

@RequestMapping(value = "/helloWorld")
public String helloWorld() {
    return "helloWorld";
}
```



##### 注解RequestMapping方法

```java
@RequestMapping(value = "/helloWorld.do")
@ModelAttribute("attributeName")
public String helloWorld() {
    return "hi";
}
```

​	　**Model属性名称**由`@ModelAttribute("attributeName")`指定。方法的返回值并不表示一个视图名称，而是**model属性的值**。视图名称由`RequestToViewNameTranslator`根据请求路径`/helloWorld.do`转换为`逻辑视图helloWorld`。所以，相当于request中封装了`key=attributeName，value=hi`。



## SpringMVC拦截器

​	　SpringMVC中不能使用Servlet过滤器，只能使用**SpringMVC拦截器**做日志记录、权限管理、性能监控、读取 Cookie 等。

### HandlerInterceptor

​	　Spring MVC 拦截器需要实现 `HandlerInterceptor` 接口的 `afterCompletion()`、`postHandle()` 和 `preHandle()`方法来对用户的请求进行拦截处理。



#### preHandle

```java
import org.springframework.web.servlet.HandlerInterceptor;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class LoginInterceptor implements HandlerInterceptor {
    
   public boolean preHandle(HttpServletRequest httpServletRequest,
                           HttpServletResponse httpServletResponse, Object o) throws Exception {
        //放行
        return true;
    }
}
```

​	　Spring MVC 中的 Interceptor 是**链式调用**的，一个请求中可以**同时存在多个 Interceptor**，每个 Interceptor 的调用会依据它的**声明顺序依次执行**，首先执行的都是 Interceptor 中的 `preHandle` 方法。

​	　`preHandle`方法的返回值是布尔值 Boolean 类型的，当它返回为 `false` 时，表示请求结束，**后续的 Interceptor（如：postHandle、afterCompletion）  和 Controller 都不会再执行**；当返回值为 `true` 时，就会**继续调用下一个 Interceptor 的 `preHandle` 方法**，如果已经是最后一个 Interceptor 的时候，就会是调用当前请求的 Controller 中的方法。

#### postHandle

```java
import org.springframework.web.servlet.HandlerInterceptor;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class LoginInterceptor implements HandlerInterceptor {
    
  public void postHandle(HttpServletRequest httpServletRequest, 
                         HttpServletResponse httpServletResponse, 
                         Object o, ModelAndView modelAndView) throws Exception {

    }
}
```

​	　`postHandle` 方法会在 **Controller 中的方法调用之后**、**在 `DispatcherServlet` 进行视图渲染之前**被调用。所以，可以在`postHandle` 方法中对 Controller 处理之后的 `ModelAndView` 对象进行操作。特别的，`postHandle` 方法被调用的方向跟 `preHandle` 是相反的，也就是说，先声明的 Interceptor 的 `postHandle` 方法反而会后执行。

#### afterCompletion

```java
import org.springframework.web.servlet.HandlerInterceptor;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class LoginInterceptor implements HandlerInterceptor {
    
   public void afterCompletion(HttpServletRequest httpServletRequest, 
                               HttpServletResponse httpServletResponse, 
                               Object o, Exception e) throws Exception {

    }
}
```

​	　`afterCompletion`方法会**在 `DispatcherServlet` 渲染了对应的视图之后执行**，其主要作用是用于进行资源清理的工作。



### spring-mvc.xml

​	　拦截器定义后还需要在 `spring-mvc.xml` 中配置拦截器。多个拦截器是先执行后定义的，排在第一位的最后执行。

```xml
<mvc:interceptors>
  <!-- 定义一个拦截器 -->
    <mvc:interceptor>
        <!-- 映射路径，需要拦截的请求路径-->
        <mvc:mapping path="/**"/>
        <!-- 需要排除的请求路径，静态资源和登录请求不需要拦截-->
        <mvc:exclude-mapping path="/static/**"/>
        <mvc:exclude-mapping path="/login"/>
        <!-- 配置指定的拦截器对象-->
        <bean class="com.shooter.funtl.module.web.interceptor.LoginInterceptor"/>
    </mvc:interceptor>
</mvc:interceptors>
```

