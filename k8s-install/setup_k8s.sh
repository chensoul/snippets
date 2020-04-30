#!/bin/bash

USER=chenzj

#关闭交换空间
swapoff -a && sed -i '/swap/s/^/#/' /etc/fstab
sed -i '/ \/ .* defaults /s/defaults/defaults,noatime,nodiratime,nobarrier/g' /etc/fstab
sed -i 's/tmpfs.*/tmpfs\t\t\t\/dev\/shm\t\ttmpfs\tdefaults,nosuid,noexec,nodev 0 0/g' /etc/fstab

#加载内核
cat > k8s.modules <<EOF
#!/bin/bash
modprobe -- rbd
modprobe -- br_netfilter
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
mv k8s.modules /etc/sysconfig/modules/k8s.modules
chmod 755 /etc/sysconfig/modules/k8s.modules && bash /etc/sysconfig/modules/k8s.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
yum install -y ipset ipvsadm 

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
    backup_config:
      enabled: true         
      interval_hours: 12   
      retention: 6         
  kube-api:
    service_cluster_ip_range: 10.43.0.0/16
    service_node_port_range: 30000-32767
  kubelet:
    cluster_domain: cluster.local
    cluster_dns_server: 10.43.0.10
    fail_swap_on: false
    extra_args:
      max-pods: 110

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

kubectl taint nodes --all node-role.kubernetes.io/master-

