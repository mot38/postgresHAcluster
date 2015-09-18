#!/bin/bash

#Don't need VIP or load balancing for barman server
systemctl stop keepalived
systemctl stop haproxy

#Barman setup

yum install -y barman

cat <<BARMAN>> /etc/barman.conf
[primary]
description = "Primary PostgreSQL Server"
conninfo = "host=vip user=postgres"
ssh_command = "ssh postgres@vip"
BARMAN

chown barman:barman /etc/barman.conf 

mkdir -p /primary/incoming
chown barman:barman -R /primary/incoming

