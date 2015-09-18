# postgresHAcluster

This code is a proof of concept to illustrate a high available postgres cluster with the following features:
- 3 node cluster comprising of 1 master and 2 slaves
- repmgr for automatic failover
- keepalived for a floating VIP for postgres writes
- keepalived for an additional floating VIP for postgres reads
- haproxy for load balancing


