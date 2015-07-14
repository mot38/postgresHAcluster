#!/usr/bin/env bash

if [ $(id -u) != '0' ]; then
  echo "You must run $0 as root!"
  exit 1
fi

export VERSION='9.4' # Use 9.3 or 9.4
export SML_VER=$(echo $VERSION | sed 's/\.//')
export PG_DIR="/var/lib/pgsql/${VERSION}/data"

# Package installation
######################
echo "Adding Official PostgreSQL ${VERSION} repositories"
yum install -e 0 -q -y http://yum.postgresql.org/${VERSION}/redhat/rhel-7-x86_64/pgdg-centos94-${VERSION}-1.noarch.rpm 2>/dev/null

echo "Installing PostgreSQL version ${VERSION}"
PKGLIST[0]="postgresql${SML_VER}"
PKGLIST[1]="postgresql${SML_VER}-server"
PKGLIST[2]="postgresql${SML_VER}-contrib"
PKGLIST[3]="repmgr${SML_VER}"
for rpm in ${PKGLIST[@]}; do
  yum install -e 0 -q -y $rpm >/dev/null
  if [ $? != '0' ]; then
    echo "Failed to install ${rpm}"
    exit 1
  fi
done

cat << AUTO_FAILOVER_CONF >> /etc/repmgr/${VERSION}/auto_failover.sh
echo "Promoting Standby at `date '+%Y-%m-%d %H:%M:%S'`" #>>/var/log/repmgr/repmgr.log
/usr/pgsql-9.4/bin/repmgr -f /etc/repmgr/9.4/repmgr.conf --verbose standby promote #>>/var/log/repmgr/repmgr.log
AUTO_FAILOVER_CONF
#cp /vagrant/auto_failover.sh /etc/repmgr/${VERSION}/
chmod 755 /etc/repmgr/${VERSION}/auto_failover.sh
# Add Node entries to hosts File
################################
cat << HOSTS_FILE >> /etc/hosts
192.168.33.10 node1 A
192.168.33.20 node2 B
192.168.33.30 node3 C
HOSTS_FILE

yum install -y rsync

# Configure replication manager
###############################
echo 'Configuring replication manager'
cat <<REPMGR > /etc/repmgr/${VERSION}/repmgr.conf
cluster=test
node=$1
node_name=node$1
conninfo='host=$(hostname) user=repmgr dbname=repmgr'
pg_bindir=/usr/pgsql-${VERSION}/bin
master_response_timeout=60
reconnect_attempts=6
reconnect_interval=10
failover=automatic
promote_command='/etc/repmgr/${VERSION}/auto_failover.sh'
follow_command='/usr/pgsql-${VERSION}/bin/repmgr standby follow -f /etc/repmgr/${VERSION}/repmgr.conf'
priority=`expr $2 - $1 + 1`
use_replication_slots=1
REPMGR

# Type-specific installation
############################
echo "Installing configuration specific to $(hostname)"
/scripts/install.sh $1
