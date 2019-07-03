#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";  exit 1
fi

sh $PROGDIR/bin/install_hadoop.sh
sh $PROGDIR/bin/install_postgres.sh
sh $PROGDIR/bin/config_hadoop.sh

echo "[INFO]:Install hadoop on cluster complete!"
