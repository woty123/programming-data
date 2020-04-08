#include "Utils.h"

#include <malloc.h>
#include <string.h>

/*
 java内部是使用16bit的unicode编码（UTF-16）来表示字符串的，无论中文英文都是2字节；
 jni内部是使用UTF-8编码来表示字符串的，UTF-8是变长编码的unicode，一般ascii字符是1字节，中文是3字节；
 c/c++使用的是原始数据，ascii就是一个字节了，中文一般是GB2312编码，用两个字节来表示一个汉字。

 情况：
 1. 通过jni的NewStringUTF方法把C++的字符串转换为jstring时，如果入参为emoji表情或其他非Modified UTF8编码字符将导致Crash
 2. 使用jni的GetStringUTFChars方法把jstring转换为C++字符串时得到的字符串编码为Modified UTF8，如果直接传递到服务端或其他使用方，emoji表情将出现解析失败的问题。

 方案：与其他组件进行交互或与服务端进行通信时要注意不要误把变种Modified UTF-8当成UTF-8数据。
            可以先将Java的String用UTF-8编码转换成byte数组，再转换成C/C++字符串即可保证字符编码为UTF-8。
 */

/**
 * Java String转换为C字符串，转换后的字符串是可以修改的
 */
char *Jstring2CString(JNIEnv *env, jstring jstr) {
    char *rtn = NULL;
    jclass clsstring = (*env)->FindClass(env, "java/lang/String");
    jstring strencode = (*env)->NewStringUTF(env, "UTF-8");
    jmethodID mid = (*env)->GetMethodID(env, clsstring, "getBytes", "(Ljava/lang/String;)[B");
    // String .getByte("GB2312");
    jbyteArray barr = (jbyteArray) (*env)->CallObjectMethod(env, jstr, mid, strencode);
    jsize alen = (*env)->GetArrayLength(env, barr);
    jbyte *ba = (*env)->GetByteArrayElements(env, barr, 0);
    if (alen > 0) {
        rtn = (char *) malloc(alen + 1);         //"\0" c中字符串以\0结尾
        memcpy(rtn, ba, alen);
        rtn[alen] = 0;//让最后一个字符='\0',表示是字符串的结尾
    }
    (*env)->ReleaseByteArrayElements(env, barr, ba, 0);
    return rtn;
}