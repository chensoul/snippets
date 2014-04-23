#!/bin/bash

#get server ip and running date

SERVER=`ifconfig |grep -oE '([0-9]{1,3}\.?){4}'|head -n 1`
date=`date "+%Y-%m-%d-%H:%M:%S"`
run () {



# set system limits
# backup system limits.conf file

echo '=================================================set limits.conf=================================================='

echo 'Former /etc/security/limits.conf states:'
stat /etc/security/limits.conf |tail -n 4
echo ''

echo "backing up /etc/security/limits.conf to file /etc/security/limits.conf."$SERVER"-"$date""
cp -a /etc/security/limits.conf /etc/security/limits.conf."$SERVER"-"$date"

echo "changing system limits...."
grep ^* /etc/security/limits.conf |grep nofile  >/dev/null 
if [ $? -eq 0 ];then
sed -i '/^#/!{/nofile/d}' /etc/security/limits.conf
echo '*		soft	nofile		81920' >>  /etc/security/limits.conf
echo '*               hard    nofile          81920' >>  /etc/security/limits.conf
else
echo '*		soft	nofile		81920' >>  /etc/security/limits.conf
echo '*               hard    nofile          81920' >>  /etc/security/limits.conf
fi
#grep ^* /etc/security/limits.conf |grep nofile

grep ^* /etc/security/limits.conf |grep noproc  >/dev/null 
echo '' > /etc/security/limits.d/90-nproc.conf
if [ $? -eq 0 ];then
sed -i '/^#/!{/noproc/d}' /etc/security/limits.conf
echo '*		soft	noproc		81920' >>  /etc/security/limits.conf
echo '*               hard    noproc          81920' >>  /etc/security/limits.conf
else
echo '*		soft	noproc		81920' >>  /etc/security/limits.conf
echo '*               hard    noproc          81920' >>  /etc/security/limits.conf
fi

echo ''
echo '###########################new version#######################	###############################old version###################'
diff -y /etc/security/limits.conf /etc/security/limits.conf."$SERVER"-"$date"

echo ''
echo 'New /etc/security/limits.conf states:'
stat /etc/security/limits.conf |tail -n 4
echo ''

# set system sysctl
# backing up system sysctl
echo '=================================================set sysctl.conf=================================================='
echo ''
echo 'Former /etc/sysctl.conf states:'
stat /etc/sysctl.conf |tail -n 4
echo ''
echo ''
echo "backing up /etc/sysctl.conf to file /etc/sysctl.conf."$SERVER"-"$date""
cp -a /etc/sysctl.conf /etc/sysctl.conf."$SERVER"-"$date"

echo "changing sysctl.conf..."
grep ^net.ipv4.tcp_tw_reuse /etc/sysctl.conf >/dev/null
if [ $? -eq 0 ];then
#sed -i 's/^net.ipv4.tcp_tw_reuse.*$/net\.ipv4\.tcp\_tw\_reuse\ \=\ 1/g' /etc/sysctl.conf
sed -i '/^net.ipv4.tcp_tw_reuse.*$/d' /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_reuse = 1' >> /etc/sysctl.conf
else
echo 'net.ipv4.tcp_tw_reuse = 1' >> /etc/sysctl.conf
fi
grep ^net.ipv4.tcp_tw_reuse /etc/sysctl.conf


grep ^net.ipv4.tcp_tw_recycle /etc/sysctl.conf >/dev/null
if [ $? -eq 0 ];then
sed -i '/^net.ipv4.tcp_tw_recycle.*$/d' /etc/sysctl.conf
#sed -i 's/^net.ipv4.tcp_tw_recycle.*$/net\.ipv4\.tcp\_tw\_recycle\ \=\ 1/g' /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_recycle = 1' >> /etc/sysctl.conf
else
echo 'net.ipv4.tcp_tw_recycle = 1' >> /etc/sysctl.conf
fi
grep ^net.ipv4.tcp_tw_recycle /etc/sysctl.conf


grep ^net.ipv4.tcp_rmem /etc/sysctl.conf >/dev/null
if [ $? -eq 0 ];then
#sed -i 's/^net.ipv4.tcp_rmem.*$/net\.ipv4\.tcp\_rmem\ \=\ 65536\ 129024\ 8388608/g' /etc/sysctl.conf
sed -i '/^net.ipv4.tcp_rmem.*$/d' /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 65536 129024 33554432' >> /etc/sysctl.conf
else
echo 'net.ipv4.tcp_rmem = 65536 129024 33554432' >> /etc/sysctl.conf
fi
grep ^net.ipv4.tcp_rmem /etc/sysctl.conf


grep ^net.ipv4.tcp_wmem /etc/sysctl.conf >/dev/null
if [ $? -eq 0 ];then
#sed -i 's/^net.ipv4.tcp_wmem.*$/net\.ipv4\.tcp\_wmem\ \=\ 65536\ 129024\ 8388608/g' /etc/sysctl.conf
sed -i '/^net.ipv4.tcp_wmem.*$/d' /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 65536 129024 33554432' >> /etc/sysctl.conf
else
echo 'net.ipv4.tcp_wmem = 65536 129024 33554432' >> /etc/sysctl.conf
fi
grep ^net.ipv4.tcp_wmem /etc/sysctl.conf


grep ^net.ipv4.tcp_mem /etc/sysctl.conf >/dev/null
if [ $? -eq 0 ];then
#sed -i 's/^net.ipv4.tcp_mem.*$/net\.ipv4\.tcp\_mem\ \=\ 196608\ 524288\ 3145728/g' /etc/sysctl.conf
sed -i '/^net.ipv4.tcp_mem.*$/d' /etc/sysctl.conf
echo 'net.ipv4.tcp_mem = 6194592 8259456 134217728' >> /etc/sysctl.conf
else
echo 'net.ipv4.tcp_mem = 6194592 8259456 134217728' >> /etc/sysctl.conf
fi
grep ^net.ipv4.tcp_mem /etc/sysctl.conf 



grep ^net.core.wmem_max /etc/sysctl.conf >/dev/null
if [ $? -eq 0 ];then
sed -i '/^net.core.wmem_max.*$/d' /etc/sysctl.conf
echo 'net.core.wmem_max = 33554432' >> /etc/sysctl.conf
else
echo 'net.core.wmem_max = 33554432' >> /etc/sysctl.conf
fi
grep ^net.core.wmem_max /etc/sysctl.conf 


grep ^net.core.rmem_max /etc/sysctl.conf >/dev/null
if [ $? -eq 0 ];then
sed -i '/^net.core.rmem_max.*$/d' /etc/sysctl.conf
echo 'net.core.rmem_max = 33554432' >> /etc/sysctl.conf
else
echo 'net.core.rmem_max = 33554432' >> /etc/sysctl.conf
fi
grep ^net.core.rmem_max /etc/sysctl.conf 

grep ^net.core.wmem_default /etc/sysctl.conf >/dev/null
if [ $? -eq 0 ];then
sed -i '/^net.core.wmem_default.*$/d' /etc/sysctl.conf
echo 'net.core.wmem_default = 124928' >> /etc/sysctl.conf
else
echo 'net.core.wmem_default = 124928' >> /etc/sysctl.conf
fi
grep ^net.core.wmem_default /etc/sysctl.conf 


grep ^net.core.rmem_default /etc/sysctl.conf >/dev/null
if [ $? -eq 0 ];then
sed -i '/^net.core.rmem_default.*$/d' /etc/sysctl.conf
echo 'net.core.rmem_default = 124928' >> /etc/sysctl.conf
else
echo 'net.core.rmem_default = 124928' >> /etc/sysctl.conf
fi
grep ^net.core.rmem_default /etc/sysctl.conf 


grep ^net.ipv4.tcp_max_syn_backlog /etc/sysctl.conf >/dev/null
if [ $? -eq 0 ];then
#sed -i 's/^net.ipv4.tcp_max_syn_backlog.*$/net\.ipv4\.tcp\_max\_syn\_backlog\ \=\ 16384/g' /etc/sysctl.conf
sed -i '/^net.ipv4.tcp_max_syn_backlog.*$/d' /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 16384' >> /etc/sysctl.conf
else
echo 'net.ipv4.tcp_max_syn_backlog = 16384' >> /etc/sysctl.conf
fi
grep ^net.ipv4.tcp_max_syn_backlog /etc/sysctl.conf


grep ^net.ipv4.tcp_fin_timeout /etc/sysctl.conf >/dev/null
if [ $? -eq 0 ];then
#sed -i 's/^net.ipv4.tcp_fin_timeout.*$/net\.ipv4\.tcp\_fin\_timeout\ \=\ 20/g' /etc/sysctl.conf
sed -i '/^net.ipv4.tcp_fin_timeout.*$/d' /etc/sysctl.conf
echo 'net.ipv4.tcp_fin_timeout = 20' >> /etc/sysctl.conf
else
echo 'net.ipv4.tcp_fin_timeout = 20' >> /etc/sysctl.conf
fi
grep ^net.ipv4.tcp_fin_timeout /etc/sysctl.conf 

echo ''
echo '###########################new version#######################	###############################old version###################'
diff -y /etc/sysctl.conf /etc/sysctl.conf."$SERVER"-"$date"

echo ''
echo 'New /etc/sysctl.conf states:'
stat /etc/sysctl.conf |tail -n 4
echo ''
#sysctl -p > /dev/null
#service mysql restart
echo "finished ,to make changing available ,please reboot system"
}

run |tee -ai /var/log/set_kernel_params."$SERVER"-"$date".log

echo "Please refer to /var/log/set_kernel_params."$SERVER"-"$date".log for details"
