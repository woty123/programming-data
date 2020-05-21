#include "AudioChannel.h"

AudioChannel::AudioChannel(
        int audioId,
        AVCodecContext *avCodecContext
) : BaseChannel(audioId, avCodecContext) {

}

void AudioChannel::play() {

}
