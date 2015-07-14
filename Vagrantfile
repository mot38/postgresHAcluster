# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do | global |
  global.vm.box = "landregistry/centos"
  global.vm.provision "shell", inline: 'sudo yum update -q -y'

  nodes = [
    {
      :name => 'A',
      :addr => '192.168.33.10',
      :data => './master'
    },
    {
      :name => 'B',
      :addr => '192.168.33.20',
      :data => './slave'
    },
    {
      :name => 'C',
      :addr => '192.168.33.30',
      :data => './slave'
    }
  ]

  nodes.each_with_index do | node, i |
    global.vm.define node[:name] do | config |
      config.vm.hostname = node[:name]
      config.vm.network :private_network,
        ip: node[:addr],
        virtualbox_inet: true
      config.vm.synced_folder node[:data], '/scripts'
      config.vm.provision "shell",
        inline: "/vagrant/install.sh #{i+1} #{nodes.length}"
    end
  end

end
