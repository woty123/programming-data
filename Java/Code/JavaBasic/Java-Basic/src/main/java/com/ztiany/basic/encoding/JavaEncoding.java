package com.ztiany.basic.encoding;

import java.nio.charset.Charset;

/**
 * @author Ztiany
 * Email ztiany3@gmail.com
 * Date 2020/3/11 11:00
 */
public class JavaEncoding {

    /*
    字符、编码和Java中的编码：https://www.jianshu.com/p/1b00ca07b003
    深入分析 Java 中的中文编码问题：https://www.ibm.com/developerworks/cn/java/j-lo-chinesecoding/index.htm
    分享一下我所了解的字符编码知识：https://www.jianshu.com/p/2d4ad873b39f
    what-does-it-mean-to-say-java-modified-utf-8-encoding：https://stackoverflow.com/questions/7921016/what-does-it-mean-to-say-java-modified-utf-8-encoding
     */

    /*
    Java运行时环境和外部环境使用的编码是不一样的：

        1. 外部环境的编码可以使用Charset.defaultcharset()获取。如果没有指定外部环境编码，就是操作系统的默认编码。
            jvm操作I/O流时，如果不指定编码，也会使用这个编码，可以在启动Java时使用-Dfile.encoding=xxx设置。
            通过System.setProperty("file.encoding","GBK")能修改这个值，但由于jvm一旦启动就不能修改jvm默认字符集，所以修改这个值并没有什么作用。

        2. 编译时的编码转换：Java的源文件可以是任意的编码，但是在编译的时候，Javac编译器默认会使用操作系统平台的编码解析字符。
            如果Java源文件的编与默认编码不一致，就需要通过 -encoding参数指定。

        3. 运行时数据中的UTF-16：JVM中运行时数据都是使用UTF-16进行编码的。

        4. modified UTF-8：后期为了支持更多编码，有了modified UTF-8，modified UTF-8是对UTF-16的再编码。
     */
    public static void main(String... args) {
        System.out.println(Charset.defaultCharset().name());
        System.out.println(System.getProperty("file.encoding", "un-know"));
    }

}
