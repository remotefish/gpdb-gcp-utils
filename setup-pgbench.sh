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
EOF

cat <<EOF

pgbench TPC-B benchmark is setup on mdw, to use it:

# login to mdw
./login.sh mdw

# execute below commands on mdw

. $gphome/greenplum_path.sh
. $gpdata/me.env

cd pgbench.6x

./pgbench tpcb -s 1000 -i                   # load the data
./pgbench tpcb -c 80 -j 40 -T 60 -P 1 -r -S # run the select-only benchmark
./pgbench tpcb -c 80 -j 40 -T 60 -P 1 -r    # run the tpcb-like benchmark

# below settings are recommended for TPC-B benchmark
gpconfig -c optimizer -v off
gpconfig -c log_statement -v ddl
gpconfig -c gp_enable_global_deadlock_detector -v on
EOF
