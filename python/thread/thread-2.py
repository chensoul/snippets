#!/usr/bin/env python
# -*- coding: utf-8 -*-

from threading import Thread
import time

#继承父类threading.Thread
class myThread(Thread):

    def __init__(self, name, delay):
        Thread.__init__(self)
        self.name = name
        self.delay = delay

    def run(self):                   #把要执行的代码写到run函数里面 线程在创建后会直接运行run函数
        print "Starting " + self.name
        print_time(self.name, self.delay, 5)
        print "Exiting " + self.name

def print_time(threadName, delay, counter):
    while counter:
        time.sleep(delay)
        print "%s: %s" % (threadName, time.ctime(time.time()))
        counter -= 1

# 创建新线程
thread1 = myThread("Thread-1", 1)
thread2 = myThread("Thread-2", 2)

# 开启线程
thread1.start()
thread2.start()

print "Exiting Main Thread"
