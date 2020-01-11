#!/usr/bin/env bash

set -e

# Locate shell script path
SCRIPT_DIR=$(dirname $0)
if [ ${SCRIPT_DIR} != '.' ]
then
  cd ${SCRIPT_DIR}
fi

PORT=9000

firewall-cmd --list-all

firewall-cmd --zone=public --add-port=$PORT/tcp
firewall-cmd --zone=public --add-port=$PORT/tcp --permanent

firewall-cmd --reload
firewall-cmd --list-all


mkdir -p /opt/sonarqube
cp docker-compose.yml /opt/sonarqube

cd /opt/sonarqube
docker-compose up -d