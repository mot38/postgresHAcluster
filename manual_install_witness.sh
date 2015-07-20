#!/usr/bin/env bash
set 4
systemctl stop postgresql-9.4
echo "upstream_node=1" >> /etc/repmgr/9.4/repmgr.conf
rm -rf /var/lib/pgsql/9.4/data/*
cd /etc/repmgr/9.4/
/usr/pgsql-9.4/bin/repmgr -D /var/lib/pgsql/9.4/data -d repmgr -U repmgr --verbose standby clone node`expr $1 - 3` 
chown -R postgres:postgres /var/lib/pgsql/9.4/data/*
systemctl start postgresql-9.4
#/usr/pgsql-9.4/bin/repmgr -f /etc/repmgr/9.4/repmgr.conf standby register
#Create witness
mkdir /etc/repmgr/witness
chown -R postgres:postgres /etc/repmgr/witness
export WITNESS_PGDATA=/etc/repmgr/witness
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
su - postgres -c '/usr/pgsql-9.4/bin/repmgr -d repmgr -U repmgr -h node1 -D /etc/repmgr/witness -f /etc/repmgr/9.4/repmgr.conf witness create --initdb-no-pwprompt'
su - postgres -c '/usr/pgsql-9.4/bin/postgres -D /etc/repmgr/witness'
/usr/pgsql-9.4/bin/repmgr -f /etc/repmgr/9.4/repmgr.conf standby register
su - postgres -c '/usr/pgsql-9.4/bin/repmgrd -f /etc/repmgr/9.4/repmgr.conf --daemonize'
