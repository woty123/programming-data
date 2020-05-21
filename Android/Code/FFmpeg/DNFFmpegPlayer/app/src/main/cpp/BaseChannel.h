#ifndef DNFFMPEGPLAYER_BASECHANNEL_H
#define DNFFMPEGPLAYER_BASECHANNEL_H

#import "safe_queue.h"

extern "C" {
#include <libavcodec/avcodec.h>
};

class BaseChannel {

public:
    BaseChannel(int id, AVCodecContext *codecContext) : id(id), avCodecContext(codecContext) {

    }

    virtual ~BaseChannel() {
        packets.setReleaseCallback(releaseAVPacket);
        packets.clear();
    }

    int id;
    AVCodecContext *avCodecContext = nullptr;
    SafeQueue<AVPacket *> packets;
    bool isPlaying = false;

    virtual void play() = 0;

    static void releaseAVPacket(AVPacket **avPacket) {
        if (avPacket) {
            av_packet_free(avPacket);
            *avPacket = nullptr;
        }
    }

    static void releaseAVFrame(AVFrame **avFrame) {
        if (avFrame) {
            av_frame_free(avFrame);
            *avFrame = nullptr;
        }
    }
};

#endif //DNFFMPEGPLAYER_BASECHANNEL_H
