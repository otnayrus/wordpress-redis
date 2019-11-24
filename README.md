# Implementasi Wordpress dengan Redis Cluster

## Skema Infrastruktur

WIP

## Implementasi Node Redis dan Wordpress
Membuat node untuk 3 server Redis dan 2 server Wordpress. Pada pengerjaan ini, saya menggunakan Virtualbox sebagai box node-nya.
Menjalankan `vagrant up` pada direktori project.

`Vagrantfile`
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  (1..3).each do |i|
    config.vm.define "redis_#{i}" do |node|
      node.vm.hostname = "redis_#{i}"
      node.vm.box = "ubuntu/bionic64"
      node.vm.network "private_network", ip: "192.168.16.6#{i+3}"
      
      node.vm.provider "virtualbox" do |vb|
        vb.name = "redis_#{i}"
        vb.gui = false
        vb.memory = "512"
        vb.cpus = "1"
      end
      
      node.vm.provision "shell", path: "provision/bootstrapRedis#{i}.sh"
    end
  end

  (1..2).each do |i|
    config.vm.define "wordpress_#{i}" do |node|
      node.vm.hostname = "wordpress_#{i}"
      node.vm.box = "ubuntu/bionic64"
      node.vm.network "private_network", ip: "192.168.16.6#{i+6}"
      
      node.vm.provider "virtualbox" do |vb|
        vb.name = "wordpress_#{i}"
        vb.gui = false
        vb.memory = "512"
        vb.cpus = "1"
      end
      
      node.vm.provision "shell", path: "provision/bootstrapWordpress.sh"
    end
  end

end
```

### Instalasi Redis Cluster

WIP

### Instalasi Wordpress

WIP

