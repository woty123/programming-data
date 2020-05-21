#include "VideoChannel.h"
#include "macro.h"

extern "C" {
#include <libavutil/imgutils.h>
}

VideoChannel::VideoChannel(
        int videoId,
        AVCodecContext *avCodecContext
) : BaseChannel(videoId, avCodecContext) {
    frames.setReleaseCallback(releaseAVFrame);
}

VideoChannel::~VideoChannel() {
    frames.clear();
}

void *decode_task(void *args);

void *render_task(void *args);

/**called by Player, to play the video*/
void VideoChannel::play() {
    LOGD("VideoChannel::play called");
    isPlaying = true;
    //存包的
    packets.setWork(1);
    //存帧的
    frames.setWork(1);
    //开启线程，防止阻塞读流线程。
    //解码
    pthread_create(&pid_decode, nullptr, decode_task, this);
    //播放
    pthread_create(&pid_render, nullptr, render_task, this);
    LOGD("VideoChannel::play completed");
}

/**解码任务*/
void *decode_task(void *args) {
    auto videoChannel = static_cast<VideoChannel *>(args);
    videoChannel->decodePacket();
    return nullptr;
}

/**渲染任务*/
void *render_task(void *args) {
    auto videoChannel = static_cast<VideoChannel *>(args);
    videoChannel->renderFrame();
    return nullptr;
}

/**子线程解码 Packet*/
void VideoChannel::decodePacket() {
    LOGD("VideoChannel start to decode packet");
    AVPacket *avPacket;

    while (isPlaying) {
        //取出一个数据包
        int ret = packets.pop(avPacket);
        if (!isPlaying) {
            break;
        }
        if (!ret) {
            //取不到就继续
            continue;
        }
        //FFmeng3.x 后 avcodec_decode_video2 被 avcodec_send_packet 和 avcodec_receive_frame 函数取代。
        //把包丢给解码器
        ret = avcodec_send_packet(avCodecContext, avPacket);
        releaseAVPacket(&avPacket);

        /*AVERROR(EAGAIN): input is not accepted in the current state - user must read output with avcodec_receive_frame()
         * (once all output is read, the packet should be resent, and the call will not fail with EAGAIN).*/
        if (ret == AVERROR(EAGAIN)) {
            //avcodec_send_packet 方法内部的缓冲区已经满了，我们需要使用 avcodec_receive_frame 来读取缓冲区中的数据，以便让其腾出空间。
        } else if (ret < 0/*failed*/) {
            break;
        }

        /*代表一个帧，一个画面*/
        AVFrame *avFrame = av_frame_alloc();
        ret = avcodec_receive_frame(avCodecContext, avFrame);
        /*AVERROR(EAGAIN): output is not available in this state - user must try to send new input*/
        if (ret == AVERROR(EAGAIN)) {
            //数据不够，继续send
            //这里的 avFrame 是否应该释放掉？
            continue;
        }
        if (ret != 0) {
            break;
        }
        frames.push(avFrame);
    }//while ending

    //对应 isPlaying 判断时，如果 break，会直接到这里，也需要释放一次。
    releaseAVPacket(&avPacket);
    LOGD("VideoChannel decoding packet end up");
}

/**子线程：渲染视频*/
void VideoChannel::renderFrame() {
    LOGD("VideoChannel start to render frame");
    //tips：下面两个方法这么多参数不懂怎么办？看 doc 中提供的示例。

    //颜色空间转换：原始数据 YUV420  --> RGBA
    //我们不关心原始数据格式，借助 swsacle 来帮我们做转换
    swsContext = sws_getContext(
            avCodecContext->width, avCodecContext->height, //原始宽高
            avCodecContext->pix_fmt,//格式
            avCodecContext->width, avCodecContext->height,//目标宽高
            AV_PIX_FMT_RGBA,//目标格式
            SWS_BILINEAR,//算法
            nullptr,
            nullptr,
            nullptr
    );

    AVFrame *avFrame = nullptr;
    uint8_t *dst_data[4]; //指针数组
    int dst_linesize[4];//
    //初始化一个图像
    av_image_alloc(dst_data, dst_linesize, avCodecContext->width, avCodecContext->height, AV_PIX_FMT_RGBA, 1);

    while (isPlaying) {
        int ret = frames.pop(avFrame);
        if (!isPlaying) {
            break;
        }
        if (!ret) {
            continue;
        }

        sws_scale(
                swsContext,
                reinterpret_cast<const uint8_t *const *>(avFrame->data),//源数据容器
                avFrame->linesize,//原始行 size，步长，即表示每一行存放的字节长度
                0,//要处理的源图像区域Y轴起始位置，全图则传 0 即可
                avCodecContext->height,//图像的高
                dst_data,//（出参）目标数据容器
                dst_linesize//（出参）目标数据容器每一行存放的字节长度
        );

        if (renderFrameCallback) {
            renderFrameCallback(dst_data[0], dst_linesize[0], avCodecContext->width, avCodecContext->height);
        }
        releaseAVFrame(&avFrame);
    }
    av_freep(&dst_data[0]);
    releaseAVFrame(&avFrame);

    LOGD("VideoChannel rendering frame ends up");
}

void VideoChannel::setRenderFrameCallback(RenderFrameCallback renderFrameCallback) {
    this->renderFrameCallback = renderFrameCallback;
}
