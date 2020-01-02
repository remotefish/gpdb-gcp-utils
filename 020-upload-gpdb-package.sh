#!/usr/bin/env bash

. config.sh
. common.sh

upload_pkg()
{
	local fullname="$1"
	local pkgname=$(basename "$fullname")
	local tmpdir=opt/tmp
	local extname=${pkgname##*.}
	local unpack

	case "$extname" in
		deb)
			unpack="dpkg -x '$pkgname' ."
			;;
		rpm)
			unpack="rpm2cpio '$pkgname' | cpio -idm"
			;;
		gz)
			unpack="mkdir -p usr/local/greenplum-db-$gpversion; pushd usr/local/greenplum-db-$gpversion; tar zxf ../../../$pkgname; popd"
			;;
		*)
			echo >&2 "error: unsupported package type: $extname"
			exit 1
			;;
	esac

	echo "uploading gpdb binary $pkgname to $mdw ..."

	gcp_ssh $mdw -- mkdir -p opt $tmpdir
	gcp_scp "$fullname" $mdw:$tmpdir
	gcp_ssh $mdw -- bash -ex <<EOF
cd $tmpdir
rm -rf usr
$unpack
cd usr/local
if [ ! -d greenplum-db-$gpversion ]; then
	echo >&2 "error: could not found greenplum-db-$gpversion in $pkgname"
	exit 1
fi
rm -rf ~/opt/greenplum-db-$gpversion
sed -i 's,^GPHOME=.*$,GPHOME=\$HOME/opt/greenplum-db-$gpversion,' \
	greenplum-db-*/greenplum_path.sh
mv greenplum-db-* ~/opt
EOF
}

if [ $# -ne 1 ]; then
	cat <<EOF
usage: $0 /path/to/greenplum-package.deb
    or $0 /path/to/greenplum-package.rpm

packages are available at https://network.pivotal.io/products/pivotal-gpdb/

EOF
	exit 1
fi

upload_pkg "$1"
