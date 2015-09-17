#!/usr/bin/env bash

systemctl stop postgresql-9.4
echo "upstream_node=2" >> /etc/repmgr/9.4/repmgr.conf
rm -rf /var/lib/pgsql/9.4/data/*
cd /etc/repmgr/9.4/
/usr/pgsql-9.4/bin/repmgr -D /var/lib/pgsql/9.4/data/ -d repmgr -U repmgr --verbose standby clone nodeb
chown -R postgres:postgres /var/lib/pgsql/9.4/data/*
systemctl start postgresql-9.4
/usr/pgsql-9.4/bin/repmgr -f /etc/repmgr/9.4/repmgr.conf standby register
su - postgres -c '/usr/pgsql-9.4/bin/repmgrd -f /etc/repmgr/9.4/repmgr.conf --daemonize'
