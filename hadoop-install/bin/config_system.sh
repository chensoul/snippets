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

echo -e "Disable firewalls"
setenforce 0  >/dev/null 2>&1
sed -i "s/.*SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
systemctl disable firewalld
systemctl stop firewalld

echo "Disable IPv6"
cat > /etc/sysctl.conf <<EOF
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
EOF
sysctl -p

echo -e  "Set hostname"
yum install net-tools bind-utils -y
hostnamectl set-hostname $HOSTNAME
cat > /etc/sysconfig/network<<EOF
HOSTNAME=$HOSTNAME
EOF
##ifconfig |grep -B1 broadcast
##host -v -t A $HOSTNAME

echo -e "Set locale and timezone"
#yum groupinstall "fonts" -y
yum install glibc-common -y
cat > /etc/locale.conf <<EOF
LANG="zh_CN.UTF-8"
LC_CTYPE=zh_CN.UTF-8
LC_ALL=zh_CN.UTF-8
EOF

cat > /etc/sysconfig/i18n <<EOF
LANG="zh_CN.UTF-8"
LC_ALL="zh_CN.UTF-8"
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
[ ! -f ~/.ssh/id_rsa.pub ] && (yes|ssh-keygen -f ~/.ssh/id_rsa -t rsa -N "") && ( chmod 600 ~/.ssh/id_rsa.pub ) && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
addline "StrictHostKeyChecking no" ~/.ssh/config
addline "UserKnownHostsFile /dev/null" ~/.ssh/config
addline "LogLevel ERROR" ~/.ssh/config

echo -e "Config system params"
sysctl -w vm.swappiness=0 >/dev/null
echo vm.swappiness = 0 >> /etc/sysctl.conf

#解决透明大页面问题
echo "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag" >/etc/rc.local
echo "echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled" >/etc/rc.local

#设置文件打开数
rst=`grep "^fs.file-max" /etc/sysctl.conf`
if [ "x$rst" = "x" ] ; then
	echo "fs.file-max = 727680" >> /etc/sysctl.conf || exit $?
else
	sed -i "s:^fs.file-max.*:fs.file-max = 727680:g" /etc/sysctl.conf
fi

addline "*	soft		nofile	327680" /etc/security/limits.conf
addline "*	hard	    nofile	327680" /etc/security/limits.conf
addline "root	soft	nofile	327680" /etc/security/limits.conf
addline "root	hard	nofile	327680" /etc/security/limits.conf

curuser=`whoami`
for user in hdfs mapred hbase zookeeper hive impala flume $curuser ;do
    addline "$user	soft	nproc	131072" /etc/security/limits.conf
    addline "$user	hard	nproc	131072" /etc/security/limits.conf
done

#设置时钟同步
yum install -y ntp
sed -i "/^server/ d" /etc/ntp.conf
cat << EOF | sudo tee -a /etc/ntp.conf
server ntp1.aliyun.com
server ntp2.aliyun.com
server ntp3.aliyun.com
server ntp4.aliyun.com
EOF
sudo systemctl start ntpd
sudo systemctl enable ntpd
ntpdate -u ntp1.aliyun.com
hwclock --systohc

#配置cdh yum源
echo -e "Create cdh yum repos"
cat > /etc/yum.repos.d/cdh6.repo  <<EOF
[cloudera-cdh]
name=Cloudera's Distribution for Hadoop, Version 6
baseurl=https://archive.cloudera.com/cdh6/6.2.0/redhat7/yum/
gpgkey = https://archive.cloudera.com/cdh6/6.2.0/redhat7/yum/RPM-GPG-KEY-cloudera
enabled=1
gpgcheck = 0
EOF

echo -e "Install JDK"
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
cat << EOF | sudo tee -a /etc/profile
export JAVA_HOME=/usr/lib/jvm/java
export CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/jre/lib:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin:\$PATH
EOF
source /etc/profile


