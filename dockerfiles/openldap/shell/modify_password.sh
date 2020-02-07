#!/bin/bash

# const
LDAP_SERVER_IP="localhost"
LDAP_SERVER_PORT="389"
LDAP_ADMIN_USER="cn=admin,dc=javachen,dc=xyz"
LDAP_ADMIN_PASS="admin"

if [ x"$#" != x"2" ];then
    echo "Usage: $0 <username> <newPassword>"
    exit -1
fi

# param
USERNAME="$1"
PASSWORD="$2"
ENCRYPT_PASSWORD=$(slappasswd -h {ssha} -s "$PASSWORD")

# modify
cat <<EOF | ldapmodify -c -h $LDAP_SERVER_IP -p $LDAP_SERVER_PORT \
	-w $LDAP_ADMIN_PASS -D $LDAP_ADMIN_USER 
dn: cn=$USERNAME,ou=People,dc=javachen,dc=xyz
changetype: modify
replace: userPassword
userPassword: $ENCRYPT_PASSWORD
EOF