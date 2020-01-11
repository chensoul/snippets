#!/usr/bin/env bash

set -e

# Locate shell script path
SCRIPT_DIR=$(dirname $0)
if [ ${SCRIPT_DIR} != '.' ]
then
  cd ${SCRIPT_DIR}
fi

PORT=10083

firewall-cmd --list-all

firewall-cmd --zone=public --add-port=$PORT/tcp
firewall-cmd --zone=public --add-port=$PORT/tcp --permanent

firewall-cmd --reload
firewall-cmd --list-all


mkdir -p /opt/redmine
cp docker-compose.yml /opt/redmine

cd /opt/redmine
docker-compose up -d