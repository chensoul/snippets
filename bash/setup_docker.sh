#!/bin/bash

cat > /etc/sysctl.d/docker.conf <<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
net.netfilter.nf_conntrack_max=2310720
EOF
sysctl -p /etc/sysctl.d/docker.conf

#安装docker
yum install -y yum-utils device-mapper-persistent-data lvm2
wget -O /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo
sed -i 's+download.docker.com+mirrors.cloud.tencent.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
yum install docker-ce -y

systemctl enable docker && systemctl start docker

cat > /etc/docker/daemon.json <<EOF
{
    "oom-score-adjust": -1000,
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m",
      "max-file": "5"
    },
    "dns": ["114.114.114.114","119.29.29.29", "182.254.116.116"],
    "bip": "172.17.10.1/24",
    "registry-mirrors": [
      "https://hub.daocloud.io",
      "https://docker.mirrors.ustc.edu.cn/",
      "https://registry.docker-cn.com"
    ],
    "graph":"/var/lib/docker",
    "exec-opts": ["native.cgroupdriver=systemd"],
    "storage-driver": "overlay2",
    "storage-opts": [
      "overlay2.override_kernel_check=true"
    ]
}
EOF
sed -i '/containerd.sock.*/ s/$/ -H tcp:\/\/0.0.0.0:2375 -H unix:\/\/var\/run\/docker.sock /' /usr/lib/systemd/system/docker.service
systemctl daemon-reload && systemctl restart docker

USER=chenzj
usermod -G docker,root $USER
chown $USER:docker /var/run/docker.sock

curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-`uname -s`-`uname -m` \
  > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose