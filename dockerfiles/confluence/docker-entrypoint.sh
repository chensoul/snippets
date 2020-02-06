#!/bin/bash

# https://github.com/zhangguanzhang/Dockerfile/blob/master/atlassian-confluence/docker-entrypoint.sh

set -e
[[ "${DEBUG}" == "true" ]] && set -x

# check if the `server.xml` file has been changed since the creation of this
# Docker image. If the file has been changed the entrypoint script will not
# perform modifications to the configuration file.
if [ "$(stat -c "%Y" "/opt/atlassian/confluence/conf/server.xml")" -eq "0" ]; then
  if [ -n "${X_PROXY_NAME}" ]; then
    sed -i 's/proxyName=""/proxyName="${X_PROXY_NAME}"/g' /opt/atlassian/confluence/conf/server.xml
  fi
  if [ -n "${X_PROXY_PORT}" ]; then
    sed -i 's/proxyName=""/proxyName="${X_PROXY_PORT}"/g' /opt/atlassian/confluence/conf/server.xml
  fi
  if [ -n "${X_PROXY_SCHEME}" ]; then
    sed -i 's/http/${X_PROXY_SCHEME}/g' /opt/atlassian/confluence/conf/server.xml
  fi
  if [ -n "${X_PROXY_SECURE}" ]; then
    sed -i 's/secure=""/secure="${X_PROXY_SECURE}"/g' /opt/atlassian/confluence/conf/server.xml
  fi
fi

if [ -f "${CERTIFICATE}" ]; then
  keytool -noprompt -storepass changeit -keystore ${JAVA_CACERTS} -import -file ${CERTIFICATE} -alias CompanyCA
fi


exec "$@"