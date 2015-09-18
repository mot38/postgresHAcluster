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
  - host$ git clone git@github.com:mot38/postgresHAcluster.git

  Clone git repository:
  - host$ git clone 

  On host - to spin up the 4 boxes:
  - host$ vagrant up

  On host - to ssh into the 4 boxes:
  - host$ vagrant ssh nodea
  - host$ vagrant ssh nodeb
  - host$ vagrant ssh nodec
  - host$ vagrant ssh bart

  For each of these we need to run a manual install file. This is to manipulate the install/setup sequence because the ssh key exchange has prerequisites.
  - nodea$ /vagrant/manual_install_master.sh
    The default passwords for root is 'root'
  - nodeb$ /vagrant/manual_install_master.sh
  - nodec$ /vagrant/manual_install_master.sh
  - bart$ /vagrant/manual_install_bart.sh
  

  
