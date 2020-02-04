# Centos-OpenLDAP

创建 local 数据目录: (目前不支持 TLS 认证)

```
mkdir -p /data/openldap/ldap /data/openldap/slapd.d /data/openldap/certs
```

启动 OpenLDAP-Server：

```
docker run -d -p 389:389 -p 639:639 \
--restart always \
--name openldap-server \
--hostname shileizcc.com  \
-e LDAP_DOMAIN=shileizcc.com \
-e LDAP_ADMIN_PASSWORD=shileizcc \
-v /data/openldap/ldap:/var/lib/ldap \
-v /data/openldap/slapd.d:/etc/openldap/slapd.d \
javachen/centos-openldap:2.4.44
```

测试 Web UI：

```
$ docker run -d -p 18080:80 --name phpldapadmin \
--restart always \
-e PHPLDAPADMIN_LDAP_HOSTS=10.140.0.2 \
-e PHPLDAPADMIN_HTTPS=false \
osixia/phpldapadmin:latest
```