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

cp /vagrant/auto_failover.sh /etc/repmgr/${VERSION}/
chmod 755 /etc/repmgr/${VERSION}/auto_failover.sh
# Add Node entries to hosts File
################################
cat << HOSTS_FILE >> /etc/hosts
192.168.33.10 node1 master
192.168.33.20 node2 slave
192.168.33.30 node3 spare
HOSTS_FILE

yum install -y rsync

# Type-specific installation
############################
echo "Installing configuration specific to $(hostname)"
/scripts/install.sh $1
