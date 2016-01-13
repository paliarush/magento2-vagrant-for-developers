#!/usr/bin/env bash

# Enable trace printing and exit on the first error
set -ex

use_nfs_for_synced_folders=$1
guest_magento_dir=$2
magento_host_name=$3
use_php7=$4

vagrant_dir="/vagrant"

apt-get update

# Install git
apt-get install -y git

# Setup Apache
apt-get install -y apache2
a2enmod rewrite

# Make suer Apache is run from 'vagrant' user to avoid permission issues
sed -i 's|www-data|vagrant|g' /etc/apache2/envvars

# Enable Magento virtual host
custom_virtual_host_config="${vagrant_dir}/local.config/magento2_virtual_host.conf"
default_virtual_host_config="${vagrant_dir}/local.config/magento2_virtual_host.conf.dist"
if [ -f ${custom_virtual_host_config} ]; then
    virtual_host_config=${custom_virtual_host_config}
else
    virtual_host_config=${default_virtual_host_config}
fi
enabled_virtual_host_config="/etc/apache2/sites-available/magento2.conf"
cp ${virtual_host_config}  ${enabled_virtual_host_config}
sed -i "s|<host>|${magento_host_name}|g" ${enabled_virtual_host_config}
sed -i "s|<guest_magento_dir>|${guest_magento_dir}|g" ${enabled_virtual_host_config}
a2ensite magento2.conf

# Disable default virtual host
sudo a2dissite 000-default

# Setup PHP
if [ ${use_php7} -eq 1 ]; then
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

    sed -i "s|;include_path = \".:/usr/share/php\"|include_path = \".:/usr/share/php:${guest_magento_dir}/vendor/phpunit/phpunit\"|g" /etc/php/7.0/cli/php.ini

    rm -rf /etc/php/7.0/apache2
    ln -s /etc/php/7.0/cli /etc/php/7.0/apache2
else
    apt-get install -y php5 php5-mhash php5-mcrypt php5-curl php5-cli php5-mysql php5-gd php5-intl php5-xsl php5-xdebug curl
    if [ ! -f /etc/php5/apache2/conf.d/20-mcrypt.ini ]; then
        ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini
    fi
    if [ ! -f /etc/php5/cli/conf.d/20-mcrypt.ini ]; then
        ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini
    fi
    echo "date.timezone = America/Chicago" >> /etc/php5/cli/php.ini

    # Configure XDebug to allow remote connections from the host
    echo 'xdebug.max_nesting_level=200
    xdebug.remote_enable=1
    xdebug.remote_connect_back=1' >> /etc/php5/cli/conf.d/20-xdebug.ini
fi

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

# Configure composer
composer_auth_json="${vagrant_dir}/local.config/composer/auth.json"
if [ -f ${composer_auth_json} ]; then
    set +x
    echo "Installing composer OAuth tokens from ${composer_auth_json}..."
    set -x
    if [ ! -d /home/vagrant/.composer ] ; then
      sudo -H -u vagrant bash -c 'mkdir /home/vagrant/.composer'
    fi
    cp ${composer_auth_json} /home/vagrant/.composer/auth.json
fi

# Declare path to scripts supplied with vagrant and Magento
echo "export PATH=\$PATH:${vagrant_dir}/scripts/guest:${guest_magento_dir}/bin" >> /etc/profile
echo "export MAGENTO_ROOT=${guest_magento_dir}" >> /etc/profile

# Set permissions to allow Magento codebase upload by Vagrant provision script
if [ ${use_nfs_for_synced_folders} -eq 0 ]; then
    chown -R vagrant:vagrant /var/www
    chmod -R 755 /var/www
fi

# Install RabbitMQ (is used by Enterprise edition)
apt-get install -y rabbitmq-server
rabbitmq-plugins enable rabbitmq_management
invoke-rc.d rabbitmq-server stop
invoke-rc.d rabbitmq-server start
