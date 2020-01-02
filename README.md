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
