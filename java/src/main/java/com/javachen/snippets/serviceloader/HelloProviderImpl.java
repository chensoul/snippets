package com.javachen.snippets.serviceloader;

/**
 * @author <a href="mailto:june.chan@foxmail.com">june</a>
 * @date 2014-10-13 10:43.
 */
public class HelloProviderImpl extends HelloProvider {

    @Override
    public String getMessage() {
        return this.toString();
    }
}