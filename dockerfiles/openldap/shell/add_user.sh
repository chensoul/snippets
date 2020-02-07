#!/bin/bash

# const
LDAP_SERVER_IP="localhost"
LDAP_SERVER_PORT="389"
LDAP_ADMIN_USER="cn=admin,dc=javachen,dc=xyz"
LDAP_ADMIN_PASS="admin"

if [ x"$#" != x"3" ];then
    echo "Usage: $0 <username> <realname>"
    exit -1
fi

# param
USER_ID="$1"
SN="$2"
NAME="$3"
PASSWORD="123456"
ENCRYPT_PASSWORD=$(slappasswd -h {ssha} -s "$PASSWORD")

# add count & group 
cat <<EOF | ldapmodify -c -h $LDAP_SERVER_IP -p $LDAP_SERVER_PORT \
    -w $LDAP_ADMIN_PASS -D $LDAP_ADMIN_USER 
dn: cn=$USER_ID,ou=People,javachen,dc=xyz
changetype: add
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
cn: $USER_ID
sn: $SN
givenName: $NAME
displayName: $SN$NAME
mail: $USER_ID@wesine.com
userPassword: $ENCRYPT_PASSWORD

dn: cn=jira,ou=Group,javachen,dc=xyz
changetype: modify
add: uniqueMember
uniqueMember: cn=$USER_ID,ou=People,javachen,dc=xyz
EOF