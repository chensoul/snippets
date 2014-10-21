package com.javachen.snippets.threadlocal;

/**
 * @author <a href="mailto:june.chan@foxmail.com">june</a>.
 * @date 2014-10-13 11:16.
 */
public class PlayThreadLocal {

    static final ThreadLocal<Long> threadIdPool = new ThreadLocal<Long>() {
        public Long initialValue() {
            return Long.valueOf(System.nanoTime());
        }
    };

    static class MyThread extends Thread {
        public void run() {
            System.out.println(threadIdPool.get());
        }
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
        for (int i = 0; i < 10; i++) {
            Thread t = new MyThread();
            t.start();
        }
    }

}