#!/usr/bin/env bash

. config.sh
. common.sh

$gcloud compute instances start $hosts \
	--zone=$zone
