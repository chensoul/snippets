#!/bin/bash

# https://github.com/zhangguanzhang/Dockerfile/blob/master/atlassian-confluence/docker-entrypoint.sh

set -e
[[ "${DEBUG}" == "true" ]] && set -x

# check if the `server.xml` file has been changed since the creation of this
# Docker image. If the file has been changed the entrypoint script will not
# perform modifications to the configuration file.
if [ "$(stat -c "%Y" "${CONF_INSTALL}/conf/server.xml")" -eq "0" ]; then
  if [ -n "${X_PROXY_NAME}" ]; then
    sed -i 's/proxyName=""/proxyName="${X_PROXY_NAME}"/g' server.xml
  fi
  if [ -n "${X_PROXY_PORT}" ]; then
    sed -i 's/proxyName=""/proxyName="${X_PROXY_PORT}"/g' server.xml
  fi
  if [ -n "${X_PROXY_SCHEME}" ]; then
    sed -i 's/http/${X_PROXY_SCHEME}/g' server.xml
  fi
  if [ -n "${X_PROXY_SECURE}" ]; then
    sed -i 's/secure=""/secure="${X_PROXY_SECURE}"/g' server.xml
  fi
  if [ -n "${X_PATH}" ]; then
  fi
fi

if [ -f "${CERTIFICATE}" ]; then
  keytool -noprompt -storepass changeit -keystore ${JAVA_CACERTS} -import -file ${CERTIFICATE} -alias CompanyCA
fi


exec "$@"