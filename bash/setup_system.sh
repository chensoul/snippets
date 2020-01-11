#!/bin/sh

rm -rf /root/original-ks.cfg

# 设置hostname
hostnamectl set-hostname $(hostname)

# 设置root密码为root
echo 'root'|passwd root --stdin >/dev/null 2>&1
#关闭远程sudo执行命令需要输入密码和没有终端不让执行命令问题
sed -i 's/Defaults *requiretty/#Defaults requiretty/g' /etc/sudoers
sed -i 's/Defaults *!visiblepw/Defaults   visiblepw/g' /etc/sudoers

# 设置yum源
yum install -y curl
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
rm -rf CentOS*.repo
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.cloud.tencent.com/repo/epel-7.repo
#禁用fastestmirror插件
sed -i 's/^enabled.*/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf
sed -i 's/^plugins.*/plugins=0/g' /etc/yum.conf
yum install -y wget curl vim tree jq net-tools bind-utils socat yum-utils git expect telnet tcpdump htop mtr

# 关闭selinux
setenforce 0  >/dev/null 2>&1
sed -i -e 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i -e 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 关闭防火墙
systemctl stop firewalld.service && systemctl disable firewalld.service

# 关闭邮件服务
systemctl stop postfix && systemctl disable postfix

# 持久化journald日志
mkdir /var/log/journal
chown root:systemd-journal /var/log/journal/
chmod 2755 /var/log/journal/
systemctl restart systemd-journald

# 配置系统语言
localectl set-locale LANG=en_US.UTF-8

# 配置时区
timedatectl set-timezone Asia/Shanghai
# 将硬件时钟调整为UTC时间，1为本地时钟
timedatectl set-local-rtc 0

# 设置时钟同步
yum erase -y ntp
yum install -y chrony
sed -i -e '/^server/d' /etc/chrony.conf
echo "server ntp1.aliyun.com iburst" >> /etc/chrony.conf
egrep -v "^#|^$" /etc/chrony.conf 
systemctl start chronyd && systemctl enable chronyd
ss -tulp | grep chronyd
chronyc tracking
chronyc sources
chronyc sourcestats

# 设置命名服务
echo "nameserver 114.114.114.114" | tee -a /etc/resolv.conf
echo "nameserver 8.8.8.8" | tee -a /etc/resolv.conf

# 关闭NOZEROCONF
sed -i 's/^NOZEROCONF.*/NOZEROCONF=yes/g' /etc/sysconfig/network
#更改系统网络接口配置文件，设置该网络接口随系统启动而开启
sed -i -e '/^HWADDR=/d' -e '/^UUID=/d' /etc/sysconfig/network-scripts/ifcfg-eth*
sed -i -e 's/^ONBOOT.*$/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-eth*
sed -i -e 's/^NM_CONTROLLED.*$/NM_CONTROLLED=no/' /etc/sysconfig/network-scripts/ifcfg-eth*

# 解决透明大页面问题
tee /etc/systemd/system/disable-thp.service <<-'EOF'
[Unit]
Description=Disable Transparent Huge Pages (THP)
 
[Service]
Type=simple
ExecStart=/bin/sh -c "echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled && echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag"
 
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload && systemctl start disable-thp &&systemctl enable disable-thp

USER=chenzj
useradd --system --shell /bin/bash --create-home --home-dir /home/$USER -G docker,root $USER
echo $USER|passwd $USER --stdin >/dev/null 2>&1
echo "$USER ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
sudo -u $USER ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ""
chmod 600 /home/$USER/.ssh/id_rsa.pub && sudo -u $USER cat /home/$USER/.ssh/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
chmod 600 /home/$USER/.ssh/authorized_keys
chown $USER:$USER /home/$USER/.ssh/authorized_keys

# 设置ssh
# 禁止root登陆
sed -i -e 's/^PermitRootLogin.*$/PermitRootLogin no/' /etc/ssh/sshd_config
# 禁止密码登陆
#sed -i -e 's/^#PasswordAuthentication.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
# 禁用SSH允许空密码
sed -i -e 's/^#PermitEmptyPasswords.*$/PermitEmptyPasswords no/' /etc/ssh/sshd_config
# GSSAPI验证改为no，加快连接速度**
sed -i -e 's/^GSSAPIAuthentication.*$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
# 禁用dns解析
sed -i -e 's/^#UseDNS.*$/UseDNS no/' /etc/ssh/sshd_config
# 配置SSH 最大认证尝试次数为4或更低
sed -i -e 's/^#MaxAuthTries.*$/MaxAuthTries 4/' /etc/ssh/sshd_config
sed -i 's/#MaxStartups 10:30:100/MaxStartups 10:30:200/g' /etc/ssh/sshd_config
# 修改协议版本
sed -i -e 's/^#Protocol.*$/Protocol 2/' /etc/ssh/sshd_config
sed -i 's/^[ ]*StrictHostKeyChecking.*/StrictHostKeyChecking no/g' /etc/ssh/ssh_config
systemctl restart sshd

cat > /etc/sysctl.d/custom.conf <<EOF
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_rmem = 65536 129024 33554432
net.ipv4.tcp_wmem = 65536 129024 33554432
net.ipv4.tcp_mem = 6194592 8259456 134217728
net.ipv4.tcp_fin_timeout = 20

# 接收数据包内存大小
net.core.rmem_max = 33554432 # 32MB
net.core.wmem_max = 33554432
net.core.rmem_default = 124928
net.core.wmem_default = 124928

# 文件打开数
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963

vm.overcommit_memory=1
vm.panic_on_oom=0
EOF
sysctl -p /etc/sysctl.d/custom.conf

# 设置文件打开句柄数
cat >> /etc/security/limits.conf<<EOF
*       soft    nproc   131072
*       hard    nproc   131072
*       soft    nofile  131072
*       hard    nofile  131072
root    soft    nproc   131072
root    hard    nproc   131072
root    soft    nofile  131072
root    hard    nofile  131072
EOF

# 安装openjdk
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel
cat > /etc/profile.d/java8.sh <<EOF
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
export PATH=\$PATH:\$JAVA_HOME/bin
export CLASSPATH=.:\$JAVA_HOME/jre/lib:\$JAVA_HOME/lib:\$JAVA_HOME/lib/tools.jar
EOF
source /etc/profile.d/java8.sh

# 关闭NUMA
sed -i 's/rhgb quiet/rhgb quiet numa=off/g' /etc/default/grub

# 升级内核
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install -y kernel-lt kernel-lt-devel 
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg
reboot 

# rpm -qa | grep kernel
# yum remove kernel*-3.10* -y
# yum --enablerepo=elrepo-kernel install -y kernel-lt-headers

