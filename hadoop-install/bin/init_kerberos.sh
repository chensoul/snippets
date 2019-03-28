#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"


NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode
ALL="`cat $NN_FILE $DN_FILE |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'`"

DNS=JAVACHEN.COM

for host in  $ALL ;do
  for user in hdfs hive; do
    kadmin.local -q "addprinc -randkey $user/$host@$DNS"
    kadmin.local -q "xst -k /var/kerberos/krb5kdc/$user-un.keytab $user/$host@$DNS"
  done
  for user in HTTP yarn mapred impala zookeeper sentry llama zkcli hbase llama sentry solr hue; do
    kadmin.local -q "addprinc -randkey $user/$host@$DNS"
    kadmin.local -q "xst -k /var/kerberos/krb5kdc/$user.keytab $user/$host@$DNS"
  done
done

cd /var/kerberos/krb5kdc/
echo -e "rkt rkt hdfs-un.keytab\nrkt HTTP.keytab\nwkt hdfs.keytab" | ktutil

#kerberos 重新初始化之后，还需要添加下面代码用于集成 ldap
kadmin.local -q "addprinc ldapadmin@JAVACHEN.COM"
kadmin.local -q "addprinc -randkey ldap/cdh1@JAVACHEN.COM"
kadmin.local -q "ktadd -k /etc/openldap/ldap.keytab ldap/cdh1@JAVACHEN.COM"