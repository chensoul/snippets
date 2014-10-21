package com.javachen.snippets.serviceloader;

import java.util.ServiceLoader;

/**
 * @author <a href="mailto:june.chan@foxmail.com">june</a>
 * @date 2014-10-13 10:42.
 */
public abstract class HelloProvider {
    public static HelloProvider getDefault() {
        ServiceLoader<HelloProvider> ldr = ServiceLoader.load(HelloProvider.class);

        for (HelloProvider provider : ldr) {
            System.out.println("found:"+provider);
        }

        for (HelloProvider provider : ldr) {
            //We are only expecting one
            return provider;
        }
        throw new Error("No HelloProvider registered");


    }

    public abstract String getMessage();



}