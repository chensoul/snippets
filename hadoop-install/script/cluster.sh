#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode
ALL="`cat $NN_FILE $DN_FILE |sort -n | uniq | tr '\n' ' '|sed 's/ *$//'`"

for node in $ALL ; do
	ssh $node 'for src in `ls /etc/init.d|grep '$1'`;do echo -e "$src '$2' on '$node'";service $src '$2'; done'
    echo -e
done
