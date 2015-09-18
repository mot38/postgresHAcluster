#!/usr/bin/env bash

# Check running as root
if [ $(id -u) != '0' ]; then
  echo "You must run $0 as root!"
  exit 1
fi

#
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

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

chmod 777 /etc/repmgr/${VERSION}/auto_failover.sh
# Add Node entries to hosts File
################################
cat << HOSTS_FILE >> /etc/hosts
192.168.33.10 nodea
192.168.33.20 nodeb
192.168.33.30 nodec
192.168.33.40 bart
192.168.33.100 vip
192.168.33.101 haproxyvip
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
follow_command='/usr/pgsql-${VERSION}/bin/repmgr standby follow -f /etc/repmgr/${VERSION}/repmgr.conf -W'
priority=`expr $2 - $1 + 1`
use_replication_slots=1
REPMGR


#
yum install -y haproxy keepalived

# VIP setup
case $(hostname) in
  nodea)       export PRIORITY='100'
              ;;
  nodeb)       export PRIORITY='99'
              ;;
  nodec)       export PRIORITY='98'
              ;;
esac

cat <<KEEPALIVE > /etc/keepalived/keepalived.conf
vrrp_script postgresql-9.4 {
  script "pgrep postgres"
  interval 2
  wait 2
}
vrrp_instance PG-CLUSTER {
    state MASTER
    interface eth1
    virtual_router_id 100
    priority ${PRIORITY}
    advert_int 1
    virtual_ipaddress {
        192.168.33.100
    }
    track_script {
      postgresql-9.4 
    }
}
vrrp_script haproxy {
  script "pgrep haproxy"
  interval 2
  wait 2
}
vrrp_instance HAPROXY-CLUSTER {
    state MASTER
    interface eth1
    virtual_router_id 101
    priority ${PRIORITY}
    advert_int 1
    virtual_ipaddress {
        192.168.33.101
    }
    track_script {
      haproxy  
    }
}
KEEPALIVE

systemctl start keepalived
systemctl enable keepalived


# HA Proxy setup
#export CLUSTER='PG_CLUSTER' 

cat <<HAPROXY > /etc/haproxy/haproxy.cfg
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option                  http-server-close
    option                  redispatch
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
listen postgres-readonly *:15432
    balance roundrobin
    mode    tcp
    option pgsql-check user repmgr 
    server  nodea nodea:5432 check
    server  nodeb nodeb:5432 check
    server  nodec nodec:5432 check
listen admin *:8080
    mode http
    stats enable
    stats hide-version
    stats realm Haproxy\ Statistics
    stats uri /
HAPROXY
systemctl start haproxy
systemctl enable haproxy


# Type-specific installation
############################
echo "Installing configuration specific to $(hostname)"
/scripts/install.sh $1
