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
### Registrasi Host File
Melakukan registrasi host agar dapat memanggil node dengan namanya.
```
sudo cp /vagrant/src/hosts /etc/hosts
```

### Instalasi Redis Cluster

Berikut merupakan cuplikan tahapan instalasi pada salah satu node redis.

Prerequisite
```
sudo apt-get install build-essential tcl -y
sudo apt-get install libjemalloc-dev -y
```

Install Redis
```
wget http://download.redis.io/releases/redis-5.0.7.tar.gz
tar xzf redis-5.0.7.tar.gz
cd redis-5.0.7
make

sudo make install

sudo mkdir /etc/redis
```
Membuat file config Redis dan Sentinel
```
sudo cp /vagrant/src/redis-1/redis.conf /etc/redis/redis.conf
sudo cp /vagrant/src/redis-1/sentinel.conf /etc/redis-sentinel.conf
```
Redis dan Sentinel as a service
```
sudo cp /vagrant/src/redis-1/redis.service /etc/systemd/system/redis.service
sudo cp /vagrant/src/redis-1/redis-sentinel.service /etc/systemd/system/redis-sentinel.service
```
Memberi ownership pada user redis agar bisa read-write
```
sudo adduser --system --group --no-create-home redis
sudo mkdir /var/lib/redis
sudo chown redis:redis /var/lib/redis
sudo chmod 770 /var/lib/redis
sudo mkdir /var/dump
sudo chown redis:redis /var/dump

sudo chmod 777 /etc/redis-sentinel.conf
sudo systemctl start redis-sentinel

sudo chmod -R 777 /etc/redis
```

Untuk node yang lain, sebagian besar tahapan instalasinya sama, hanya mengubah alamat dan nama host dari node yang bersangkutan.

### Instalasi Wordpress
Lakukan installasi basic LAMP Stack pada semua node wordpress, supaya Wordpress dapat berjalan.

`provision/bootstrapWordpress.sh`
```
# Apache2
sudo apt install apache2 -y

# PHP
sudo apt install php libapache2-mod-php php-mysql php-pear php-dev -y
sudo a2enmod mpm_prefork && sudo a2enmod php7.0
sudo pecl install redis
sudo echo 'extension=redis.so' >> /etc/php/7.2/apache2/php.ini

# MySQL
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password admin'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password admin'
sudo apt install mysql-server -y
sudo mysql_secure_installation -y

# Wordpress on MySQL Config
sudo mysql -u root -padmin < /vagrant/src/wp.sql

# Wordpress
wget -c http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
sudo mkdir -p /var/www/html
sudo mv wordpress/* /var/www/html
```

