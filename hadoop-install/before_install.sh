#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

PASSWORD="root"
HOSTNAME=`hostname -f`

NN_FILE=$PROGDIR/conf/namenode
DN_FILE=$PROGDIR/conf/datanode
ALL="`cat $NN_FILE $DN_FILE |sort -n | uniq | tr '\n' ' '| sed 's/ *$//'`"
CLIENTS="`cat $DN_FILE | sort -n | uniq |grep -v $HOSTNAME| tr '\n' ' '|sed 's/ *$//'`"

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";  exit 1
fi

# Begin
echo ""
echo "[INFO]:Install JavaChen(R) Distribution for CDH Hadoop Software..."
echo "[INFO]:Manager is $HOSTNAME, Time is `date +'%F %T'`, TimeZone is `date +'%Z %:z'`"
echo ""

#安装必须软件
yum install expect net-tools -y

# 先配置管理节点到其他节点的无密码登陆
echo -e "Config ssh nopassword login"
for node in $ALL ;do
    "Config ssh nopassword login for node $node"
    $PROGDIR/bin/ssh_nopassword.expect $node $PASSWORD
done


# 依次配置每个节点
for node in $ALL ;do
    echo -e "Config node $node"
    ssh $node "`cat bin/config_system.sh`"
    echo -e
done
