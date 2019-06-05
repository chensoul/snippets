#!/bin/sh
readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

#ps -ef|grep zookeeper|grep QuorumPeerMain|awk '{print $2}'|xargs kill -9
NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode
ALL="`cat $NN_FILE $DN_FILE |sort -n | uniq | tr '\n' ' '| sed 's/ *$//'`"

HADOOP_TMP_DIR=/var/hadoop


if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";   exit 1
fi

myid=0
for server in $ALL ;do
    myid=`expr $myid + 1`
    echo -e "Init hadoop data dictionary on $server ..."

    ssh -q $server  "
        echo -e "remove $HADOOP_TMP_DIR on $server ..."

        rm -rf $HADOOP_TMP_DIR
        mkdir -p $HADOOP_TMP_DIR/dfs/{dn,nn,namesecondary}
        chown -R hdfs:hdfs $HADOOP_TMP_DIR/dfs
        chmod -R 700 $HADOOP_TMP_DIR/dfs/

        #http://archive.cloudera.com/cdh4/cdh/4/hadoop/hadoop-project-dist/hadoop-hdfs/ShortCircuitLocalReads.html
        rm -rf /var/run/hadoop-hdfs/*   && chown -R hdfs:hdfs /var/run/hadoop-hdfs/

        mkdir -p $HADOOP_TMP_DIR/{nm-local-dir,userlogs}
        chown -R yarn:yarn $HADOOP_TMP_DIR/{nm-local-dir,userlogs}

        sudo -u hive touch /var/lib/hive/.hivehistory
        ln -fs `ls /usr/lib/hive/lib/hive-hbase-handler*|head -n 1` /usr/lib/hive/lib/hive-hbase-handler.jar

        mkdir -p /var/hbase
        chown -R hbase:hbase /var/hbase
        chmod -R 700 /var/hbase

        mkdir -p /usr/lib/hbase/lib/native/Linux-amd64-64/
        ln -fs /usr/lib64/libsnappy.so /usr/lib/hbase/lib/native/Linux-amd64-64/

        echo -e "init zookeeper on $server ..."
        service zookeeper-server stop

        rm -rf /var/lib/zookeeper && mkdir /var/lib/zookeeper
        chown -R zookeeper:zookeeper /var/lib/zookeeper && chmod -R 700 /var/lib/zookeeper

        service zookeeper-server init --myid=$myid >/dev/null 2>&1
    "
done

echo -e "Format hadoop cluster"
service hadoop-hdfs-namenode stop
sleep 3
su -s /bin/bash hdfs -c 'yes Y | hdfs namenode -format'

echo "Start hadoop-hdfs-namenode service ..."
service hadoop-hdfs-namenode start
sleep 10

