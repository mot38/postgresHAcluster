#!/usr/bin/env bash

# Enable hot standby
####################
cp /scripts/hotstandby.conf ${PG_DIR}/conf.d/hotstandby.conf

# Create pg_hba.conf
####################
cat << HBA_CONF > /var/lib/pgsql/9.4/data/pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host     repmgr           repmgr      127.0.0.1/32             trust
host     repmgr           repmgr      192.168.33.10/24         trust
host     replication      all         192.168.33.10/24         trust
#host    all             all             127.0.0.1/32            ident
# IPv6 local connections:
host    all             all             ::1/128                 ident
# Allow replication connections from localhost, by a user with the
# replication privilege.
#local   replication     postgres                                peer
#host    replication     postgres        127.0.0.1/32            ident
#host    replication     postgres        ::1/128                 ident
HBA_CONF

# Create postgresql.conf
########################
cat << POSTGRES_CONF >> /var/lib/pgsql/9.4/data/postgresql.conf
listen_addresses='*'
wal_level = 'hot_standby'
archive_mode = on
archive_command = 'cd .'   # we can also use exit 0, anything that
                          # just does nothing
max_wal_senders = 10
wal_keep_segments = 5000   # 80 GB required on pg_xlog
hot_standby = on
shared_preload_libraries = 'repmgr_funcs'
POSTGRES_CONF
