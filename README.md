# postgresHAcluster

This code is a proof of concept to illustrate a high available postgres database cluster with the following features:
- 3 node cluster comprising of 1 master and 2 slaves
- repmgr for automatic failover
- keepalived for a floating VIP for postgres writes
- keepalived for an additional floating VIP for postgres reads
- haproxy for load balancing
- a barman server to take backups and to restore including point in time recovery (PITR)

Prerequisites:
- Virtualbox
- Vagrant

Set up environment:

Clone git repository:
- host$ git clone git@github.com:mot38/postgresHAcluster.git

On host - to spin up the 4 boxes:
- host$ vagrant up

On host - to ssh into the 4 boxes:
- host$ vagrant ssh nodea
- host$ vagrant ssh nodeb
- host$ vagrant ssh nodec
- host$ vagrant ssh bart

For each of these we need to run a manual install file. This is to manipulate the install/setup sequence because the ssh key exchange has prerequisites and vagrant works by running the install script in it's entirity before moving on the next box.
- nodea$ /vagrant/manual_install_master.sh
  The default passwords for root is 'root'
- nodeb$ /vagrant/manual_install_node.sh
- nodec$ /vagrant/manual_install_node.sh
- bart$ /vagrant/manual_install_bart.sh

The cluster set up is for nodeb and nodec to both replicate from nodea. On failure of nodea, nodeb will then become the master (the priority is set in repmgr.conf). Nodec is needed to act as a 'witness server' to prevent a split brain scenario and to act as a read only node.

For cascading replication / failover, nodec should run /vagrant/manual_install_nodec.sh 

The IP address for writes to the postgres db is 192.168.33.100 This will always point to the master node
The IP address for the reads from the postgres db is 192.168.33.101 This will point to the nodes by round robin. You can view these reads by browsing to 192.168.33.101:8080

To take a backup and restore:
- barman@bart$ barman backup primary (primary is defined on barman.conf)
- barman@bart$ barman list-backup primary #note the backup ID
- root@restore_to# systemctl stop postgresql-9.4
- postgres@restore_to$ rm -rf ~/9.4/data 
- barman@bart$ barman recover --remote-ssh-command "ssh postgres@restore_to" primary latest /var/lib/pgsql/9.4/data  --target-time '2015-09-18 13:21:00' #or replace "latest" with backup ID
- root@restore_to# systemctl start postgresql-9.4

