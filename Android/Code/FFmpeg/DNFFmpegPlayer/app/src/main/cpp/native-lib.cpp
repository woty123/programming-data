#include <jni.h>
#include <string>
#include "DNFFmpeg.h"

extern "C" {
#include <libavcodec/avcodec.h>
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_dongnao_player_MainActivity_stringFromJNI(JNIEnv *env, jobject /* this */) {
    av_version_info();
    return env->NewStringUTF(av_version_info());
}

extern "C"
JNIEXPORT void JNICALL
Java_com_dongnao_player_DNPlayer_nativePrepare(JNIEnv *env, jobject thiz, jstring dataSource) {
    //创建FFmpeg
    const char *string = env->GetStringUTFChars(dataSource, 0);
    DNFFmpeg fmpeg(string);
    env->ReleaseStringUTFChars(dataSource, string);
    //调用 native 层的 prepare
    fmpeg.prepare()
}