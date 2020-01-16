#!/usr/bin/env bash

. config.sh
. common.sh

upload_pkg()
{
	local fullname="$1"
	local pkgname=$(basename "$fullname")
	local pkgs
	local unpack

	case "$pkgname" in
		*.deb)
			unpack="dpkg -x '$pkgname' ."
			;;
		*.rpm)
			unpack="rpm2cpio '$pkgname' | cpio -idm"
			;;
		*.zip)
			pkgs=unzip
			unpack+="mkdir -p usr/local/greenplum-db-$gpversion; "
			unpack+="unzip '$pkgname'; "
			unpack+="skip=\$(awk '/^__END_HEADER__/ {print NR + 1; exit 0; }' *.bin); "
			unpack+="tail -n +\$skip *.bin | tar zxf - -C usr/local/greenplum-db-$gpversion; "
			;;
		bin_gpdb*.tar.gz)
			unpack+="mkdir -p usr/local/greenplum-db-$gpversion; "
			unpack+="pushd usr/local/greenplum-db-$gpversion; "
			unpack+="tar zxf '../../../$pkgname'; "
			unpack+="popd; "
			;;
		*)
			echo >&2 "error: unsupported package: $pkgname"
			exit 1
			;;
	esac

	echo "uploading gpdb binary $pkgname to $mdw ..."
	gcp_scp "$fullname" $mdw:/tmp

	echo "unpacking $pkgname ..."
	gcp_ssh $mdw -- bash -ex <<EOF
rm -rf /tmp/unpack ~/opt/greenplum-db-$gpversion
mkdir -p /tmp/unpack ~/opt
cd /tmp/unpack
ln -nfs '../$pkgname'
$(install_pkg $pkgs)
$unpack
cd usr/local
if [ ! -d greenplum-db-$gpversion ]; then
	echo >&2 "error: could not found greenplum-db-$gpversion in $pkgname"
	exit 1
fi
sed -i 's,^GPHOME=.*$,GPHOME=\$HOME/opt/greenplum-db-$gpversion,' \
	greenplum-db-$gpversion/greenplum_path.sh
mv greenplum-db-$gpversion ~/opt
ln -nfs ~/opt/greenplum-db-$gpversion/greenplum_path.sh ~/
EOF
}

if [ $# -ne 1 ]; then
	cat <<EOF
usage: $0 /path/to/greenplum-package.deb
    or $0 /path/to/greenplum-package.rpm
    or $0 /path/to/greenplum-package.zip

packages are available at https://network.pivotal.io/products/pivotal-gpdb/

EOF
	exit 1
fi

upload_pkg "$1"
