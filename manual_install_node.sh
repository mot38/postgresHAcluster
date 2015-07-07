#!/usr/bin/env bash

systemctl stop postgresql-9.4
rm -rf /var/lib/pgsql/9.4/data/*
cd /etc/repmgr/9.4/
/usr/pgsql-9.4/bin/repmgr -D /var/lib/pgsql/9.4/data -d repmgr -U repmgr --verbose standby clone 192.168.33.10
chown -R postgres:postgres /var/lib/pgsql/9.4/data/*
systemctl start postgresql-9.4
/usr/pgsql-9.4/bin/repmgr -f /etc/repmgr/9.4/repmgr.conf standby register
