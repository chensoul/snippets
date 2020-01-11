#!/bin/sh


yum install epel-release install yum-plugin-copr -y
yum copr enable ngompa/snapcore-el7
yum -y install snapd

systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap


snap install microk8s --classic

snap alias microk8s.kubectl kubectl
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc

microk8s.start
microk8s.enable dashboard dns ingress registry

#https://microk8s.io
#https://github.com/ubuntu/microk8s
#https://tutorials.ubuntu.com/tutorial/install-a-local-kubernetes-with-microk8s#0


