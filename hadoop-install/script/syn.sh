#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode
ALL="`cat $NN_FILE $DN_FILE |sort -n | uniq | tr '\n' ' '| sed 's/ *$//'`"

#1 获取输入参数个数，如果没有参数，直接退出
pcount=$#
if((pcount==0)); then
    echo no args;
    exit;
fi

#2 获取文件名称
p1=$1
fname=`basename $p1`

#3 获取上级目录到绝对路径
pdir=`cd -P $(dirname $p1); pwd`

#4 获取当前用户名称
user=`whoami`

#5 循环
for node in $ALL;do
    echo ---------------$node ----------------
    rsync -rvl $pdir/$fname $user@$node:$pdir
done
