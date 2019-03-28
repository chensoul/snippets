#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

if [ `id -u` -ne 0 ]; then
    echo "must run as root"
    exit 1
fi

HOSTNAME=`hostname -f`

cd /root

# install the kerberos components
yum install -y krb5-server
yum install -y openldap-clients
yum install -y krb5-workstation

# update the config files for the realm name and hostname
# notice the -i.xxx for sed will create an automatic backup
# of the file before making edits in place
#
# set the Realm
sed -i.org 's/EXAMPLE.COM/JAVACHEN.COM/g' /etc/krb5.conf
# set the hostname for the kerberos server
sed -i "s/kerberos.example.com/$HOSTNAME/g" /etc/krb5.conf
# change domain name to javachen.com
sed -i 's/example.com/javachen.com/g' /etc/krb5.conf

# add a line
sed -i '/forwardable/a udp_preference_limit = 1' /etc/krb5.conf
# indent the two new lines in the file
sed -i 's/^udp_preference_limit/ udp_preference_limit/' /etc/krb5.conf

# add a line
sed -i '/forwardable/a clockskew = 120' /etc/krb5.conf
# indent the two new lines in the file
sed -i 's/^clockskew/ clockskew/' /etc/krb5.conf

# add a line
sed -i '/forwardable/a permitted_enctypes = aes256-cts-hmac-sha1-96' /etc/krb5.conf
# indent the two new lines in the file
sed -i 's/^permitted_enctypes/ permitted_enctypes/' /etc/krb5.conf

# add two line
sed -i '/forwardable/a default_tkt_enctypes = aes256-cts-hmac-sha1-96' /etc/krb5.conf
sed -i '/forwardable/a default_tgs_enctypes = aes256-cts-hmac-sha1-96' /etc/krb5.conf
# indent the two new lines in the file
sed -i 's/^default_t/ default_t/' /etc/krb5.conf

# download UnlimitedJCEPolicyJDK7.zip from Oracle into
# the /root directory
# we will use this for full strength 256 bit encryption
mkdir -p jce && cd jce
unzip -f ../UnlimitedJCEPolicyJDK7.zip
# save the original jar files
cp -fu /usr/java/latest/jre/lib/security/local_policy.jar local_policy.jar.orig
cp -fu /usr/java/latest/jre/lib/security/US_export_policy.jar US_export_policy.jar.orig

# copy the new jars into place
cp -fu /root/jce/UnlimitedJCEPolicy/local_policy.jar /usr/java/latest/jre/lib/security/local_policy.jar
cp -fu /root/jce/UnlimitedJCEPolicy/US_export_policy.jar /usr/java/latest/jre/lib/security/US_export_policy.jar


# update the kdc.conf file
sed -i.orig 's/EXAMPLE.COM/JAVACHEN.COM/g' /var/kerberos/krb5kdc/kdc.conf
# this will add a line to the file with ticket life
sed -i '/dict_file/a max_life = 1d' /var/kerberos/krb5kdc/kdc.conf
# add a max renewable life
sed -i '/dict_file/a max_renewable_life = 7d' /var/kerberos/krb5kdc/kdc.conf
# indent the two new lines in the file
sed -i 's/^max_/  max_/' /var/kerberos/krb5kdc/kdc.conf

# the acl file needs to be updated so the */admin
# is enabled with admin privileges
sed -i 's/EXAMPLE.COM/JAVACHEN.COM/' /var/kerberos/krb5kdc/kadm5.acl

# The kerberos authorization tickets need to be renewable
# if not the Hue service will show bad (red) status
# and the Hue “Kerberos Ticket Renewer” will not start
# the error message in the log will look like this:
#  kt_renewer   ERROR    Couldn't renew # kerberos ticket in
#  order to work around Kerberos 1.8.1 issue.
#  Please check that the ticket for 'hue/quickstart.cloudera'
#  is still renewable

# update the kdc.conf file to allow renewable
sed -i '/supported_enctypes/a default_principal_flags = +renewable, +forwardable' /var/kerberos/krb5kdc/kdc.conf
# fix the indenting
sed -i 's/^default_principal_flags/  default_principal_flags/' /var/kerberos/krb5kdc/kdc.conf

rm -rf /var/kerberos/krb5kdc/*.keytab /var/kerberos/krb5kdc/prin*
# now create the kerberos database
# cat /dev/sda > /dev/urandom
echo -e "root\nroot" | kdb5_util create  -r JAVACHEN.COM -s

# start up the kdc server and the admin server
chkconfig --level 35 krb5kdc on
chkconfig --level 35 kadmin on
service krb5kdc restart
service kadmin restart

# There is an addition error message you may encounter
# this requires an update to the krbtgt principal

# 5:39:59 PM    ERROR   kt_renewer
#
#Couldn't renew kerberos ticket in order to work around
# Kerberos 1.8.1 issue. Please check that the ticket
# for 'hue/quickstart.cloudera' is still renewable:
#  $ kinit -f -c /tmp/hue_krb5_ccache
#If the 'renew until' date is the same as the 'valid starting'
# date, the ticket cannot be renewed. Please check your
# KDC configuration, and the ticket renewal policy
# (maxrenewlife) for the 'hue/quickstart.cloudera'
# and `krbtgt' principals.
#

kadmin.local <<eoj
modprinc -maxrenewlife 1week krbtgt/JAVACHEN.COM@JAVACHEN.COM
eoj

echo -e "root\nroot" | kadmin.local -q "addprinc root/admin"

kadmin.local <<eoj
addprinc -pw test test@JAVACHEN.COM
eoj

# test the server by authenticating as the root user
# enter the password root when you are prompted
echo -e "root\nroot" | kinit root/admin

# once you have a valid ticket you can see the
# characteristics of the ticket with klist -e
# you will see the encryption type which you will
# need for a screen in the wizard, for example
#  Etype (skey, tkt): aes256-cts-hmac-sha1-96
klist -e

# to see the contents of the files cat them
cat /var/kerberos/krb5kdc/kdc.conf

cat /var/kerberos/krb5kdc/kadm5.acl

cat /etc/krb5.conf

