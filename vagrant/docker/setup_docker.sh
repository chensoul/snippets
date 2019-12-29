#!/bin/bash

USER=chenzj

#安装docker
# yum install -y yum-utils device-mapper-persistent-data lvm2
# yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# yum install docker-ce -y

curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh --mirror Aliyun
rm -rf get-docker.sh 

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

useradd -G docker $USER
echo $USER|passwd $USER --stdin >/dev/null 2>&1
sudo echo "$USER ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
sudo -u $USER ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ""
sudo -u $USER ./ssh_nopassword.expect $(hostname) $USER $USER
chown $USER:docker /var/run/docker.sock


curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-`uname -s`-`uname -m` \
  > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
