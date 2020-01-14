#!/usr/bin/env bash

. config.sh
. common.sh

gcp_ssh $mdw -- bash -ex <<EOF
# install sysbench and utils
$(install_pkg sysbench git)

# fetch sysbench-tpcc
if [ ! -d sysbench-tpcc ]; then
	git clone https://github.com/Percona-Lab/sysbench-tpcc.git
fi

cd sysbench-tpcc
cp ~/misc/sysbench-tpcc-wrapper.sh gpdb-tpcc.sh
chmod +x gpdb-tpcc.sh

. $gphome/greenplum_path.sh
. $gpdata/me.env

createdb tpcc
EOF

cat <<EOF

sysbench TPC-C benchmark is setup on mdw, to use it:

# login to mdw
./login.sh mdw

# execute below commands on mdw

. \$gphome/greenplum_path.sh
. \$gpdata/me.env

cd sysbench-tpcc

./gpdb-tpcc.sh prepare      # load the data
./gpdb-tpcc.sh run          # run the benchmark
./gpdb-tpcc.sh cleanup      # delete the data

# below settings are recommended for TPC-C benchmark
gpconfig -c optimizer -v on
gpconfig -c log_statement -v all
gpconfig -c gp_enable_global_deadlock_detector -v on
EOF
