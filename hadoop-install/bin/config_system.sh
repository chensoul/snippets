#!/bin/sh

function addline {
    line=$1
    file=$2
    tempstr=`grep "$line" $file  2>/dev/null`
    if [ "$tempstr" == "" ]; then
        echo "$line" >>$file
    fi
}

HOSTNAME=`hostname -f`

echo -e "Remove unused logs"
rm -rf /root/*.log /root/*.cfg

#配置yum源
echo -e "Setup yum repos"
rm -rf /etc/yum.repos.d/*
yum clean all >/dev/null 2>&1
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo >/dev/null 2>&1
cat > /etc/yum.repos.d/cdh6.repo  <<EOF
[cloudera-cdh]
name=Cloudera's Distribution for Hadoop, Version 6
baseurl=https://archive.cloudera.com/cdh6/6.2.0/redhat7/yum/
gpgkey = https://archive.cloudera.com/cdh6/6.2.0/redhat7/yum/RPM-GPG-KEY-cloudera
enabled=1
gpgcheck = 0
EOF

echo -e "Install some rpms"
yum install -y wget vim java-1.8.0-openjdk java-1.8.0-openjdk-devel expect ntp >/dev/null 2>&1

echo -e "Disable firewalls"
[ -f /etc/init.d/iptables ] && FIREWALL="iptables"
[ -f /etc/init.d/SuSEfirewall2_setup ] && FIREWALL="SuSEfirewall2_setup"
[ -f /etc/init.d/boot.apparmor ] && SELINUX="boot.apparmor"
[ -f /usr/sbin/setenforce ] && SELINUX="selinux"
service $FIREWALL stop >/dev/null 2>&1
chkconfig $FIREWALL off > /dev/null 2>&1

if [ $SELINUX == "selinux" ]; then
    sed -i "s/.*SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
    setenforce 0  >/dev/null 2>&1
elif [ $SELINUX == "boot.apparmor" ]; then
    service boot.apparmor stop >/dev/null 2>&1
    chkconfig boot.apparmor off >/dev/null 2>&1
fi

echo "Disable IPv6"
cat > /etc/sysctl.conf <<EOF
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
EOF

echo -e "Update /etc/hosts"
cat > /etc/hosts <<EOF
127.0.0.1       localhost
192.168.56.121 cdh1 cdh1.example.com
192.168.56.122 cdh2 cdh2.example.com
192.168.56.123 cdh3 cdh3.example.com
EOF

echo -e  "Set hostname"
hostnamectl set-hostname $HOSTNAME
cat > /etc/sysconfig/network<<EOF
HOSTNAME=$HOSTNAME
EOF
yum install net-tools bind-utils -y >/dev/null 2>&1
##ifconfig |grep -B1 broadcast
##host -v -t A $HOSTNAME

echo -e "Set locale and timezone"
#yum groupinstall "fonts" -y
cat > /etc/locale.conf <<EOF
LANG="zh_CN.UTF-8"
LC_CTYPE=zh_CN.UTF-8
LC_ALL=zh_CN.UTF-8
EOF
source   /etc/locale.conf
sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

echo -e "Setup nameservers"
# http://ithelpblog.com/os/linux/redhat/centos-redhat/howto-fix-couldnt-resolve-host-on-centos-redhat-rhel-fedora/
# http://stackoverflow.com/a/850731/1486325
echo "nameserver 8.8.8.8" | tee -a /etc/resolv.conf
echo "nameserver 8.8.4.4" | tee -a /etc/resolv.conf

echo -e "Generate root ssh"
[ ! -d ~/.ssh ] && ( mkdir ~/.ssh ) && ( chmod 600 ~/.ssh )
[ ! -f ~/.ssh/id_rsa.pub ] && (yes|ssh-keygen -f ~/.ssh/id_rsa -t rsa -N "") && ( chmod 600 ~/.ssh/id_rsa.pub )
addline "StrictHostKeyChecking no" ~/.ssh/config
addline "UserKnownHostsFile /dev/null" ~/.ssh/config
addline "LogLevel ERROR" ~/.ssh/config

echo -e "Config system params"
sysctl -w vm.swappiness=0 >/dev/null
echo "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag" >/etc/rc.local
rst=`grep "^fs.file-max" /etc/sysctl.conf`
if [ "x$rst" = "x" ] ; then
	echo "fs.file-max = 727680" >> /etc/sysctl.conf || exit $?
else
	sed -i "s:^fs.file-max.*:fs.file-max = 727680:g" /etc/sysctl.conf
fi

addline "*	soft		nofile	327680" /etc/security/limits.conf
addline "*	hard	nofile	327680" /etc/security/limits.conf
addline "root	soft		nofile	327680" /etc/security/limits.conf
addline "root	hard	nofile	327680" /etc/security/limits.conf

curuser=`whoami`
for user in hdfs mapred hbase zookeeper hive impala flume $curuser ;do
    addline "$user	soft		nproc	131072" /etc/security/limits.conf
    addline "$user	hard	nproc	131072" /etc/security/limits.conf
done

# echo -e "[INFO]:Config JAVA_HOME on `hostname -f`  ..."

# echo "
#  # .bashrc
#  # Source global definitions
#  if [ -f /etc/bashrc ]; then
#     . /etc/bashrc
#  fi
# umask 022
# " > ~/.bashrc

# if [ -f ~/.bashrc ] ; then
#     sed -i '/^export[[:space:]]\{1,\}JAVA_HOME[[:space:]]\{0,\}=/d' ~/.bashrc
#     sed -i '/^export[[:space:]]\{1,\}CLASSPATH[[:space:]]\{0,\}=/d' ~/.bashrc
#     sed -i '/^export[[:space:]]\{1,\}PATH[[:space:]]\{0,\}=/d' ~/.bashrc
# fi

# echo "export JAVA_HOME=/usr/java/latest" >> ~/.bashrc
# echo "export CLASSPATH=.:\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar">>~/.bashrc
# echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc

# echo  "
# export HADOOP_HOME=/usr/lib/hadoop
# export HIVE_HOME=/usr/lib/hive
# export HBASE_HOME=/usr/lib/hbase
# export HADOOP_HDFS_HOME=/usr/lib/hadoop-hdfs
# export HADOOP_MAPRED_HOME=/usr/lib/hadoop-mapreduce
# export HADOOP_COMMON_HOME=\${HADOOP_HOME}
# export HADOOP_HDFS_HOME=/usr/lib/hadoop-hdfs
# export HADOOP_LIBEXEC_DIR=\${HADOOP_HOME}/libexec
# export HADOOP_CONF_DIR=\${HADOOP_HOME}/etc/hadoop
# export HDFS_CONF_DIR=\${HADOOP_HOME}/etc/hadoop
# export HADOOP_YARN_HOME=/usr/lib/hadoop-yarn
# export YARN_CONF_DIR=\${HADOOP_HOME}/etc/hadoop
# ">> ~/.bashrc

# alternatives --install /usr/bin/java java /usr/java/latest 5
# alternatives --set java /usr/java/latest

# source ~/.bash_profile
