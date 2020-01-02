#!/usr/bin/env bash

. config.sh
. common.sh

$gcloud compute instances stop $hosts \
	--zone=$zone
