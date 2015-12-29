#!/usr/bin/env bash

# vagrant provision --provision-with install_magento

# Enable trace printing and exit on the first error
set -ex

is_windows_host=$1
guest_magento_dir=$2
magento_host_name=$3

cd ${guest_magento_dir}

# Clear cache
magento_clear_cache

# Remove configuration files
rm -f "${guest_magento_dir}/app/etc/config.php"
rm -f "${guest_magento_dir}/app/etc/env.php"

# Create DB
db_names=("magento" "magento_integration_tests")
for db_name in "${db_names[@]}"; do
    mysql -e "drop database if exists ${db_name}; create database ${db_name};"
done

# Install Magento application
cd ${guest_magento_dir}

admin_frontame="admin"
install_cmd="./bin/magento setup:install \
    --db-host=localhost \
    --db-name=magento \
    --db-user=root \
    --backend-frontname=${admin_frontame} \
    --base-url=http://${magento_host_name}/ \
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
if [ -f "${guest_magento_dir}/app/code/Magento/Amqp/registration.php" ]; then
    install_cmd="${install_cmd} \
    --amqp-host=localhost \
    --amqp-port=5672 \
    --amqp-user=guest \
    --amqp-password=guest"
fi

chmod +x bin/magento
php ${install_cmd}

# Enable Magento cron jobs
echo "* * * * * php ${guest_magento_dir}/bin/magento cron:run &" | crontab -u vagrant -

if [ ${is_windows_host} -eq 1 ]; then
    chown -R vagrant:vagrant ${guest_magento_dir}
fi

set +x
echo "
Magento application was deployed to ${guest_magento_dir} and installed successfully
Access storefront at http://${magento_host_name}/
Access admin panel at http://${magento_host_name}/${admin_frontame}/"

if [ ${is_windows_host} -eq 1 ]; then
    echo "
    [Optional] To finish developer environment set up:
        1. Please create new PhpStorm project using 'magento2ce' directory on your host
        (this directory should already contain Magento repository cloned earlier)

        2. Use instructions provided here https://github.com/paliarush/vagrant-magento/blob/master/docs/phpstorm-configuration-windows-hosts.md
        to set up synchronization in PhpStorm (or using rsync) with ${guest_magento_dir} directory"
fi
