#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode

NN="`cat $NN_FILE |sort -n | uniq | tr '\n' ' '|sed 's/ *$//'`"
DN="`cat $DN_FILE |sort -n | uniq | tr '\n' ' '|sed 's/ *$//'`"

echo -e "Install Hadoop Service on namenodes"
for node in $NN ;do
    echo -e "Install Hadoop on $node"
    ssh $node "yum install -y hadoop-hdfs-namenode hadoop-mapreduce-historyserver hadoop-yarn-resourcemanager hive-metastore zookeeper-server snappy snappy-devel --nogpgcheck"
    echo -e
done

echo -e "[INFO]:Install Hadoop Service on datanodes"
for node in $DN ;do
    echo -e "Install Hadoop on $node"
    ssh $node "yum install -y hadoop-hdfs-datanode hadoop-yarn-nodemanager hive-server2 hive-hbase zookeeper-server hbase-master hbase-regionserver snappy snappy-devel --nogpgcheck"
    echo -e
done

sh $PROGDIR/bin/config_hadoop.sh