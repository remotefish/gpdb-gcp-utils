#!/usr/bin/env bash

# Get the Current Working DIRectory (CWDIR) of this file
CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. ${CWDIR}/config.sh
. ${CWDIR}/common.sh

setup_ssh()
{
	hosts_content=$(list_internal_hosts)

	for host in $hosts; do
		# generate pub keys
		gcp_ssh $host -- bash -e <<EOF
[ -f ~/.ssh/id_rsa ] || ssh-keygen -P '' -f ~/.ssh/id_rsa

# also take the chance to add the aliases to /etc/hosts
sudo sed -i '/$prefix-$os-/d' /etc/hosts
sudo tee -a /etc/hosts >/dev/null <<EOF1

$hosts_content
EOF1
EOF

		# fetch all pub keys
		gcp_scp $host:.ssh/id_rsa.pub tmp/$host.pub
		# combine all pub keys
		cat tmp/$host.pub >> tmp/all.pub
	done

	for host in $hosts; do
		# authorize all pub keys
		gcp_scp tmp/all.pub $host:/tmp/
		gcp_ssh $host -- bash -e <<EOF
cat /tmp/all.pub >> ~/.ssh/authorized_keys
EOF
	done

	for host in $hosts; do
		# mark all the pub keys as known, both hostnames and aliases
		gcp_ssh $host -- bash -e <<EOF
for h in $hosts $aliases; do
  ssh -o StrictHostKeyChecking=no \$h :
done
EOF
	done
}

# install depends, setup sysctl and limits
setup_system()
{
	gcp_scp ${CWDIR}/misc/ $mdw:

	gcp_ssh $mdw -- bash -ex <<EOF
. $gphome/greenplum_path.sh

# generate hostfiles using the aliases
cat <<EOF1 >~/hostfile.all
$(join_hostnames $'\n' "$aliases")
EOF1
sed '/mdw/d' <~/hostfile.all >~/hostfile.segs

if [ "$nsdws" -gt 0 ]; then
	# copy helper scripts to all segs
	gpscp -r -f ~/hostfile.segs ~/misc =:
fi

# deploy and run the scripts
gpssh -f ~/hostfile.all <<EOF1
	sudo cp ~/misc/limits.conf /etc/security/limits.d/99-gpdb.conf
	sudo cp ~/misc/sysctl.conf /etc/sysctl.d/99-gpdb.conf

	sudo sysctl -p /etc/sysctl.d/99-gpdb.conf

	cd ~/misc
	sudo bash -ex ./$install_deps_script
EOF1
EOF
}

rm -rf tmp
mkdir tmp

setup_ssh
setup_system
