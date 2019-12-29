#!/bin/bash

USER=chenzj
FQDN=javachen.space

#关闭交换空间
swapoff -a && sed -i '/swap/s/^/#/' /etc/fstab
sed -i '/ \/ .* defaults /s/defaults/defaults,noatime,nodiratime,nobarrier/g' /etc/fstab
sed -i 's/tmpfs.*/tmpfs\t\t\t\/dev\/shm\t\ttmpfs\tdefaults,nosuid,noexec,nodev 0 0/g' /etc/fstab

#设置内核参数
cat > k8s.conf <<EOF
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1

#ip转发
net.ipv4.ip_nonlocal_bind = 1
net.ipv4.ip_forward = 1
# 开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接，默认为0，表示关闭；
net.ipv4.tcp_tw_reuse = 1
#开启TCP连接中TIME-WAIT sockets的快速回收，默认为0，表示关闭
net.ipv4.tcp_tw_recycle=0
net.ipv4.neigh.default.gc_thresh1=4096
net.ipv4.neigh.default.gc_thresh2=6144
net.ipv4.neigh.default.gc_thresh3=8192
net.ipv4.neigh.default.gc_interval=60
net.ipv4.neigh.default.gc_stale_time=120

#配置网桥的流量
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.netfilter.nf_conntrack_max=2310720

vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0

fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
EOF
mv k8s.conf /etc/sysctl.d/k8s.conf
sysctl -p /etc/sysctl.d/k8s.conf

#加载内核
cat > /etc/sysconfig/modules/k8s.modules <<EOF
#!/bin/bash
modprobe rbd
modprobe br_netfilter
EOF
chmod 755 /etc/sysconfig/modules/k8s.modules && bash /etc/sysconfig/modules/k8s.modules 

#安装k8s
curl -s -L -o /usr/local/bin/rke https://github.com/rancher/rke/releases/latest/download/rke_linux-amd64
sudo chmod 777 /usr/local/bin/rke

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
  http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum install kubectl -y

kubernetes_version=`rke config --system-images --all|grep rancher/hyperkube|awk -F ':' '{print $2}'|sort -n|tail -n 1`


# $USER 用户安装k8s集群
su - $USER
mkdir -p install/k8s && cd install/k8s
cat > cluster.yml <<EOF
nodes:
  - address: 192.168.56.111
    user: $USER
    role: [controlplane,etcd,worker]

services:
  etcd:
    snapshot: true
    creation: 6h
    retention: 24h
  kube-api:
    service_cluster_ip_range: 10.43.0.0/16
    service_node_port_range: 30000-32767
  kubelet:
    cluster_domain: cluster.local
    cluster_dns_server: 10.43.0.10
    fail_swap_on: false
    extra_args:
      max-pods: 100

cluster_name: k8s-test
kubernetes_version: "${kubernetes_version}"
network:
    plugin: calico
EOF

rke up --config cluster.yml

mkdir ~/.kube/
cp kube_config_cluster.yml ~/.kube/config

echo "Configure Kubectl to autocomplete"
source <(kubectl completion bash) #
echo 'source <(kubectl completion bash)' >> ~/.bashrc
