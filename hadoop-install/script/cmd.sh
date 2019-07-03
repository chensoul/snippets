#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"


NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode
ALL="`cat $NN_FILE $DN_FILE |sort -n | uniq | tr '\n' ' '| sed 's/ *$//'`"

pcount=$#
if((pcount==0));then
        echo no args;
        exit;
fi

for node in $ALL;do
    echo ---------------$node ----------------
    ssh root@$node $1
done
