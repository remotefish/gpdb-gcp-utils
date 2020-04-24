#!/usr/bin/env bash

. config.sh
. common.sh

# GCP will show a prompt 'do you want to continue',
# so we do not show one by us.

$gcloud compute instances delete $hosts \
	--zone=$zone

