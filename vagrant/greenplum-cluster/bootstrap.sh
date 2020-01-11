#!/bin/sh

#设置内核参数
cat > greenplum.conf <<EOF
# kernel.shmall = _PHYS_PAGES / 2 # See Shared Memory Pages
kernel.shmall = 4000000000
# kernel.shmmax = kernel.shmall * PAGE_SIZE 
kernel.shmmax = 500000000
kernel.shmmni = 4096
vm.overcommit_memory = 2 
vm.overcommit_ratio = 50

net.ipv4.ip_local_port_range = 10000 65535 
kernel.sem = 500 2048000 200 40960
kernel.sysrq = 1
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.msgmni = 2048

net.ipv4.ip_forward = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.conf.default.rp_filter = 1 
net.ipv4.conf.all.arp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0

net.core.netdev_max_backlog = 10000
net.core.rmem_max = 2097152
net.core.wmem_max = 2097152
vm.swappiness = 10
vm.zone_reclaim_mode = 0
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 100
vm.dirty_background_ratio = 3 
vm.dirty_ratio = 10
EOF
mv greenplum.conf /etc/sysctl.d/greenplum.conf
sysctl -p /etc/sysctl.d/greenplum.conf

#关闭RemoveIPC
sed -i 's/#RemoveIPC=no/RemoveIPC=no/g' /etc/systemd/logind.conf
service systemd-logind restart

blockdev --setra 16384 /dev/sd*

echo deadline > /sys/block/sda/queue/scheduler 
grubby --update-kernel=ALL --args="elevator=deadline" 

USER=gpadmin
groupadd $USER
useradd $USER -r -m -g $USER
echo $USER|passwd $USER --stdin >/dev/null 2>&1
sudo echo "$USER ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
sudo -u $USER ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ""
