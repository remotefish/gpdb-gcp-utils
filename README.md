These scripts automate the deployment of multi-host gpdb cluster on GCP.

To use them first please customize the settings in config.sh, please refer to
the comments in that file.  The `gcloud` CLI is used by the scripts, you need a
valid GCP project, to set it please execute `gcloud config set project
<project-id>`.

After that please execute the scripts in order:

    ./010-create-hosts.sh
    ./020-upload-gpdb-package.sh /path/to/gpdb-package
    ./030-setup-hosts.sh
    ./040-setup-cluster.sh
    ./050-enable-mirrors.sh

You can of course replace a step with your own version or do it manually.

There are some other helper scripts:
- `login.sh`: login to one vm:
```sh
    ./login.sh mdw        # login to mdw
    ./login.sh sdw1       # login to sdw1
    ./login.sh mdw date   # login to mdw and execute date command
```
- `start-hosts.sh` and `stop-hosts.sh`: start / stop the vms;
- `alter-machine-type.sh`: alter the cpu cores and memory size, the vms must be
  stopped, a typical usage is like below:
```sh
    ./stop-hosts.sh
    ./alter-machine-type.sh 24 48   # 24 cores, 48GB memory
    ./start-hosts.sh
```
- `setup-pgbench.sh`: setup the pgbench environment, a database `tpcb` will be
  created to hold the tables, the data scale is 1000;

## Cookbook

### How to create a single-host cluster?

Set `nsdws=0` in `config.sh`

### How to login to a host?

```sh
./login.sh mdw        # login to mdw
./login.sh mdw date   # execute the date command on mdw and exit
./login.sh sdw1       # login to sdw1
```

### How to use the cluster?

```sh
# login to the mdw
./login.sh mdw

# source below environment files on mdw
. $gphome/greenplum_path.sh
. $gpdata/me.env

# now we can use it
postgres --gp-version
psql -c 'select version()'
```

### How to setup the pgbench TPC-B benchmark?

```sh
./setup-pgbench.sh
```

Then we can login to mdw and use it:

```sh
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
```

### How to setup the sysbench TPC-C benchmark?

```sh
./setup-sysbench-tpcc.sh
```

Then we can login to mdw and use it:

```sh
# login to mdw
./login.sh mdw

# execute below commands on mdw

. $gphome/greenplum_path.sh
. $gpdata/me.env

cd sysbench-tpcc

./gpdb-tpcc.sh prepare      # load the data
./gpdb-tpcc.sh run          # run the benchmark
./gpdb-tpcc.sh cleanup      # delete the data

# below settings are recommended for TPC-C benchmark
gpconfig -c optimizer -v on
gpconfig -c log_statement -v all
gpconfig -c gp_enable_global_deadlock_detector -v on
```

TODO: explain how to control the data scale and concurrency

### How to setup the Benchmark-SQL TPC-C benchmark?

```sh
./setup-benchmarksql-tpcc.sh
```

Then we can login to mdw and use it:

```sh
# login to mdw
./login.sh mdw

# execute below commands on mdw

. $gphome/greenplum_path.sh
. $gpdata/me.env

cd benchmarksql-5.0

# then follow HOW-TO-RUN.txt on the instructions

# below settings are recommended for TPC-C benchmark
gpconfig -c optimizer -v on
gpconfig -c log_statement -v all
gpconfig -c gp_enable_global_deadlock_detector -v on
```
