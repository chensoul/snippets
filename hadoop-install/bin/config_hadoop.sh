#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode
ALL="`cat $NN_FILE $DN_FILE |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'`"
NN=`cat $NN_FILE |tr '\n' ','|  sed 's/,$//'`

ZK_HOSTNAME=`cat $DN_FILE |tr '\n' ','|  sed 's/,$//'`

echo "[INFO]:Resolve hadoop conf"
for srv in hadoop hbase hive zookeeper ; do
	\cp $PROGDIR/../template/${srv}/* /etc/${srv}/conf/
	sed -i "s|localhost|$NN|g" /etc/${srv}/conf/*
done

\cp $PROGDIR/../template/impala /etc/default/impala
sed -i "s|localhost|$NN|g" /etc/default/impala
sed -i "s|zkhost|$ZK_HOSTNAME|g" /etc/hbase/conf/hbase-site.xml

echo "[INFO]:Syn hadoop conf to every nodes"
sh $PROGDIR/../script/syn.sh /etc/hadoop/conf /etc/hadoop >/dev/null 2>&1
sh $PROGDIR/../script/syn.sh /etc/hive/conf /etc/hive >/dev/null 2>&1
sh $PROGDIR/../script/syn.sh /etc/hbase/conf /etc/hbase >/dev/null 2>&1
sh $PROGDIR/../script/syn.sh /etc/zookeeper/conf /etc/zookeeper >/dev/null 2>&1
sh $PROGDIR/../script/syn.sh /etc/default/impala /etc/default/impala >/dev/null 2>&1

chmod 755 $PROGDIR/../template/postgresql-9.1-901.jdbc4.jar
sh $PROGDIR/../script/syn.sh $PROGDIR/../template/postgresql-9.1-901.jdbc4.jar /usr/lib/hive/lib/postgresql-jdbc.jar >/dev/null 2>&1

myid=0
for server in $ALL ;do
	myid=`expr $myid + 1`
	echo "[INFO]:Init hadoop data dictionary on $server ..."

	ssh -q root@$server  "
		rm -rf /data/dfs
		mkdir -p /data/dfs/{dn,nn,namesecondary} /data/yarn/{local,logs}
		chown -R hdfs:hdfs /data/dfs && chmod -R 700 /data/dfs/ && chown -R yarn:yarn /data/yarn
		#http://archive.cloudera.com/cdh4/cdh/4/hadoop/hadoop-project-dist/hadoop-hdfs/ShortCircuitLocalReads.html
		rm -rf /var/run/hadoop-hdfs/*	&& chown -R hdfs:hdfs /var/run/hadoop-hdfs/

		sudo -u hive touch /var/lib/hive/.hivehistory
		ln -fs `ls /usr/lib/hive/lib/hive-hbase-handler*|head -n 1` /usr/lib/hive/lib/hive-hbase-handler.jar

		mkdir -p /usr/lib/hbase/lib/native/Linux-amd64-64/
		ln -fs /usr/lib64/libsnappy.so /usr/lib/hbase/lib/native/Linux-amd64-64/

		service zookeeper-server stop
		service zookeeper-server stop
		pkill -9 zookeeper-server

		rm -rf /var/lib/zookeeper && mkdir /var/lib/zookeeper
		chown -R zookeeper:zookeeper /var/lib/zookeeper && chmod -R 700 /var/lib/zookeeper

		service zookeeper-server init --myid=$myid >/dev/null 2>&1
	"
done
