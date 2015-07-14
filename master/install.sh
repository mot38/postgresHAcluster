#!/usr/bin/env bash

# Database initialisation
#########################
if [ ! -f "${PG_DIR}/postgresql.conf" ]; then
  echo "Initialising database..."
  /usr/pgsql-${VERSION}/bin/postgresql${SML_VER}-setup initdb
else
  echo "Database already exists. Skipping initialisation..."
fi

# Enable custom configuration
#############################
sed -i -e "s/#include_dir = 'conf.d'/include_dir = 'conf.d'/" ${PG_DIR}/postgresql.conf
[ ! -d "${PG_DIR}/conf.d" ] && mkdir "${PG_DIR}/conf.d"

# Service startup
#################
echo 'Starting PostgreSQL service'
systemctl start postgresql-${VERSION}
systemctl enable postgresql-${VERSION} >/dev/null 2>&1

echo 'Creating replication user account'
su - postgres -c "createuser -s repmgr" 2>/dev/null
su - postgres -c "createdb repmgr -O repmgr" 2>/dev/null

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
host     repmgr           repmgr      192.168.33.20/24         trust
host     replication      all         192.168.33.20/24         trust
host     repmgr           repmgr      192.168.33.30/24         trust
host     replication      all         192.168.33.30/24         trust
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
max_replication_slots = 3
POSTGRES_CONF

systemctl reload postgresql-${VERSION}

su - postgres -c "mkdir ./.ssh ; ssh-keygen -f ./.ssh/id_rsa -t rsa -N '' ; cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys ; chmod 600 ~/.ssh/authorized_keys"
