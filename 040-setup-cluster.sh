#!/usr/bin/env bash

# Get the Current Working DIRectory (CWDIR) of this file
CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. ${CWDIR}/config.sh
. ${CWDIR}/common.sh

build_cluster()
{
	echo "creating the cluster at $gpdata ..."

	gcp_ssh $mdw -- bash -ex <<EOF
. $gphome/greenplum_path.sh

# create data dir
gpssh -f ~/hostfile.all <<EOF1
mkdir -p data

sudo ln -nfs \$HOME/data /data
sudo chown \$USER /data

mkdir -p $gpdata/{primary,mirror}
EOF1

# create master env
cat >$gpdata/me.env <<EOF1
export PGPORT=$gpport
export MASTER_DATA_DIRECTORY=$gpdata/gpseg-1
EOF1

# generate gpinitsystem config file
sed -ri \
    -e 's,^(__version)=.*$,\\1=$gpversion,' \
    -e 's,^(__port)=.*$,\\1=$gpport,' \
    -e 's,^(__nhosts)=.*$,\\1=$nsdws,' \
    -e 's,^(__nsegs)=.*$,\\1=$nsegs,' \
    -e 's,^(__enable_mirrors)=.*$,\\1=$enable_mirrors,' \
    -e 's,^(__enable_standby)=.*$,\\1=$enable_standby,' \
    /tmp/misc/gpinitsystem.conf

# copy gpdb binaries to segs
gpssh -f ~/hostfile.segs mkdir -p opt/
gpscp -r -f ~/hostfile.segs $gphome =:opt/

# build the cluster
gpinitsystem -aq -B32 \
	-c /tmp/misc/gpinitsystem.conf \
	-h ~/hostfile.segs
EOF

	cat <<EOF

successfully created the cluster, source below files to use it:

    . $gphome/greenplum_path.sh
    . $gpdata/me.env

EOF
}

build_cluster
