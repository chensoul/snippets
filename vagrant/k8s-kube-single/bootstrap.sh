#!/bin/bash

K8S_VERSION="1.16.3"

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

yum install -y ipset ipvsadm kubelet-${K8S_VERSION} kubeadm-${K8S_VERSION} kubectl-${K8S_VERSION} kubernetes-cni

#kubelet 默认读取的是 eth0 网卡 ip，所以会出问题。需要集群创建后设置正确的节点 ip
echo KUBELET_EXTRA_ARGS=\"--node-ip=`ip addr show eth1 |grep inet|grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}/"|tr -d '/'`\" > /etc/sysconfig/kubelet

systemctl start kubelet.service
systemctl enable kubelet.service

IPADDR=$(ifconfig eth1|grep inet|grep -v inet6|awk '{print $2}')
kubeadm init --apiserver-advertise-address $IPADDR --apiserver-cert-extra-sans $IPADDR --service-cidr 10.96.0.0/12 --pod-network-cidr 10.244.0.0/16 --kubernetes-version v${K8S_VERSION} --image-repository registry.aliyuncs.com/google_containers


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-

wget https://docs.projectcalico.org/v3.9/manifests/calico.yaml
sed -i '/CALICO_IPV4POOL_IPIP/{n;s/Always/off/g}' calico.yaml
#多网卡问题 interface=eth0 interface=eth.* first-found
sed -i '/name: IP/{s/name: IP/name: IP_AUTODETECTION_METHOD/}' calico.yaml
sed -i '/\"autodetect\"/{s/\"autodetect\"/\"interface=eth1\"/}' calico.yaml
kubectl apply -f calico.yaml

echo 'source <(kubectl completion bash)' >> ~/.bashrc

kubectl get nodes

kubectl get pods --all-namespaces

