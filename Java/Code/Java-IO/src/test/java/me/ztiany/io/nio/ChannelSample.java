package me.ztiany.io.nio;


import org.junit.Test;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;

import static me.ztiany.io.nio.Utils.close;

/*
 * 一、通道（Channel）：用于源节点与目标节点的连接。在 Java NIO 中负责缓冲区中数据的传输。Channel 本身不存储数据，因此需要配合缓冲区进行传输。
 *
 * 二、通道的主要实现类
 *
 * 	java.nio.channels.Channel 接口：
 * 		|--FileChannel
 * 		|--SocketChannel
 * 		|--ServerSocketChannel
 * 		|--DatagramChannel
 *
 * 三、获取通道
 * 1. Java 针对支持通道的类提供了 getChannel() 方法
 *
 * 		本地 IO：
 * 		    FileInputStream/FileOutputStream
 * 		    RandomAccessFile
 *
 * 		网络IO：
 * 		    Socket
 * 		    ServerSocket
 * 		    DatagramSocket
 *
 * 2. 在 JDK 1.7 中的 NIO.2 针对各个通道提供了静态方法 open()
 * 3. 在 JDK 1.7 中的 NIO.2 的 Files 工具类的 newByteChannel()
 *
 * 四、通道之间的数据传输
 *
 *      transferFrom()
 *      transferTo()
 *
 * 五、分散(Scatter)与聚集(Gather)
 *      分散读取（Scattering Reads）：将通道中的数据分散到多个缓冲区中
 *      聚集写入（Gathering Writes）：将多个缓冲区中的数据聚集到通道中
 *
 */
public class ChannelSample {

    private static final String TARGET = "file/cmde_copy.zip";
    private static final String SOURCE = "file/cmder.zip";

    //分散和聚集
    @Test
    public void testScatter() throws IOException {
        RandomAccessFile randomAccessFile = new RandomAccessFile("file/text.txt", "rw");

        //1. 获取通道
        FileChannel channel1 = randomAccessFile.getChannel();

        //2. 分配指定大小的缓冲区
        ByteBuffer buf1 = ByteBuffer.allocate(200);
        ByteBuffer buf2 = ByteBuffer.allocate(10 * 1024);

        //3. 分散读取
        ByteBuffer[] bufs = {buf1, buf2};
        channel1.read(bufs);

        for (ByteBuffer byteBuffer : bufs) {
            byteBuffer.flip();//切换到读模式
        }

        System.out.println(new String(bufs[0].array(), 0, bufs[0].limit()));
        System.out.println("-----------------");
        System.out.println(new String(bufs[1].array(), 0, bufs[1].limit()));

        //4. 聚集写入
        RandomAccessFile raf2 = new RandomAccessFile("file/text_copy.txt", "rw");
        FileChannel channel2 = raf2.getChannel();
        channel2.write(bufs);
    }


    //通道之间的数据传输(直接缓冲区)
    @Test
    public void testFileTransfer() throws IOException {
        long start = System.currentTimeMillis();

        FileChannel inChannel = FileChannel.open(Paths.get(SOURCE), StandardOpenOption.READ);
        FileChannel outChannel = FileChannel.open(Paths.get(TARGET), StandardOpenOption.WRITE, StandardOpenOption.READ, StandardOpenOption.CREATE);
        //inChannel.transferTo(0, inChannel.size(), outChannel);
        outChannel.transferFrom(inChannel, 0, inChannel.size());
        inChannel.close();
        outChannel.close();

        System.out.println("耗费时间为：" + (System.currentTimeMillis() - start));
    }

    //使用直接缓冲区完成文件的复制(内存映射文件)
    @Test
    public void testCopyFileWithDirect() {
        long start = System.currentTimeMillis();
        FileChannel inChannel = null;
        FileChannel outChannel = null;

        try {
            //获取Channel
            inChannel = FileChannel.open(Paths.get(SOURCE), StandardOpenOption.READ);
            outChannel = FileChannel.open(Paths.get(TARGET), StandardOpenOption.WRITE, StandardOpenOption.READ, StandardOpenOption.CREATE);
            //内存映射文件
            MappedByteBuffer inMappedBuf = inChannel.map(FileChannel.MapMode.READ_ONLY, 0, inChannel.size());
            MappedByteBuffer outMappedBuf = outChannel.map(FileChannel.MapMode.READ_WRITE, 0, inChannel.size());
            //直接对缓冲区进行数据的读写操作
            byte[] dst = new byte[inMappedBuf.limit()];
            inMappedBuf.get(dst);
            outMappedBuf.put(dst);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            close(inChannel);
            close(outChannel);
        }
        System.out.println("耗费时间为：" + (System.currentTimeMillis() - start));
    }

    //利用通道完成文件的复制（非直接缓冲区）
    @Test
    public void testCopyFile() {
        long start = System.currentTimeMillis();

        FileInputStream fileInputStream = null;
        FileOutputStream fileOutputStream = null;

        FileChannel inChannel = null;
        FileChannel outChannel = null;

        try {
            fileInputStream = new FileInputStream(SOURCE);
            fileOutputStream = new FileOutputStream(TARGET);
            //①获取通道
            inChannel = fileInputStream.getChannel();
            outChannel = fileOutputStream.getChannel();
            //②分配指定大小的缓冲区
            ByteBuffer buf = ByteBuffer.allocate(1024);
            //③将通道中的数据存入缓冲区中
            while (inChannel.read(buf) != -1) {
                buf.flip();//切换到读模式
                //④将缓冲区中的数据写入通道中
                outChannel.write(buf);
                buf.clear(); //清空缓冲区
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            close(outChannel);
            close(inChannel);
            close(fileOutputStream);
            close(fileInputStream);
        }
        System.out.println("耗费时间为：" + (System.currentTimeMillis() - start));
    }

    @Test
    public void copyUseByteBuffer() throws IOException {
        ByteBuffer buffer = ByteBuffer.allocateDirect(32 * 1024);
        try (FileChannel src = FileChannel.open(Paths.get(SOURCE), StandardOpenOption.READ);
             FileChannel dest = FileChannel.open(Paths.get(TARGET), StandardOpenOption.WRITE, StandardOpenOption.CREATE)) {
            while (src.read(buffer) > 0 || buffer.position() != 0) {
                buffer.flip();
                dest.write(buffer);
                buffer.compact();
            }
        }
    }

    public void mapFile() throws IOException {

        try (FileChannel channel = FileChannel.open(Paths.get("src.data"), StandardOpenOption.READ, StandardOpenOption.WRITE)) {
            MappedByteBuffer buffer = channel.map(FileChannel.MapMode.READ_WRITE, 0, channel.size());
            byte b = buffer.get(1024 * 1024);
            buffer.put(5 * 1024 * 1024, b);
            buffer.force();
        }

    }

}