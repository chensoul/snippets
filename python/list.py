#!/usr/bin/env python
# -*- coding: utf-8 -*-

a=[2,1,3]
b=[4,5,6]

#连接操作
print a+b

#追加
a.append(4)

print 'index of 4:', a.index(4)
a.insert(4,4)

#统计出现次数
print 'count of 4:', a.count(4)

#弹出最后一个元素
a.pop()

#删除元素4
del a[3]
a.remove(3)

#extend效率高于连接操作
a.extend(b)
print "a extend b:",a

#分片赋值
b[1:]=list('abc')
b[1:1]=['dd','ef']
del b[0]

print 'before sort,b:',b

#排序
b.reverse()
b.sort()
sorted(b)
b.sort(cmp)
b.sort(key=len,reverse=False)

print 'after sort,b:',b

print [3*x for x in a]

print [[x, x**2] for x in a]

print [3*x for x in a if x%2 ==0]

print [(x, x**2) for x in a]

vec1 = [2, 4, 6]
vec2 = [4, 3, -9]
print [x*y for x in vec1 for y in vec2]
print [vec1[i]*vec2[i] for i in range(len(vec1))]

print [str(round(355/113, i)) for i in range(1, 6)]
