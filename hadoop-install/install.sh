#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

HOSTNAME=`hostname -f`

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";  exit 1
fi

# Begin
echo ""
echo "[INFO]:Install JavaChen(R) Distribution for CDH Hadoop Software..."
echo "[INFO]:Manager is $HOSTNAME, Time is `date +'%F %T'`, TimeZone is `date +'%Z %:z'`"
echo ""


sh $PROGDIR/bin/install_hadoop.sh
sh $PROGDIR/bin/install_postgres.sh
sh $PROGDIR/bin/config_hadoop.sh

sh $PROGDIR/script/cluster.sh hive stop
sh $PROGDIR/script/cluster.sh hbase stop
sh $PROGDIR/script/cluster.sh zookeeper stop
sh $PROGDIR/script/cluster.sh hadoop stop

sh $PROGDIR/bin/format_hadoop.sh

sh $PROGDIR/after_install.sh

echo "[INFO]:Install hadoop on cluster complete!"
