# 使用RKE安装K8S单节点



## 1、启动

```
vagrant up
```

vagrant启动时完成以下几件事情：

- 设置操作系统：setup_system.sh
- 安装k8s，包括安装docker：setup_k8s.sh
- 安装rancher：setup_rancher.sh
- 安装ceph：setup_ceph.sh

## 2、挂载存储

先停掉虚拟机：

```
vagrant halt
```

然后，在virtualbox里添加一块磁盘。

再次启动虚拟机，然后登陆进去初始化ceph，主要是创建存储类：

```
vagrant up
vagrant ssh
cd /vagrant
sh post_setup_ceph
```

## 3、安装harbor

```
sh setup_harbor.sh
```

