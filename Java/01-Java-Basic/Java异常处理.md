# 异常处理

## 1 栈轨迹

从Exception获取StackTraceElement的数组，其中每个元素都表示栈中的一帧。元素0是栈顶的元素。

```java
            try {
                funcA();
            } catch (Exception e) {
                StackTraceElement[] stackTrace = e.getStackTrace();
                for (StackTraceElement stackTraceElement : stackTrace) {
                    System.out.println(stackTraceElement.getClassName());
                    System.out.println(stackTraceElement.getFileName());
                    System.out.println(stackTraceElement.getLineNumber());
                    System.out.println(stackTraceElement.getMethodName());
                }
            }
```

## 2 重新抛出异常

使用fillInStackTrace方法可以重新抛出异常

```java
        try {
            funcA();
        } catch (Exception e) {
            throw  e.fillInStackTrace();
        }
```

## 3 当final中包含return语句时

当final中包含return语句时，将会出现一种意向不到的结果，假设利用return从try语句中返回，在方法返回之前final语句将会被执行，当final语句中也包含return语句时，这个返回值将会覆盖原始的返回值。

## 4 TryWithResource

在JDK1.7中，允许在使用包含资源的try语句(需要实现 AutoCloseable 接口)。如：

```java
        try (Scanner scanner = new Scanner(new FileInputStream("a.txt"))) {
            String text;
            int line = 0;
            while (scanner.hasNext() ) {
                text = scanner.nextLine();
                System.out.println("line :" + line++ + " " + text);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
```

try退出时，scanner会自动调用close()方法关闭
