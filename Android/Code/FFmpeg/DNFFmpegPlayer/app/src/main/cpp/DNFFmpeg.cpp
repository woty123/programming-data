#include "DNFFmpeg.h"
#include <cstring>
#include <pthread.h>

extern "C" {
#include <libavformat/avformat.h>
}

DNFFmpeg::DNFFmpeg(const char *dataSource) {
    //防止 dataSource 指向的内存被释放。
    this->dataSource = new char[strlen(dataSource)];
    //拷贝数据
    strcpy(this->dataSource, dataSource);
}

DNFFmpeg::~DNFFmpeg() {
    delete dataSource;
    dataSource = nullptr;
}

void *task_preapre(void *args) {
    auto *dnfFmpeg = static_cast<DNFFmpeg *>(args);
    dnfFmpeg->_prepare();
    return 0;
}

void DNFFmpeg::prepare() {
    //创建多线程
    pthread_t tid;
    pthread_create(&tid, nullptr, task_preapre, (void *) "NO1");
}

void DNFFmpeg::_prepare() {
    /*
     * 参数说明：
     *  AVFormatContext**：封装格式上下文结构体，全局结构体，保存了视频文件封装格式相关信息。一般让我们传递二级指针，意味着被调用函数回去修改该指针的指向，不需要我们创建对象。
     */
    AVFormatContext *context;
    avformat_open_input(&context,this->dataSource, )
}