sudo cp /vagrant/src/hosts /etc/hosts

sudo apt-get update -y

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

sudo systemctl restart apache2