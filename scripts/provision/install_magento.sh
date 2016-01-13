#!/usr/bin/env bash

# vagrant provision --provision-with install_magento

# Enable trace printing and exit on the first error
set -ex

use_nfs_for_synced_folders=$1
guest_magento_dir=$2
magento_host_name=$3

declare -A setupOptions
setupOptions[backend_frontname]=$5
setupOptions[language]=$6
setupOptions[timezone]=$7
setupOptions[currency]=$8
setupOptions[admin_user]=$9
setupOptions[admin_password]=${10}
setupOptions[db_host]='localhost'
setupOptions[db_name]='magento'
setupOptions[db_user]='root'
setupOptions[base_url]="http://${magento_host_name}/"
setupOptions[admin_lastname]='Admin'
setupOptions[admin_firstname]='Admin'
setupOptions[admin_email]='admin@example.com'
setupOptions[amqp_host]='localhost'
setupOptions[amqp_port]='5672'
setupOptions[amqp_user]='guest'
setupOptions[amqp_password]='guest'

cd ${guest_magento_dir}

# Clear cache
magento_clear_cache

# Remove configuration files
rm -f "${guest_magento_dir}/app/etc/config.php"
rm -f "${guest_magento_dir}/app/etc/env.php"

# Create DB
db_names=(${setupOptions[db_name]} "magento_integration_tests" )
for db_name in "${db_names[@]}"; do
    mysql -e "drop database if exists ${db_name}; create database ${db_name};"
done

# Install Magento application
cd ${guest_magento_dir}

install_cmd="./bin/magento setup:install \
    --db-host=${setupOptions[db_host]} \
    --db-name=${setupOptions[db_name]} \
    --db-user=${setupOptions[db_user]} \
    --backend-frontname=${setupOptions[backend_frontname]} \
    --base-url=${setupOptions[base_url]} \
    --language=${setupOptions[language]} \
    --timezone=${setupOptions[timezone]} \
    --currency=${setupOptions[currency]} \
    --admin-lastname=${setupOptions[admin_lastname]} \
    --admin-firstname=${setupOptions[admin_firstname]} \
    --admin-email=${setupOptions[admin_email]} \
    --admin-user=${setupOptions[admin_user]} \
    --admin-password=${setupOptions[admin_password]} \
    --cleanup-database \
    --use-rewrites=1"

# Configure Rabbit MQ
if [ -f "${guest_magento_dir}/app/code/Magento/Amqp/registration.php" ]; then
    install_cmd="${install_cmd} \
    --amqp-host=${setupOptions[amqp_host]} \
    --amqp-port=${setupOptions[amqp_port]} \
    --amqp-user=${setupOptions[amqp_user]} \
    --amqp-password=${setupOptions[amqp_password]}"
fi

chmod +x bin/magento
php ${install_cmd}

# Enable Magento cron jobs
echo "* * * * * php ${guest_magento_dir}/bin/magento cron:run &" | crontab -u vagrant -

if [ ${use_nfs_for_synced_folders} -eq 0 ]; then
    chown -R vagrant:vagrant ${guest_magento_dir}
fi

set +x
echo "
Magento application was deployed to ${guest_magento_dir} and installed successfully
Access storefront at ${setupOptions[base_url]}
Access admin panel at ${setupOptions[base_url]}${setupOptions[backend_frontname]}/"

if [ ${use_nfs_for_synced_folders} -eq 0 ]; then
    echo "
    [Optional] To finish developer environment set up:
        1. Please create new PhpStorm project using 'magento2ce' directory on your host
        (this directory should already contain Magento repository cloned earlier)

        2. Use instructions provided here https://github.com/paliarush/vagrant-magento/blob/master/docs/phpstorm-configuration-windows-hosts.md
        to set up synchronization in PhpStorm (or using rsync) with ${guest_magento_dir} directory"
fi
