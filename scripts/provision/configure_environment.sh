#!/usr/bin/env bash

# Enable trace printing and exit on the first error
set -ex

use_nfs_for_synced_folders=$1
guest_magento_dir=$2
magento_host_name=$3
use_php7=$4
host_magento_dir=$5
is_windows_host=$6

vagrant_dir="/vagrant"

# Enable Magento virtual host
custom_virtual_host_config="${vagrant_dir}/etc/magento2_virtual_host.conf"
default_virtual_host_config="${vagrant_dir}/etc/magento2_virtual_host.conf.dist"
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
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
apt-get install -y php5.6 php-xdebug php5.6-xml php5.6-mcrypt php5.6-curl php5.6-cli php5.6-mysql php5.6-gd php5.6-intl php5.6-bcmath php5.6-mbstring php5.6-soap php5.6-zip libapache2-mod-php5.6
echo '
xdebug.max_nesting_level=200
xdebug.remote_enable=1
xdebug.remote_connect_back=1' >> /etc/php/5.6/mods-available/xdebug.ini

php_ini_path=/etc/php/7.0/cli/php.ini
echo "date.timezone = America/Chicago" >> ${php_ini_path}
sed -i "s|;include_path = \".:/usr/share/php\"|include_path = \".:/usr/share/php:${guest_magento_dir}/vendor/phpunit/phpunit\"|g" ${php_ini_path}
sed -i "s|display_errors = Off|display_errors = On|g" ${php_ini_path}
sed -i "s|display_startup_errors = Off|display_startup_errors = On|g" ${php_ini_path}
sed -i "s|error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT|error_reporting = E_ALL|g" ${php_ini_path}

php_ini_path=/etc/php/5.6/cli/php.ini
echo "date.timezone = America/Chicago" >> ${php_ini_path}
sed -i "s|;include_path = \".:/usr/share/php\"|include_path = \".:/usr/share/php:${guest_magento_dir}/vendor/phpunit/phpunit\"|g" ${php_ini_path}
sed -i "s|display_errors = Off|display_errors = On|g" ${php_ini_path}
sed -i "s|display_startup_errors = Off|display_startup_errors = On|g" ${php_ini_path}
sed -i "s|error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT|error_reporting = E_ALL|g" ${php_ini_path}
#end Setup PHP


# Configure composer
composer_auth_json="${vagrant_dir}/etc/composer/auth.json"
if [ -f ${composer_auth_json} ]; then
    set +x
    echo "Installing composer OAuth tokens from ${composer_auth_json}..."
    set -x
    if [ ! -d /home/vagrant/.composer ] ; then
      sudo -H -u vagrant bash -c 'mkdir /home/vagrant/.composer'
    fi
    if [ -f ${composer_auth_json} ]; then
        cp ${composer_auth_json} /home/vagrant/.composer/auth.json
    fi
fi

# Set permissions to allow Magento codebase upload by Vagrant provision script
if [ ${use_nfs_for_synced_folders} -eq 0 ]; then
    chown -R vagrant:vagrant /var/www
    chmod -R 755 /var/www
fi
