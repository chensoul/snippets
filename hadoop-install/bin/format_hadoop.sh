#!/bin/sh

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";   exit 1
fi

#ps -ef|grep zookeeper|grep QuorumPeerMain|awk '{print $2}'|xargs kill -9

echo "[INFO]:Format hadoop cluster"
su -s /bin/bash hdfs -c 'yes Y | hadoop namenode -format' >/dev/null 2>&1

echo "[INFO]:Start hadoop-hdfs-namenode service ..."
service hadoop-hdfs-namenode start >/dev/null 2>&1
sleep 10

echo "[INFO]:create hdfs dir ..."
su -s /bin/bash hdfs -c 'hadoop fs -chmod 755 /'

while read dir user group perm
do
  su -s /bin/bash hdfs -c "hadoop fs -mkdir -p $dir;hadoop fs -chmod -R $perm $dir;hadoop fs -chown $user:$group $dir" >/dev/null 2>&1
  echo "[INFO]:mkdir $dir"
done << EOF
/tmp hdfs hadoop 1777
/yarn/apps yarn mapred 1777
/user hdfs hadoop 755
/user/root root hadoop 755
/user/hive hive hadoop 777
/user/hive/warehouse hive hadoop 1777
/user/history mapred hadoop 1777
/user/history/done mapred hadoop 750
/user/history/done_intermediate mapred hadoop 1777
/hbase hbase hadoop 755
EOF
