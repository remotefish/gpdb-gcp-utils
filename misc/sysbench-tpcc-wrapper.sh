#!/bin/sh

: ${T:=10}
: ${N:=40}
: ${SCALE:=10}
: ${TABLES:=10}

exec ./tpcc.lua \
	--db-driver=pgsql \
	--db-ps-mode=disable \
	--db-debug=off \
	--pgsql-host=localhost \
	--pgsql-port=${PGPORT} \
	--pgsql-db=tpcc \
	--pgsql-user=$USER \
	--time=$T \
	--threads=$N \
	--report-interval=1 \
	--tables=$TABLES \
	--scale=$SCALE \
	--trx_level=RC \
	--use_fk=0 \
	"$@"
