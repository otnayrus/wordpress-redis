sudo cp /vagrant/src/hosts /etc/hosts

sudo apt-get update

sudo apt-get install build-essential tcl -y
sudo apt-get install libjemalloc-dev -y

wget http://download.redis.io/releases/redis-5.0.7.tar.gz
tar xzf redis-5.0.7.tar.gz
cd redis-5.0.7
make

sudo make install

sudo mkdir /etc/redis

sudo cp /vagrant/src/redis-2/redis.conf /etc/redis/redis.conf
sudo cp /vagrant/src/redis-2/sentinel.conf /etc/redis-sentinel.conf

sudo cp /vagrant/src/redis-2/redis.service /etc/systemd/system/redis.service
sudo cp /vagrant/src/redis-2/redis-sentinel.service /etc/systemd/system/redis-sentinel.service

sudo adduser --system --group --no-create-home redis
sudo mkdir /var/lib/redis
sudo chown redis:redis /var/lib/redis
sudo chmod 770 /var/lib/redis
sudo mkdir /var/dump
sudo chown redis:redis /var/dump

sudo systemctl start redis

sudo chmod 777 /etc/redis-sentinel.conf
sudo systemctl start redis-sentinel

sudo chmod -R 777 /etc/redis
sudo systemctl restart redis