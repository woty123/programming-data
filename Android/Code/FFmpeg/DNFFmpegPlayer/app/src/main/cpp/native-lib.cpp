#include <jni.h>
#include <string>
#include "DNFFmpeg.h"
#include "macro.h"

JavaVM *globalJvm;
DNFFmpeg *dnfFmpeg;

extern "C"
JNIEXPORT void JNICALL
Java_com_dongnao_player_DNPlayer_nativePrepare(JNIEnv *env, jobject thiz, jstring dataSource) {
    //创建FFmpeg
    const char *string = env->GetStringUTFChars(dataSource, nullptr);
    auto *javaCallHelper = new JavaCallHelper(globalJvm, env, thiz);
    dnfFmpeg = new DNFFmpeg(javaCallHelper, string);
    //调用 native 层的 prepare
    dnfFmpeg->prepare();
    env->ReleaseStringUTFChars(dataSource, string);
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *jvm, void *reserved) {
    globalJvm = jvm;
    LOGD("JNI_OnLoad");
    return JNI_VERSION_1_4;
}

extern "C"
JNIEXPORT void JNICALL
Java_com_dongnao_player_DNPlayer_nativeDestroy(JNIEnv *env, jobject thiz) {
    dnfFmpeg = nullptr;
}