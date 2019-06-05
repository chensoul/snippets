#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

PASSWORD="redhat"
HOSTNAME=`hostname -f`

NN_FILE=$PROGDIR/conf/namenode
DN_FILE=$PROGDIR/conf/datanode
ALL="`cat $NN_FILE $DN_FILE |sort -n | uniq | tr '\n' ' '| sed 's/ *$//'`"
CLIENTS="`cat $DN_FILE | sort -n | uniq |grep -v $HOSTNAME| tr '\n' ' '|sed 's/ *$//'`"

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";  exit 1
fi

# # Begin
# echo ""
# echo "[INFO]:Install JavaChen(R) Distribution for CDH Hadoop Software..."
# echo "[INFO]:Manager is $HOSTNAME, Time is `date +'%F %T'`, TimeZone is `date +'%Z %:z'`"
# echo ""

# # 先配置管理节点到其他节点的无密码登陆
# echo -e "Config ssh nopassword login"
# for node in $ALL ;do
#     "Config ssh nopassword login for node $node"
#     $PROGDIR/bin/ssh_nopassword.expect $node $PASSWORD
# done

# # 配置时钟同步
# echo "Config npt service on $HOSTNAME"
# cat > /etc/ntp.conf  <<EOF
# restrict default ignore   //默认不允许修改或者查询ntp,并且不接收特殊封包
# restrict 127.0.0.1        //给于本机所有权限
# restrict 192.168.56.0 mask 255.255.255.0 notrap nomodify  //给于局域网机的机器有同步时间的权限
# server  127.127.1.1     # local clock
# driftfile /var/lib/ntp/drift
# fudge   127.127.1.0 stratum 10
# EOF
# chkconfig ntpd on && service ntpd restart  >/dev/null 2>&1

# for node in $CLIENTS ;do
#     echo -e "Run config_system.sh for node $node"
#     ssh $node '
#     service ntpd restart >/dev/null 2>&1

#     echo "Waiting for [`hostname -f`] to update time and timezone to ['$HOSTNAME']..."

#     if service ntpd status >/dev/null 2>&1; then
#         service ntpd stop >/dev/null 2>&1
#     fi

#     waiting_time=30
#     while ! ntpdate '$HOSTNAME' 2>&1 ; do
#         if [ $waiting_time -eq 0 ]; then
#             echo "[ERROR]: Please check whether the ntpd service is running on ntp server '$HOSTNAME'."
#             exit 1
#         fi

#         mod=`expr $waiting_time % 3`
#         if [[ $mod -eq 0 ]]; then
#             echo "."
#         fi

#         sleep 1
#         let waiting_time=$waiting_time-1
#     done

#     for x in 1 2 3 4 5 ; do
#         echo -n "" ; ntpdate '$HOSTNAME'; sleep 1
#     done
#     hwclock --systohc || true
# '
# done


# 依次配置每个节点
for node in $ALL ;do
    echo -e "Config node $node"
    ssh $node "`cat bin/config_system.sh`"
    echo -e
done
