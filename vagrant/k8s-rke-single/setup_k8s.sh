#!/bin/bash

USER=chenzj
FQDN=javachen.space

#关闭交换空间
swapoff -a && sed -i '/swap/s/^/#/' /etc/fstab
sed -i '/ \/ .* defaults /s/defaults/defaults,noatime,nodiratime,nobarrier/g' /etc/fstab
sed -i 's/tmpfs.*/tmpfs\t\t\t\/dev\/shm\t\ttmpfs\tdefaults,nosuid,noexec,nodev 0 0/g' /etc/fstab

#加载内核
cat > /etc/sysconfig/modules/k8s.modules <<EOF
#!/bin/bash
modprobe -- rbd
modprobe -- br_netfilter
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
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
    extra_args:
      auto-compaction-retention: 240 #(单位小时)
      # 修改空间配额为$((6*1024*1024*1024))，默认2G,最大8G
      quota-backend-bytes: "6442450944"
    backup_config:
      enabled: true
      interval_hours: 12
      retention: 6
  kube-api:
    service_cluster_ip_range: 10.43.0.0/16
    service_node_port_range: 30000-32767
    pod_security_policy: false
    always_pull_images: false
  # 控制器的一些配置，比如节点判断失联后多久开始迁移等
  kube-controller:
    cluster_cidr: 10.42.0.0/16
    service_cluster_ip_range: 10.43.0.0/16
    extra_args:
      ## 当节点通信失败后，再等一段时间kubernetes判定节点为notready状态。
      ## 这个时间段必须是kubelet的nodeStatusUpdateFrequency(默认10s)的整数倍，
      ## 其中N表示允许kubelet同步节点状态的重试次数，默认40s。
      node-monitor-grace-period: "20s"
      ## 再持续通信失败一段时间后，kubernetes判定节点为unhealthy状态，默认1m0s。
      node-startup-grace-period: "30s"
      ## 再持续失联一段时间，kubernetes开始迁移失联节点的Pod，默认5m0s。
      pod-eviction-timeout: "1m"
  # 集群的一些配置，包括资源预留，集群名字，dns等配置
  kubelet:
    cluster_domain: cluster.local
    infra_container_image: ""
    cluster_dns_server: 10.43.0.10
    fail_swap_on: false
    extra_args:
      serialize-image-pulls: "false"
      max-pods: 100
      registry-burst: "10"
      registry-qps: "0"
      # # 节点资源预留
      # enforce-node-allocatable: 'pods'
      # system-reserved: 'cpu=0.5,memory=500Mi'
      # kube-reserved: 'cpu=0.5,memory=1500Mi'
      # # POD驱逐，这个参数只支持内存和磁盘。
      # ## 硬驱逐伐值
      # ### 当节点上的可用资源降至保留值以下时，就会触发强制驱逐。强制驱逐会强制kill掉POD，不会等POD自动退出。
      # eviction-hard: 'memory.available<300Mi,nodefs.available<10%,imagefs.available<15%,nodefs.inodesFree<5%'
      # ## 软驱逐伐值
      # ### 以下四个参数配套使用，当节点上的可用资源少于这个值时但大于硬驱逐伐值时候，会等待eviction-soft-grace-period设置的时长；
      # ### 等待中每10s检查一次，当最后一次检查还触发了软驱逐伐值就会开始驱逐，驱逐不会直接Kill POD，先发送停止信号给POD，然后等待eviction-max-pod-grace-period设置的时长；
      # ### 在eviction-max-pod-grace-period时长之后，如果POD还未退出则发送强制kill POD"
      # eviction-soft: 'memory.available<500Mi,nodefs.available<50%,imagefs.available<50%,nodefs.inodesFree<10%'
      # eviction-soft-grace-period: 'memory.available=1m30s'
      # eviction-max-pod-grace-period: '30'
      # eviction-pressure-transition-period: '30s'

  kubeproxy:
    extra_args:
      # 默认使用iptables进行数据转发，如果要启用ipvs，则此处设置为ipvs
      proxy-mode: "ipvs"

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

