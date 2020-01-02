#!/usr/bin/env bash

. config.sh
. common.sh

if [ $# -ne 2 ]; then
	cat <<EOF
usage: $0 <number of cpu cores> <memory size in GB>

EOF
	exit 1
fi

# number of cpu cores
cores=$1

# memory size in GB
memsize=$2

newtype=custom-${cores}-$((memsize << 10))

for host in $hosts; do
	echo "alter vm '$host' to $cores cores and $memsize GB memory ..."

	$gcloud compute instances set-machine-type $host \
		--zone=$zone \
		--machine-type=$newtype
done
