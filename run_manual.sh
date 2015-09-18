#!/bin/bash

vagrant ssh nodea -c 'sudo /vagrant/manual_install_master.sh'
vagrant ssh nodeb -c 'sudo /vagrant/manual_install_node.sh'
vagrant ssh nodec -c 'sudo /vagrant/manual_install_node.sh'
<<<<<<< HEAD
vagrant ssh bart -c 'sudo /vagrant/manual_install_bart.sh'
=======
vagrant ssh bart -c 'sudo /vargrant/manual_install_bart.sh'
>>>>>>> 31a3ce882cd72c3842bc7271b759fd7055019db8
