#!/usr/bin/env bash

gcp_scp()
{
	$gcloud compute \
		scp --zone $zone --recurse \
		"$@"
}

gcp_ssh()
{
	$gcloud compute \
		ssh --zone $zone \
                --ssh-flag=-T \
		"$@"
}

get_hostname()
{
	local suffix=$1

	echo ${prefix}-${os}-${suffix}
}

join_hostnames()
{
	local sep="$1"
	local names="$2"

	echo "${names// /$sep}"
}
