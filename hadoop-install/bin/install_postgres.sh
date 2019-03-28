#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

if [ `id -u` -ne 0 ]; then
    echo "must run as root"
    exit 1
fi

get_postgresql_major_version(){
    local psql_output=`psql --version`
    local regex="^psql \(PostgreSQL\) ([[:digit:]]+)\..*"

    if [[ $psql_output =~ $regex ]]; then
      echo ${BASH_REMATCH[1]}
    fi
}

get_standard_conforming_strings(){
    local psql_version=$(get_postgresql_major_version)
    if [[ $psql_version -gt 8 ]]; then
        echo "# This is needed to make Hive work with Postgresql 9.1 and above"
        echo "# See OPSAPS-11795"
        echo "standard_conforming_strings=off"
    fi
}

check_postgresql_installed(){
  echo "[INFO]:Install postgresql-server"
	if ! rpm -q postgresql-server >/dev/null ; then
	  yum install postgresql-server postgresql-jdbc -y >/dev/null 2>&1
		chkconfig postgresql on
	fi

	pkill -9 postgres
	rm -rf /var/lib/pgsql/data /var/run/postgresql/.s.PGSQL.$DB_PORT

  echo "[INFO]:Init postgresql database"
	service postgresql initdb
}

configure_postgresql_conf(){
  echo "[INFO]:Configure postgresql conf"

	sed -i "s/#port = 5432/port = $DB_PORT/" $CONF_FILE
	sed -i "s/max_connections = 100/max_connections = 600/" $CONF_FILE
	sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $CONF_FILE
	sed -i "s/shared_buffers = 32MB/shared_buffers = 256MB/" $CONF_FILE

	local SCS=$(get_standard_conforming_strings)
	if [ "$SCS" != "" ]; then
		echo $SCS
		sed -i "s/#standard_conforming_strings = on/standard_conforming_strings = off/" $CONF_FILE
	fi
}

enable_remote_connections(){
  echo "[INFO]:Enable remote connections"

	sed -i "s/127.0.0.1\/32/0.0.0.0\/0/" /var/lib/pgsql/data/pg_hba.conf
	sed -i "s/ident/trust/" /var/lib/pgsql/data/pg_hba.conf
}

create_db(){
	DB_NAME=$1
	DB_USER=$2
	DB_PASSWORD=$3

  echo "[INFO]:Create database $DB_NAME"

	su -c "cd ; /usr/bin/pg_ctl start -w -m fast -D /var/lib/pgsql/data" postgres
	su -c "cd ; /usr/bin/psql --command \"CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD'; \" " postgres
	su -c "cd ; /usr/bin/psql --command \"CREATE DATABASE $DB_NAME owner=$DB_USER;\" " postgres
	su -c "cd ; /usr/bin/psql --command \"GRANT ALL privileges ON DATABASE $DB_NAME TO $DB_USER;\" " postgres
}

init_hive_metastore(){
	DB_NAME=$1
	DB_USER=$2
	DB_FILE=$3

  echo "[INFO]:Init hive metastore using $DB_FILE"
	su -c "cd ; /usr/bin/psql -U $DB_USER -d $DB_NAME -f $DB_FILE" postgres
}

manager_db(){
  echo "[INFO]:$1 postgres"
	su -c "cd ; /usr/bin/pg_ctl $1 -w -m fast -D /var/lib/pgsql/data" postgres
}

readonly DB_HOST=$(hostname -f)
readonly DB_PORT=${DB_PORT:-5432}
readonly DB_HOSTPORT="$DB_HOST:$DB_PORT"
CONF_FILE="/var/lib/pgsql/data/postgresql.conf"

check_postgresql_installed

configure_postgresql_conf
enable_remote_connections
create_db metastore hiveuser redhat >/dev/null  2>&1

init_hive_metastore metastore hiveuser  "/usr/lib/hive/scripts/metastore/upgrade/postgres/hive-schema-0.13.0.postgres.sql" >/dev/null  2>&1
manager_db restart >/dev/null  2>&1
