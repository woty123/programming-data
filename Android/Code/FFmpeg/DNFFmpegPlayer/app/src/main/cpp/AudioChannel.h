#ifndef DNFFMPEGPLAYER_AUDIOCHANNEL_H
#define DNFFMPEGPLAYER_AUDIOCHANNEL_H

#include "BaseChannel.h"

class AudioChannel : public BaseChannel {
public:
    AudioChannel(int audioId, AVCodecContext *avCodecContext);

    void play();
};

#endif //DNFFMPEGPLAYER_AUDIOCHANNEL_H
