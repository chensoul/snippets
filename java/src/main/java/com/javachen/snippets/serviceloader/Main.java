package com.javachen.snippets.serviceloader;

/**
 * @author <a href="mailto:june.chan@foxmail.com">june</a>
 * @date 2014-10-13 10:43.
 */
public class Main {
    /*
     * mvn exec:rmi -Dexec.mainClass="com.javachen.snippets.serviceloader.HelloProvider"
     */
    public static void main(String[] ignored) {
        HelloProvider provider = HelloProvider.getDefault();
        System.out.println("result:"+provider.getMessage());
    }
}
