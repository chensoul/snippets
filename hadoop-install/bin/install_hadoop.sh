#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode

echo "[INFO]:Install hadoop on namenode"
pssh -P -i -h $NN_FILE "yum install -y hadoop-debuginfo hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode \
 		hadoop-mapreduce-historyserver hadoop-yarn-resourcemanager hive-metastore
"

echo "[INFO]:Install hadoop on datanode"
pssh -P -i -h  $DN_FILE "yum install -y hadoop-debuginfo hadoop-hdfs-datanode hadoop-yarn-nodemanager hive-server2 hive-hbase zookeeper-server hbase-master hbase-regionserver
"
