FROM javachen/centos:7

RUN yum install -y epel-release \
	&& yum install -y supervisor openldap openldap-servers openldap-clients openldap-devel compat-openldap migrationtools \
	&& cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG \
    && chown -R ldap.ldap /etc/openldap/ \
    && chown -R ldap.ldap /var/lib/ldap

COPY initial_ldap.sh /usr/local/bin/initial_ldap.sh
COPY supervisord.sh /usr/local/bin/supervisord.sh

ENV LDAP_LOG_LEVEL=256 \
    LDAP_DOMAIN=mydomain.com \
    LDAP_ADMIN_PASSWORD=passwd \
	LDAP_ORGANISATION="Example Inc."

EXPOSE 389 639

CMD ["/usr/local/bin/supervisord.sh"]