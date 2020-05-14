#ifndef DNFFMPEGPLAYER_DNFFMPEG_H
#define DNFFMPEGPLAYER_DNFFMPEG_H

/*在头文件中进行声明，在 cpp 文件中进行实现。*/
class DNFFmpeg {

public:
    DNFFmpeg(const char *dataSource);

    ~DNFFmpeg();

    void prepare();

    void _prepare();

private:
    char *dataSource;
};

#endif //DNFFMPEGPLAYER_DNFFMPEG_H
