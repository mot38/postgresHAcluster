#!/bin/bash

vagrant ssh nodea -c 'sudo /vagrant/manual_install_master.sh'
vagrant ssh nodeb -c 'sudo /vagrant/manual_install_node.sh'
vagrant ssh nodec -c 'sudo /vagrant/manual_install_node.sh'
vagrant ssh bart -c 'sudo /vargrant/manual_install_bart.sh'
