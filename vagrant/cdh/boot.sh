#!/usr/bin/env bash

### Set default permissions. ###
umask 0022

sudo rm -rf /root/anaconda-ks.cfg /root/install.log*

# Setup sudo to allow no-password sudo for "admin". Additionally,
# make "admin" an exempt group so that the PATH is inherited.
cp /etc/sudoers /etc/sudoers.orig
echo "root            ALL=(ALL)               NOPASSWD: ALL" >> /etc/sudoers

cat > /etc/hosts <<EOF
127.0.0.1       localhost

192.168.56.121 cdh1
192.168.56.122 cdh2
192.168.56.123 cdh3
EOF

# Set up nameservers.
# http://ithelpblog.com/os/linux/redhat/centos-redhat/howto-fix-couldnt-resolve-host-on-centos-redhat-rhel-fedora/
# http://stackoverflow.com/a/850731/1486325
echo "nameserver 8.8.8.8" | tee -a /etc/resolv.conf
echo "nameserver 8.8.4.4" | tee -a /etc/resolv.conf

### iptables ###
setenforce 0
iptables -F

### Set env ###
echo "export LC_ALL=en_US.UTF-8"  >>  /etc/profile 
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

### Update passwod for vagrant ###
echo 'redhat'|passwd root --stdin

### ssh ###
[ ! -d /root/.ssh ] && ( mkdir /root/.ssh ) && ( chmod 600 /root/.ssh  )
yes|ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ""

### yum ###

rm -rf /etc/yum.repos.d/*
cp /vagrant/*.repo /etc/yum.repos.d/

yum install vim -y
