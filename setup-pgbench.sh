#!/usr/bin/env bash

. config.sh
. common.sh

gcp_scp pgbench.6x $mdw:

gcp_ssh $mdw -- bash -ex <<EOF
. $gphome/greenplum_path.sh
. $gpdata/me.env

cd pgbench.6x
make -sj USE_PGXS=1 clean || :
make -sj USE_PGXS=1

createdb tpcb

./pgbench tpcb -s 1000 -i
EOF
