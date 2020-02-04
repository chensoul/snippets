#!/bin/bash

SCHEMA_DIR=/etc/openldap/schema/

IFS='.' read -ra LDAP_BASE_DN_TABLE <<< "$LDAP_DOMAIN"
for i in "${LDAP_BASE_DN_TABLE[@]}"; do
  EXT="dc=$i,"
  LDAP_BASE_DN=$LDAP_BASE_DN$EXT
done

LDAP_BASE_DN=${LDAP_BASE_DN::-1}
LDAP_DC=`echo $LDAP_DOMAIN | awk -F. '{print $1}'`

# set client ldap.conf
echo "BASE   $LDAP_BASE_DN" >> /etc/openldap/ldap.conf
echo "URI    ldap://$LDAP_DOMAIN" >> /etc/openldap/ldap.conf

function ldap_Initialize() {

	# Initialize directory permissions
	[ -d /var/lib/ldap ] || mkdir -p /var/lib/ldap && cp -a /opt/ldap/* /var/lib/ldap/
	[ -d /etc/openldap ] || mkdir -p /etc/openldap/slapd.d 
	[ -f /etc/openldap/slapd.d/cn\=config.ldif ] || for i in `ls /opt/openldap/ | grep -v slapd.d`; do cp -a /opt/openldap/$i /etc/openldap/$i ; done && cp -a /opt/openldap/slapd.d/* /etc/openldap/slapd.d/

	chown -R ldap.ldap /var/lib/ldap
	chown -R ldap.ldap /etc/openldap

	# start
	/usr/sbin/slapd -u ldap -h 'ldapi:/// ldap:///'

	# domain passwd
	cat << EOF | ldapadd -Y EXTERNAL -H ldapi:///
dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $LDAP_ADMIN_PASSWORD
EOF

	# initial domain
	cat << EOF | ldapadd -Y EXTERNAL -H ldapi:///
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: $LDAP_BASE_DN
# domain administrator
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=admin,$LDAP_BASE_DN
EOF

	# Modify the Permissions
	cat << EOF | ldapadd -Y EXTERNAL -H ldapi:///
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=extern
 al,cn=auth" read by dn.base="cn=admin,$LDAP_BASE_DN" read by * none
EOF

	# Add Permissions
	cat << EOF | ldapadd -Y EXTERNAL -H ldapi:///
dn: olcDatabase={1}monitor,cn=config
changetype: modify
add: olcAccess
olcAccess: {1}to * by self write by dn="cn=admin,$LDAP_BASE_DN" write by * none
EOF

	# base tree
	cat << EOF | ldapadd -x -D "cn=admin,$LDAP_BASE_DN" -w $LDAP_ADMIN_PASSWORD
dn: $LDAP_BASE_DN
dc: $LDAP_DC
o: $LDAP_ORGANISATION
objectClass: top
objectClass: dcObject
objectClass: organization
EOF

	for i in `ls $SCHEMA_DIR|egrep "*\.ldif"`; do
	  ldapadd -Y EXTERNAL -H ldapi:/// -D "cn=config" -f $SCHEMA_DIR$i
	done

	kill -9 `ps aux|grep slapd | grep -v grep | awk '{print $2}'`

	touch /etc/openldap/slapd.d/.initialized
}

[ -f /etc/openldap/slapd.d/.initialized ] || ldap_Initialize