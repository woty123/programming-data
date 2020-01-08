#include <iostream>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
}

using namespace std;

int main() {
    //把 所有的dll 放到 c:/windows/system32下去
    cout << av_version_info() << endl;
    avcodec_register_all();
    return 0;
}
