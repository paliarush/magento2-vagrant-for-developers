#!/usr/bin/env bash

# vagrant provision --provision-with install_magento

# Enable trace printing and exit on the first error
set -ex

is_windows_host=$1

# Determine external IP address
set +x
IP=`ifconfig eth1 | grep inet | awk '{print $2}' | sed 's/addr://'`
echo "IP address is '${IP}'"
set -x

# Determine hostname for Magento web-site
HOST=`hostname -f`
if [ -z ${HOST} ]; then
    # Use external IP address as hostname
    set +x
    HOST=${IP}
    echo "Use IP address '${HOST}' as hostname"
    set -x
fi

magento_dir="/var/www/magento2ce"
cd ${magento_dir}

# Clear cache
magento_clear_cache

# Remove configuration files
rm -f "${magento_dir}/app/etc/config.php"
rm -f "${magento_dir}/app/etc/env.php"

# Create DB
db_names=("magento" "magento_integration_tests")
for db_name in "${db_names[@]}"; do
    mysql -e "drop database if exists ${db_name}; create database ${db_name};"
done

# Install git
apt-get install -y git

# Install Magento application
cd ${magento_dir}
composer_auth_json="/vagrant/local.config/composer/auth.json"
if [ -f ${composer_auth_json} ]; then
    set +x
    echo "Installing composer OAuth tokens from ${composer_auth_json}..."
    set -x
    if [ ! -d /home/vagrant/.composer ] ; then
      sudo -H -u vagrant bash -c 'mkdir /home/vagrant/.composer'
    fi
    cp ${composer_auth_json} /home/vagrant/.composer/auth.json
    sudo -H -u vagrant bash -c 'composer install'
else
    sudo -H -u vagrant bash -c 'composer install --prefer-source'
fi

admin_frontame="admin"
install_cmd="./bin/magento setup:install \
    --db-host=localhost \
    --db-name=magento \
    --db-user=root \
    --backend-frontname=${admin_frontame} \
    --base-url=http://${HOST}/ \
    --language=en_US \
    --timezone=America/Chicago \
    --currency=USD \
    --admin-lastname=Admin \
    --admin-firstname=Admin \
    --admin-email=admin@example.com \
    --admin-user=admin \
    --admin-password=123123q \
    --cleanup-database \
    --use-rewrites=1"

# Configure Rabbit MQ
if [ -d "${magento_dir}/app/code/Magento/Amqp" ]; then
    install_cmd="${install_cmd} \
    --amqp-host=localhost \
    --amqp-port=5672 \
    --amqp-user=guest \
    --amqp-password=guest"
fi

chmod +x bin/magento
php ${install_cmd}

# Enable Magento cron jobs
echo "* * * * * php ${magento_dir}/bin/magento cron:run &" | crontab -u vagrant -

if [ ${is_windows_host} -eq 1 ]; then
    chown -R vagrant:vagrant ${magento_dir}
fi

set +x
echo "
Magento application was deployed in ${magento_dir} and installed successfully
Access storefront at http://${HOST}/
Access admin panel at http://${HOST}/${admin_frontame}/

Don't forget to update your 'hosts' file with '${IP} ${HOST}'"

if [ ${is_windows_host} -eq 1 ]; then
    echo "
    [Optional] To finish developer environment set up:
        1. Please create new PhpStorm project using 'magento2ce' directory on your host
        (this directory should already contain Magento repository cloned earlier)

        2. Use instructions provided here https://github.com/paliarush/vagrant-magento/blob/master/docs/phpstorm-configuration-windows-hosts.md
        to set up synchronization in PhpStorm (or using rsync) with ${magento_dir} directory"
fi
