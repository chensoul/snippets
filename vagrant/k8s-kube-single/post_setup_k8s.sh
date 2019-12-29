#!/bin/bash

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