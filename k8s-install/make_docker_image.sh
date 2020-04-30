wget https://raw.githubusercontent.com/moby/moby/master/contrib/mkimage-yum.sh

sudo sh mkimage-yum.sh centos
#sudo sh mkimage-yum.sh centos -t 7


wget https://raw.githubusercontent.com/moby/moby/master/contrib/mkimage-alpine.sh

sudo sh mkimage-alpine.sh -r v3.11 -s