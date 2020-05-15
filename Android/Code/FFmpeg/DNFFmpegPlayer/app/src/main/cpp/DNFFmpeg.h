
#ifndef DNFFMPEGPLAYER_DNFFMPEG_H
#define DNFFMPEGPLAYER_DNFFMPEG_H

#include "JavaCallHelper.h"
#include "AudioChannel.h"
#include "VideoChannel.h"

extern "C" {
#include <libavformat/avformat.h>
}

/*在头文件中进行声明，在 cpp 文件中进行实现。*/
class DNFFmpeg {

public:
    DNFFmpeg(JavaCallHelper *javaCallHelper, const char *dataSource);

    ~DNFFmpeg();

    void prepare();

    void _prepare();

private:
    char *dataSource;
    AVFormatContext *avFormatContext;
    JavaCallHelper *javaCallHelper;
    AudioChannel * audioChannel;
    VideoChannel *videoChannel;
};

#endif //DNFFMPEGPLAYER_DNFFMPEG_H
