#!/bin/sh

rm -rf /root/original-ks.cfg

#设置root密码为root
echo 'root'|passwd root --stdin >/dev/null 2>&1

sed -i -e 's/md5/sha512/g' /etc/pam.d/password-auth
sed -i -e 's/md5/sha512/g' /etc/pam.d/system-auth

#设置hostname
hostnamectl set-hostname $2
cat > /etc/sysconfig/network<<EOF
HOSTNAME=$(hostname)
EOF

#关闭selinux
setenforce 0  >/dev/null 2>&1
sed -i -e 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i -e 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#关闭防火墙
systemctl stop firewalld.service && systemctl disable firewalld.service

#关闭邮件服务
systemctl stop postfix && systemctl disable postfix

#优化设置 journal 日志相关，避免日志重复搜集，浪费系统资源
sed -ri 's/^\$ModLoad imjournal/#&/' /etc/rsyslog.conf
sed -ri 's/^\$IMJournalStateFile/#&/' /etc/rsyslog.conf
sed -ri 's/^#(DefaultLimitCORE)=/\1=100000/' /etc/systemd/system.conf
sed -ri 's/^#(DefaultLimitNOFILE)=/\1=100000/' /etc/systemd/system.conf
systemctl restart systemd-journald
systemctl restart rsyslog

#配置系统语言
echo 'LANG="en_US.UTF-8"' >> /etc/profile && source /etc/profile

#禁用fastestmirror插件
sed -i 's/^enabled.*/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf
sed -i 's/^plugins.*/plugins=0/g' /etc/yum.conf

#安装常用软件
yum install -y curl
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -s -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo
curl -k -s -o /etc/yum.repos.d/epel.repo http://mirrors.cloud.tencent.com/repo/epel-7.repo
yum install -y wget vim tree jq net-tools telnet ntp tcpdump bind-utils socat yum-utils git expect

#配置时区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai
timedatectl set-local-rtc 0
systemctl restart rsyslog
systemctl restart crond

#设置时钟同步
cat > /etc/ntp.conf << EOF
#在与上级时间服务器联系时所花费的时间，记录在driftfile参数后面的文件
driftfile /var/lib/ntp/drift
#默认关闭所有的 NTP 联机服务
restrict default ignore
restrict -6 default ignore
#如从loopback网口请求，则允许NTP的所有操作
restrict 127.0.0.1
restrict -6 ::1
#使用指定的时间服务器
server ntp1.aliyun.com
server ntp2.aliyun.com
server ntp3.aliyun.com
#允许指定的时间服务器查询本时间服务器的信息
restrict ntp1.aliyun.com nomodify notrap nopeer noquery
#其它认证信息
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
EOF
systemctl start ntpd && systemctl enable ntpd
echo '* */6 * * * /usr/sbin/ntpdate -u ntp1.aliyun.com && /sbin/hwclock --systohc > /dev/null 2>&1'>>/var/spool/cron/`whoami`

#设置命名服务
echo "nameserver 8.8.8.8" | tee -a /etc/resolv.conf
echo "nameserver 114.114.114.114" | tee -a /etc/resolv.conf

#关闭NOZEROCONF
sed -i 's/^NOZEROCONF.*/NOZEROCONF=yes/g' /etc/sysconfig/network
#更改系统网络接口配置文件，设置该网络接口随系统启动而开启
sed -i -e '/^HWADDR=/d' -e '/^UUID=/d' /etc/sysconfig/network-scripts/ifcfg-eth*
sed -i -e 's/^ONBOOT.*$/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-eth*
sed -i -e 's/^NM_CONTROLLED.*$/NM_CONTROLLED=no/' /etc/sysconfig/network-scripts/ifcfg-eth*

#解决透明大页面问题
echo "echo never > /sys/kernel/mm/*transparent_hugepage/defrag" >/etc/rc.local
echo "echo never > /sys/kernel/mm/*transparent_hugepage/enabled" >/etc/rc.local

#关闭远程sudo执行命令需要输入密码和没有终端不让执行命令问题
sed -i 's/Defaults *requiretty/#Defaults requiretty/g' /etc/sudoers
sed -i 's/Defaults *!visiblepw/Defaults   visiblepw/g' /etc/sudoers

#设置ssh
sed -i '/PasswordAuthentication/s/^/#/'  /etc/ssh/sshd_config
sed -i 's/^[ ]*StrictHostKeyChecking.*/StrictHostKeyChecking no/g' /etc/ssh/ssh_config
sed -i -e 's/^GSSAPIAuthentication.*$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
#禁用sshd服务的UseDNS、GSSAPIAuthentication两项特性
sed -i -e 's/^#UseDNS.*$/UseDNS no/' /etc/ssh/sshd_config
#禁用SSH允许空密码
sed -i -e 's/^#PermitEmptyPasswords.*$/PermitEmptyPasswords no/' /etc/ssh/ssh_config
#M配置SSH 最大认证尝试次数为5或更低
sed -i -e 's/^#MaxAuthTries.*$/MaxAuthTries 4/' /etc/ssh/sshd_config
#修改协议版本
sed -i -e 's/^#Protocol.*$/Protocol 2/' /etc/ssh/ssh_config

sed -i 's/#MaxStartups 10:30:100/MaxStartups 10:30:200/g' /etc/ssh/sshd_config
systemctl restart sshd

[ ! -d ~/.ssh ] && ( mkdir ~/.ssh )
[ ! -f ~/.ssh/id_rsa.pub ] && (yes|ssh-keygen -f ~/.ssh/id_rsa -t rsa -N "")
( chmod 600 ~/.ssh/id_rsa.pub ) && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys


cat >/etc/security/limits.d/file.conf<<EOF
*       soft    nproc   131072
*       hard    nproc   131072
*       soft    nofile  131072
*       hard    nofile  131072
root    soft    nproc   131072
root    hard    nproc   131072
root    soft    nofile  131072
root    hard    nofile  131072
EOF

#关闭 NUMA
sed -i 's/rhgb quiet/rhgb quiet numa=off/g' /etc/default/grub

#升级内核
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install -y kernel-lt kernel-lt-devel 
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
grub2-set-default 0
sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# reboot 

# rpm -qa | grep kernel
# yum remove kernel*-3.10* -y
# yum --enablerepo=elrepo-kernel install -y kernel-lt-headers

