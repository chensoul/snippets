#!/bin/sh

if [ $# != 1 ]; then
	echo -e "USAGE:\n\t./config_yum_server.sh selected_ip";	exit 1
fi

SCRIPT_DIR=`dirname $0`
server_ip=$1

echo -e "[INFO]:Config yum for manager"

function backup_repo {
	cd /etc/yum.repos.d
	if ls *.repo >/dev/null 2>&1; then
		for file in `ls *.repo`
		do
			mv $file $file.bak -f
		done
	fi
	cd - >/dev/null
}

function clean_repo_file {
	echo -e "As recommended, the repo files in /etc/yum.repos.d need to be removed."
	echo "Please make sure these files are correct if you want to keep them."

	flag="undef"
	while [ "$flag" != "y" -a "$flag" != "n" ]
	do
		read -p "Remove or no......[y|n]: " flag
		if [ "$flag" == "n" ]; then
			return 0
		fi
		backup_repo
	done
}

function select_repo {
	REPO=$1
	echo -e "\nA $REPO yum repository is needed for Hadoop Installation."
	flag="undef"
	while [ "$flag" != "y" -a "$flag" != "n" ]
	do
		read -p "Create or no...[y|n]: " flag
		if [ "$flag" == "n" ]; then
			return 0
		fi
		if [ "$flag" == "y" ]; then
			read -p "Please input URL for $REPO: " repourl
			echo -e "[$REPO]\nname = $REPO packages\nbaseurl = $repourl\nproxy = _none_\ngpgcheck = 0" > /etc/yum.repos.d/$REPO.repo
			yum clean all > /dev/null 2>&1
			if ! yum install vsftpd -q -y; then
				echo "Couldn't find vsftpd packages. Given $REPO repository unavailable! "
				flag="undef"
			fi
		fi
	done
}

clean_repo_file
select_repo os
select_repo edh

service vsftpd restart
chkconfig --add vsftpd >/dev/null
chkconfig vsftpd on >/dev/null
