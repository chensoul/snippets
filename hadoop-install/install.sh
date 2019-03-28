#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";  exit 1
fi

# Begin
echo ""
echo "[INFO]:Install JavaChen(R) Distribution for Apache Hadoop* Software..."
echo "[INFO]:Manager is `hostname -f`, Time is `date +'%F %T'`, TimeZone is `date +'%Z %:z'`"
echo ""

sh $PROGDIR/bin/config_cluster.sh
sh $PROGDIR/bin/install_hadoop.sh
sh $PROGDIR/bin/config_hadoop.sh
sh $PROGDIR/bin/install_postgres.sh

sh $PROGDIR/script/cluster.sh hive stop
sh $PROGDIR/script/cluster.sh hbase stop
sh $PROGDIR/script/cluster.sh zookeeper stop
sh $PROGDIR/script/cluster.sh hadoop stop

sh $PROGDIR/bin/format_hadoop.sh

sh $PROGDIR/script/cluster.sh hadoop-hdfs start
#sh $PROGDIR/script/cluster.sh zookeeper start
#sh $PROGDIR/script/cluster.sh hbase start
#sh $PROGDIR/script/cluster.sh hive start

echo "[INFO]:Install hadoop on cluster complete!"
