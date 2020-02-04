#!/bin/bash

/usr/local/bin/initial_ldap.sh

cat <<EOF > /etc/supervisord.conf
[supervisord]
nodaemon=true
[program:ssh]
command=/usr/sbin/sshd -D
autorestart=true
startsecs=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
[program:slapd]
command=/usr/sbin/slapd -h "ldap://$HOSTNAME ldaps://$HOSTNAME ldapi:///" -u ldap -g ldap -d $LDAP_LOG_LEVEL
autorestart=true
startsecs=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOF

exec /usr/bin/supervisord