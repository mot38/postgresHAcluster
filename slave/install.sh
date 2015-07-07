#!/usr/bin/env bash
su - postgres -c "mkdir ./.ssh"

cat <<REPMGR > /etc/repmgr/${VERSION}/repmgr.conf
cluster=test
node=$1
node_name=node$1
conninfo='host=$(hostname) user=repmgr dbname=repmgr'

pg_bindir=/usr/pgsql-${VERSION}/bin
REPMGR
