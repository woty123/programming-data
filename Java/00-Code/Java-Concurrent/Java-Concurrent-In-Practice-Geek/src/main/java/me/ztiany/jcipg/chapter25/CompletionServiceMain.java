package me.ztiany.jcipg.chapter25;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * @author Ztiany
 * Email ztiany3@gmail.com
 * Date 2020/1/3 9:59
 */
public class CompletionServiceMain {

    public static void main(String... args) throws ExecutionException, InterruptedException {
        sample1();
        sample2();
    }

    private static void sample2() throws InterruptedException {
        // 创建线程池
        ExecutorService executor = Executors.newFixedThreadPool(3);
        // 异步向电商S1询价
        Future<String> f1 = executor.submit(CompletionServiceMain::getPriceByS1);
        // 异步向电商S2询价
        Future<String> f2 = executor.submit(CompletionServiceMain::getPriceByS2);
        // 异步向电商S3询价
        Future<String> f3 = executor.submit(CompletionServiceMain::getPriceByS3);
        // 创建阻塞队列
        BlockingQueue<String> bq = new LinkedBlockingQueue<>();
        //电商S1报价异步进入阻塞队列
        executor.execute(() -> {
            try {
                bq.put(f1.get());
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }
        });
        //电商S2报价异步进入阻塞队列
        executor.execute(() -> {
            try {
                bq.put(f2.get());
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }
        });
        //电商S3报价异步进入阻塞队列
        executor.execute(() -> {
            try {
                bq.put(f3.get());
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }
        });

        //异步保存所有报价
        for (int i = 0; i < 3; i++) {
            String r = bq.take();
            executor.execute(() -> save(r));
        }
    }

    private static void sample1() throws ExecutionException, InterruptedException {
        // 创建线程池
        ExecutorService executor = Executors.newFixedThreadPool(3);
        // 异步向电商S1询价
        Future<String> f1 = executor.submit(CompletionServiceMain::getPriceByS1);
        // 异步向电商S2询价
        Future<String> f2 = executor.submit(CompletionServiceMain::getPriceByS2);
        // 异步向电商S3询价
        Future<String> f3 = executor.submit(CompletionServiceMain::getPriceByS3);

        // 获取电商S1报价并保存
        final String r1 = f1.get();
        executor.execute(() -> save(r1));

        // 获取电商S2报价并保存
        final String r2 = f2.get();
        executor.execute(() -> save(r2));

        // 获取电商S3报价并保存
        final String r3 = f3.get();
        executor.execute(() -> save(r3));
    }

    private static String getPriceByS1() throws InterruptedException {
        Thread.sleep(1000);
        return "P1";
    }

    private static String getPriceByS2() {
        return "P2";
    }

    private static String getPriceByS3() {
        return "P3";
    }

    private static void save(String s) {
        System.out.println("save: " + s);
    }

}
