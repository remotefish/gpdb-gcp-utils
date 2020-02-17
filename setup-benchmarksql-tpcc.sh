#!/usr/bin/env bash

. config.sh
. common.sh

dir=benchmarksql-5.0
pkg=${dir}.zip
url=https://jaist.dl.sourceforge.net/project/benchmarksql/${pkg}

dbname=benchmarksql

gcp_ssh $mdw -- bash -ex <<EOF
# install sysbench and utils
$(install_pkg ant unzip wget)

# fetch benchmarksql
if [ ! -d $dir ]; then
	wget -c $url
	unzip $pkg
fi

. $gphome/greenplum_path.sh
. $gpdata/me.env

createdb $dbname || :
EOF

cat <<EOF

Benchmark-SQL TPC-C benchmark is setup on mdw, to use it:

# login to mdw
./login.sh mdw

# execute below commands on mdw

. $gphome/greenplum_path.sh
. $gpdata/me.env

cd $dir

# then follow HOW-TO-RUN.txt on instructions
EOF
