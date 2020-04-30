#!/bin/bash


cd ceph-cluster
#初始化mon
ceph-deploy mon create-initial

reboot


#创建osd
sudo mkfs.xfs -f -i size=2048 /dev/sdb
ceph-deploy disk zap k8s-rke-node001 /dev/sdb
ceph-deploy osd create --data /dev/sdb k8s-rke-node001

#部署mgr
ceph-deploy mgr create k8s-rke-node001

#创建ceph cli
ceph-deploy admin k8s-rke-node001
sudo chmod +r /etc/ceph/ceph.client.admin.keyring

#安装mgr-dashboard
yum install -y ceph-mgr-dashboard
ceph mgr module enable dashboard --force
ceph dashboard create-self-signed-cert
ceph dashboard ac-user-create admin admin administrator
ceph mgr services
curl -k https://0.0.0.0:8443

#查看状态
ceph health
ceph -s
ceph osd tree
