#!/bin/bash

# const
LDAP_SERVER_IP="localhost"
LDAP_SERVER_PORT="389"
LDAP_ADMIN_USER="cn=admin,dc=javachen,dc=xyz"
LDAP_ADMIN_PASS="admin"

if [ x"$#" != x"1" ];then
    echo "Usage: $0 <username>"
    exit -1
fi

# param
USERNAME="$1"

# delete user 
ldapdelete -c -h $LDAP_SERVER_IP -p $LDAP_SERVER_PORT \
	-w $LDAP_ADMIN_PASS -D $LDAP_ADMIN_USER "cn=$USERNAME,ou=People,dc=javachen,dc=xyz"