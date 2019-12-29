#!/bin/bash

K8S_VERSION="1.16.3"

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

#安装docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum install docker-ce -y

systemctl enable docker && systemctl start docker

cat > /etc/docker/daemon.json <<EOF
{
    "oom-score-adjust": -1000,
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m",
      "max-file": "3"
    },
    "bip": "172.17.10.1/24",
    "registry-mirrors": ["https://hub.daocloud.io","http://hub-mirror.c.163.com/",
      "https://docker.mirrors.ustc.edu.cn/","https://registry.docker-cn.com"],
    "graph":"/data/docker",
    "exec-opts": ["native.cgroupdriver=systemd"],
    "storage-driver": "overlay2",
    "storage-opts": [
      "overlay2.override_kernel_check=true"
    ]
}
EOF
sed -i '/containerd.sock.*/ s/$/ -H tcp:\/\/0.0.0.0:2375 -H unix:\/\/var\/run\/docker.sock /' /usr/lib/systemd/system/docker.service
systemctl daemon-reload && systemctl restart docker


#加载IPVS
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4


#安装kubernetes
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
  http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum clean all -y

yum install -y ipset ipvsadm kubelet-${K8S_VERSION} kubeadm-${K8S_VERSION} kubectl-${K8S_VERSION} kubernetes-cni

#kubelet 默认读取的是 eth0 网卡 ip，所以会出问题。需要集群创建后设置正确的节点 ip
echo KUBELET_EXTRA_ARGS=\"--node-ip=`ip addr show eth1 |grep inet|grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}/"|tr -d '/'`\" > /etc/sysconfig/kubelet

systemctl start kubelet.service
systemctl enable kubelet.service

IPADDR=$(ifconfig eth1|grep inet|grep -v inet6|awk '{print $2}')
kubeadm init --apiserver-advertise-address $IPADDR --apiserver-cert-extra-sans $IPADDR --service-cidr 10.96.0.0/12 --pod-network-cidr 10.244.0.0/16 --kubernetes-version v${K8S_VERSION} --image-repository registry.aliyuncs.com/google_containers



