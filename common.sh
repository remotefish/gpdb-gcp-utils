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

# generate the command to install packages for current os

# usage: install_pkg pkg...
#
# examples of pkg:
# - gdb: install gdb for current os
# - vim@centos: install vim if current os is centos
# - vim-nox@ubuntu: install vim-nox if current os is ubuntu
install_pkg()
{
	local pkgs
	local ostype
	local installer

	if [[ "$os" =~ ubuntu ]]; then
		ostype=ubuntu
		installer="sudo apt-get install -y"
	elif [[ "$os" =~ centos ]]; then
		ostype=centos
		installer="sudo yum install -y"
	else
		echo >&2 "error: unsupported os: $os"
		exit 1
	fi

	while [ -n "$1" ]; do
		case "$1" in
			*@${ostype}*)
				# the package is for current os
				pkgs+=" ${1%%@*}"
				;;
			*@*)
				# the package is not for current os
				;;
			*)
				# the package has the same name on all the oses
				pkgs+=" $1"
				;;
		esac
		shift
	done

	echo "$installer $pkgs"
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
