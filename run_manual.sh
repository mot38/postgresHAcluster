#!/bin/bash

vagrant ssh A -c 'sudo /vagrant/manual_install_master.sh'
vagrant ssh B -c 'sudo /vagrant/manual_install_node.sh'
vagrant ssh C -c 'sudo /vagrant/manual_install_node2.sh'
