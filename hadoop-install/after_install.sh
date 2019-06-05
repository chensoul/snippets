#!/bin/sh

echo "create hdfs dir ..."

while read dir user group perm
do
    echo "mkdir $dir $user:$group $perm"
    su -s /bin/bash hdfs -c "hadoop fs -mkdir -p $dir;hadoop fs -chmod -R $perm $dir;hadoop fs -chown -R $user:$group $dir"
done << EOF
/tmp hdfs hadoop 1777
/var/log/hadoop-yarn/apps yarn mapred 1777
/user hdfs hadoop 777
/user/root root hadoop 755
/user/hive hive hadoop 777
/user/hive/warehouse hive hadoop 1777
/user/history mapred hadoop 1777
/user/history/done mapred hadoop 750
/user/history/done_intermediate mapred hadoop 1777
/hbase hbase hadoop 755
EOF

sudo -u hdfs hadoop fs -ls -R /

# sudo -u hdfs hadoop fs -mkdir -p /var/log/hadoop-yarn/apps
# sudo -u hdfs hadoop fs -chown yarn:mapred /var/log/hadoop-yarn/apps
# sudo -u hdfs hadoop fs -chmod 1777 /var/log/hadoop-yarn/apps

# sudo -u hdfs hadoop fs -mkdir -p /user
# sudo -u hdfs hadoop fs -chmod 777 /user
# sudo -u hdfs hadoop fs -mkdir -p /user/history
# sudo -u hdfs hadoop fs -chmod -R 1777 /user/history
# sudo -u hdfs hadoop fs -chown mapred:hadoop /user/history