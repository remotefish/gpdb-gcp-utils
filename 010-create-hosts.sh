#!/usr/bin/env bash

. config.sh
. common.sh

create_vm()
{
	local hostname=$1

	echo "creating vm $hostname ..."

	$gcloud compute instances create $hostname \
		--zone=$zone \
		--machine-type=$machine \
		--subnet=default \
		--network-tier=PREMIUM \
		--maintenance-policy=MIGRATE \
		--scopes=$scopes \
		--image=$os_image \
		--image-project=$os_project \
		--boot-disk-size=$disk_size \
		--boot-disk-type=$disk_type \
		--boot-disk-device-name=$hostname \
		--reservation-affinity=any
}

for host in $hosts; do
	create_vm $host
done
