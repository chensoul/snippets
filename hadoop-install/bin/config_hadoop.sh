#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode

NN="`cat $NN_FILE |sort -n | uniq | tr '\n' ' '|sed 's/ *$//'`"
DN="`cat $DN_FILE |sort -n | uniq | tr '\n' ' '|sed 's/ *$//'`"
ZK_HOSTNAME="`cat $DN_FILE |sort -n | uniq | tr '\n' ','|sed 's/,$//'`"

HADOOP_TMP_DIR=/var/hadoop

echo "Copy hadoop template conf to /etc/*/conf"
for srv in hadoop hbase hive zookeeper ; do
	\cp $PROGDIR/../template/${srv}/* /etc/${srv}/conf/
	sed -i "s|localhost|$NN|g" /etc/${srv}/conf/*
done
sed -i "s|HADOOP_TMP_DIR|$HADOOP_TMP_DIR|g" /etc/hadoop/conf/core-site.xml
sed -i "s|localhost|$NN|g" /etc/default/impala
sed -i "s|zkhost|$ZK_HOSTNAME|g" /etc/hbase/conf/hbase-site.xml
sed -i "s|zkhost|$ZK_HOSTNAME|g" /etc/hive/conf/hive-site.xml
\cp $PROGDIR/../template/impala /etc/default/impala

echo "Syn hadoop conf to every nodes"
sh $PROGDIR/../script/syn.sh /etc/hadoop/conf /etc/hadoop >/dev/null 2>&1
sh $PROGDIR/../script/syn.sh /etc/hive/conf /etc/hive >/dev/null 2>&1
sh $PROGDIR/../script/syn.sh /etc/hbase/conf /etc/hbase >/dev/null 2>&1
sh $PROGDIR/../script/syn.sh /etc/zookeeper/conf /etc/zookeeper >/dev/null 2>&1
sh $PROGDIR/../script/syn.sh /etc/default/impala /etc/default/impala >/dev/null 2>&1

chmod 755 $PROGDIR/../template/postgresql-9.1-901.jdbc4.jar
sh $PROGDIR/../script/syn.sh $PROGDIR/../template/postgresql-9.1-901.jdbc4.jar /usr/lib/hive/lib/postgresql-jdbc.jar >/dev/null 2>&1


