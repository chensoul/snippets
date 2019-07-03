#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))


#sh $PROGDIR/bin/format_hadoop.sh

sh $PROGDIR/script/cluster.sh hadoop-hdfs-namenode start
sh $PROGDIR/script/cluster.sh hadoop-hdfs-datanode start

echo "create hdfs dir ..."
while read dir user group perm
do
    echo "mkdir $dir $user:$group $perm"
    su -s /bin/bash hdfs -c "hadoop fs -mkdir -p $dir;hadoop fs -chmod -R $perm $dir;hadoop fs -chown -R $user:$group $dir"
done << EOF
/tmp hdfs hadoop 1777
/user hdfs hadoop 777
/user/root root hadoop 777
/user/hive hive hadoop 777
/user/hive/warehouse hive hadoop 1777
/hbase hbase hadoop 755
EOF

sudo -u hdfs hadoop fs -ls -R /
