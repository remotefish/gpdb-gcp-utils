#!/usr/bin/env bash

# the name prefix of the vms, for example the mdw will have the name
# ${prefix}-${os}-mdw
prefix=my

# the gpdb version, it must match the version of the gpdb package
gpversion=6.2.1

# the port name of the master
gpport=2000

# the number of sdw vms, they will be named as sdw1 ~ sdwn
nsdws=4

# the number of segs per vm
nsegs=8

# to enable mirrors set it to 1.
#
# XXX: on GCP it might not be able to create mirrors directly with gpinitsystem
# due to the cross-subnet issue, so we have to create a primary-only cluster
# first, then add the mirrors separately after adding the cross-subnet policies
# to the pg_hba.conf
enable_mirrors=

# to enable master standby set it to 1.
#
# TODO: not supported yet
enable_standby=

# os can be ubuntu1804, centos6, centos7
os=centos7

# https://cloud.google.com/compute/docs/regions-zones/
zone=us-central1-a

# the machine type, such as n1-standard-16 or custom-16-32768
# https://cloud.google.com/compute/docs/machine-types
# https://cloud.google.com/dataproc/docs/concepts/compute/custom-machine-types
machine=n1-standard-16

# the disk type, can be pd-ssd or pd-standard
disk_type=pd-ssd

# the disk size
disk_size=512GB

# "gcloud" or "gcloud beta"
gcloud="gcloud beta"

scopes=
scopes+=https://www.googleapis.com/auth/devstorage.read_only,
scopes+=https://www.googleapis.com/auth/logging.write,
scopes+=https://www.googleapis.com/auth/monitoring.write,
scopes+=https://www.googleapis.com/auth/servicecontrol,
scopes+=https://www.googleapis.com/auth/service.management.readonly,
scopes+=https://www.googleapis.com/auth/trace.append,

# below are automatically set

case $os in
	ubuntu1804)
		os_image=ubuntu-minimal-1804-bionic-v20191217
		os_project=ubuntu-os-cloud
		install_deps_script=README.ubuntu.bash
		;;
	centos6)
		os_image=centos-6-v20191210
		os_project=centos-cloud
		install_deps_script=README.CentOS.bash
		;;
	centos7)
		os_image=centos-7-v20191210
		os_project=centos-cloud
		install_deps_script=README.CentOS.bash
		;;
	*)
		echo >&2 "error: OS '$os' is not supported yet"
		exit 1
		;;
esac

# define the names of the vms
mdw=$prefix-$os-mdw
sdws=$(seq -s ' ' -f "$prefix-$os-sdw%.f" $nsdws)
sdws=${sdws% }
if [ "$enable_standby" = 1 ]; then
	standby=$prefix-$os-smdw
	hosts="$mdw $standby $sdws"
else
	hosts="$mdw $sdws"
fi

# define where to find the gpdb binaries and cluster data
#
# XXX: do not change them, they are not used to control the binary/data path
gphome="\$HOME/opt/greenplum-db-$gpversion"
gpdata=/data/${gpversion}_${nsdws}x${nsegs}_port${gpport}
