#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

HOSTNAME=`hostname -f`

NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode
CLIENTS="`cat $DN_FILE | sort -n | uniq |grep -v $HOSTNAME| tr '\n' ' '|  sed 's/,$//'`"

if [ -s "$CLIENTS" ];then
	exit
fi

pscp -H "$CLIENTS" /etc/localtime /etc/localtime >/dev/null 2>&1
pscp -H "$CLIENTS" /etc/sysconfig/clock /etc/sysconfig/clock >/dev/null 2>&1
\cp $PROGDIR/../template/ntp.conf /etc/ntp.conf
sed -i "/^driftfile/ s:^driftfile.*:driftfile /var/lib/ntp/ntp.drift:g" /etc/ntp.conf

echo "[INFO]:Start ntpd service on $HOSTNAME"
service ntpd restart >/dev/null 2>&1

pssh -i -H "$CLIENTS" '
	echo "Waiting for [`hostname -f`] to update time and timezone to ['$HOSTNAME']..."

	if service ntpd status >/dev/null 2>&1; then
		service ntpd stop >/dev/null 2>&1
	fi

	waiting_time=30
	while ! ntpdate '$HOSTNAME' 2>&1 ; do
		if [ $waiting_time -eq 0 ]; then
		    echo "[ERROR]: Please check whether the ntpd service is running on ntp server '$HOSTNAME'."
		    exit 1
		fi

		mod=`expr $waiting_time % 3`
		if [[ $mod -eq 0 ]]; then
		    echo "."
		fi

		sleep 1
		let waiting_time=$waiting_time-1
	done

	for x in 1 2 3 4 5 ; do
		echo -n "" ; ntpdate '$HOSTNAME'; sleep 1
	done
	hwclock --systohc || true
'
