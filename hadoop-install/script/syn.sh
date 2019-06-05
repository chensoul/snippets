#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode
ALL="`cat $NN_FILE $DN_FILE |sort -n | uniq | tr '\n' ' '| sed 's/ *$//'`"

for node in $ALL;do
	echo -e "syn $1 from `hostname -f` to $node"
	scp -rp $1 root@$node:$2
    echo -e
done
