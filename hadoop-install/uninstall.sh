#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

if [ $# == 0 ]; then
  echo "USAGE:
  ./uninstall.sh ALL|all
  ./uninstall.sh node1 node2 node3 ...
  "; exit 1;
fi

function continue_ask {
	continue_flag="undef"
	while [ "$continue_flag" != "yes" -a "$continue_flag" != "no" ]
	do
		echo -n "[INFO]:Type yes to continue or no to exit uninstallation...[yes|no]: "
		read continue_flag
		if [ "$continue_flag" == "no" ]; then
		  	return 1
		fi
	done
	return 0
}

NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode
ALL="`cat $NN_FILE $DN_FILE |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'`"

if [ "$1" == "ALL" ] || [ "$1" == "all" ]; then
	continue_ask
	NODES="`cat $NN_FILE $DN_FILE |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'`"
else
	NODES=$*
	continue_ask
fi

pssh -i -H $NODES "`cat $PROGDIR/bin/remove_node.sh` "
