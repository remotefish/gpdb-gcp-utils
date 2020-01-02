#!/usr/bin/env bash

. config.sh
. common.sh

# this script add mirrors to the cluster

gcp_ssh $mdw -- bash -ex <<EOF
# generate the mirror list
for ((i = 0; i < $nsegs; i++)); do
	echo "$gpdata/mirror/gpseg\$i"
done >/tmp/mirrors.list

. $gphome/greenplum_path.sh
. $gpdata/me.env

# ensure the mirrors are allowed in pg_hba.conf
gpssh -f ~/hostfile.all <<EOF1
find $gpdata -name pg_hba.conf \
| xargs sed -i '\\\$ahost replication \$USER \$(hostname -i)/16 trust'
EOF1

gpstop -u

# add the mirrors, FIXME: it does not allow mirror ports < 6432
gpaddmirrors -a -B32 -m /tmp/mirrors.list -p $((gpport+5000))
EOF
