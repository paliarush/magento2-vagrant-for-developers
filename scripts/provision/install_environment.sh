#!/usr/bin/env bash

# Enable trace printing and exit on the first error
set -ex

vagrant_dir="/vagrant"

apt-get update

# Install git
apt-get install -y git

# Setup Apache
apt-get install -y apache2
a2enmod rewrite
# Make sure Apache is run from 'vagrant' user to avoid permission issues
sed -i 's|www-data|vagrant|g' /etc/apache2/envvars

# Setup PHP
# Workaround until php7.0 is available in official ubuntu repository
apt-get install -y language-pack-en-base
LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php-7.0
apt-get update
apt-get install -y php7.0 php7.0-mcrypt php7.0-curl php7.0-cli php7.0-mysql php7.0-gd php7.0-intl php7.0-xsl
# Install XDebug
apt-get install -y php7.0-dev
cd /usr/lib
git clone git://github.com/xdebug/xdebug.git
cd xdebug
phpize
./configure --enable-xdebug
make
make install
## Configure XDebug to allow remote connections from the host
touch /etc/php/7.0/cli/conf.d/20-xdebug.ini
echo 'zend_extension=/usr/lib/xdebug/modules/xdebug.so
xdebug.max_nesting_level=200
xdebug.remote_enable=1
xdebug.remote_connect_back=1' >> /etc/php/7.0/cli/conf.d/20-xdebug.ini
echo "date.timezone = America/Chicago" >> /etc/php/7.0/cli/php.ini
rm -rf /etc/php/7.0/apache2
ln -s /etc/php/7.0/cli /etc/php/7.0/apache2

# Restart Apache
service apache2 restart

# Setup MySQL
debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'
apt-get install -q -y mysql-server-5.6 mysql-client-5.6
mysqladmin -uroot -ppassword password ''
# Make it possible to run 'mysql' without username and password
sed -i '/\[client\]/a \
user = root \
password =' /etc/mysql/my.cnf

# Setup Composer
if [ ! -f /usr/local/bin/composer ]; then
    cd /tmp
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
fi

# Install RabbitMQ (is used by Enterprise edition)
apt-get install -y rabbitmq-server
rabbitmq-plugins enable rabbitmq_management
invoke-rc.d rabbitmq-server stop
invoke-rc.d rabbitmq-server start
