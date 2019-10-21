# nginx 推流服务器搭建（Ubuntu18.04）

## 安装  nginx 和 nginx-rtmp

- 先下载安装  nginx 和 nginx-rtmp 编译依赖工具

```shell
sudo apt-get install build-essential libpcre3 libpcre3-dev libssl-dev

sudo apt-get install zlib1g-dev
```

- 下载 nginx 和 nginx-rtmp源码（wget是一个从网络上自动下载文件的自由工具）

```Shell
# nginx 地址：http://nginx.org/en/download.html
# version：nginx-1.16.1
wget xxx
# rtmp module 地址：https://github.com/arut/nginx-rtmp-module/releases
# version：nginx-rtmp-module-1.2.1
wget xxx
```

- 安装unzip工具，解压下载的安装包

```shell
sudo apt-get install unzip
```

- 解压 nginx 和 nginx-rtmp安装包

```shell
tar -zxvf nginx-1.7.5.tar.gz
-zxvf分别是四个参数
x : 从 tar 包中把文件提取出来
z : 表示 tar 包是被 gzip 压缩过的，所以解压时需要用 gunzip 解压
v : 显示详细信息
f xxx.tar.gz :  指定被处理的文件是 xxx.tar.gz

unzip master.zip

切换到 nginx-目录
cd nginx-1.7.5
```

- 添加 nginx-rtmp 模板编译到 nginx

```shell
./configure --with-http_ssl_module --add-module=../nginx-rtmp-module-master
```

- 编译安装，编译时，在ubuntu 18 中可能会遇到类似 cc1: all warnings being treated as errors 的错误，解决方法是：打开 objs/MakeFile，删除其中的 -Werror 命令选项。

```shell
make
sudo make install
```

- 安装nginx init脚本

```shell
#下载脚本
sudo wget https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx

#修改权限
sudo chmod +x /etc/init.d/nginx

#开启启动(sudo update-rc.d 命令用于设置开机启动)
sudo update-rc.d nginx defaults
```

- 启动和停止nginx 服务，生成配置文件

```shell
sudo service nginx start
sudo service nginx stop
```

## 安装 FFmpeg

```shell
下载源码
 ./configure --disable-yasm
make
make install
```

## 配置 nginx-rtmp 服务器

```shell
打开 /usr/local/nginx/conf/nginx.conf，在末尾添加如下配置

rtmp{
    server {
        #如果你使用了防火墙，请允许端口 tcp 1935
        listen 1935;
        chunk_size 4096;

        #配置一个应用
        application live {
                    live on;
                    record off;
                    exec ffmpeg -i rtmp://localhost/live/$name -threads 1 -c:v libx264 -profile:v baseline -b:v 350K -s 640x360 -f flv -c:a aac -ac 1 -strict -2 -b:a 56k rtmp://localhost/live360p/$name;
                    }

        #配置一个应用
        application live360p {
                    live on;
                    #关闭吕录制
                    record off;
                    #允许任何人发起请求
                    allow play all;
                    }
        }
    }
}

```

保存上面配置文件，然后重新启动nginx服务：

```shell
sudo service nginx restart
```

相关测试命令：

```shell
#推流客户端

    #推流命令
    ffmpeg -re -i out.mp4 -c copy -f flv rtmp://service/live/stream_name
    #示例
    ffmpeg -re -i out.mp4 -c copy -f flv rtmp://39.108.56.76:1935/live/test
    #转发，拉取流后转发给另外一个地址
    ffmpeg -i pull_stream_address -c:a copy -c:v copy -f flv push_strem_rtmp_address
    # 示例
    ffmpeg -i rtmp://58.200.131.2:1935/livetv/hunantv -c:a copy -c:v copy -f flv rtmp://127.0.0.1:1935/test/room

#播放客户端->使用ffplay播放视频流：

    #拉流后存储到本地
    ffmpeg -i rtmp://service/live/stream_name -c copy dump.flv
    #使用 ffpaly 播放
    ffpaly rtmp://39.108.56.76:1935/live/test
```

RTMP 拉流测试地址

```log
韩国GoodTV,rtmp://mobliestream.c3tv.com:554/live/goodtv.sdp

韩国朝鲜日报,rtmp://live.chosun.gscdn.com/live/tvchosun1.stream

美国1,rtmp://ns8.indexforce.com/home/mystream

美国2,rtmp://media3.scctv.net/live/scctv_800

美国中文电视,rtmp://media3.sinovision.net:1935/live/livestream

湖南卫视,rtmp://58.200.131.2:1935/livetv/hunantv
```

## 其他参考

[Ubuntu18.04下配置Nginx+RTMP+HLS+HTTPFLV服务器，实现点播/直播/录制功能](https://www.cnblogs.com/daner1257/p/10549232.html)