#!/usr/bin/env bash

# vagrant provision --provision-with install_magento

set -ex

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

# Install Magento code base
# Create Magento root dir
magento_dir="/var/www/magento2"

# Create DB
db_name="magento"

# Install Magento code base
# Create Magento root dir
magento_dir="/var/www/magento2"
if [ ! -d "${magento_dir}/app/code/Magento" ]; then
    if [ ! -d ${magento_dir} ]; then
        mkdir ${magento_dir}
    fi
    chown -R www-data:www-data ${magento_dir}
    chmod -R 775 ${magento_dir}
    usermod -a -G www-data vagrant #required to allow files modification via SSH
    echo "
    1. To finish Magento installation, please create new PHPStorm project using 'magento2ce' directory on your host
        (this directory should already contain Magento repository cloned earlier)

    2. Use instructions provided here https://github.com/paliarush/vagrant-magento/blob/master/docs/phpstorm-configuration.md
        to set up synchronization in PHPStorm (or using rsync) with ${magento_dir} directory and upload your project

    3. Then go to 'vagrant-magento' directory on the host (created earlier)
        and run 'vagrant provision --provision-with install_magento' in command line"
else
    # Clear cache
    cd ${magento_dir}
    # Clear var
    mv var/.htaccess .var_htaccess.back && rm -rf var/* && mv .var_htaccess.back var/.htaccess
    # Clear pub/statics
    mv pub/static/.htaccess pub/static_htaccess.back && rm -rf pub/static/* && mv pub/static_htaccess.back pub/static/.htaccess
    # Clear integration tests tmp
    cd "${magento_dir}/dev/tests/integration" && mv tmp/.gitignore tmp_gitignore.back && rm -rf tmp/* && mv tmp_gitignore.back tmp/.gitignore
    # Clear unit tests tmp
    cd "${magento_dir}/dev/tests/unit" && rm -rf tmp/*

    # Remove configuration files
    rm -f "${magento_dir}/app/etc/config.php"
    rm -f "${magento_dir}/app/etc/env.php"


    mysql -u root -ppassword -e "drop database if exists ${db_name}; create database ${db_name};"
    mysql -u root -ppassword -e "GRANT ALL ON ${db_name}.* TO magento@localhost IDENTIFIED BY 'magento';"

    cd ${magento_dir}
    usermod -a -G vagrant www-data #required to allow files modification by Apache, if they were uploaded from the host

    # Install Magento application
    github_token="/vagrant/local.config/github.oauth.token"
    if [ -f ${github_token} ]; then
        set +x
        echo "Installing GitHub OAuth token from ${github_token}..."
        composer config -g github-oauth.github.com `cat ${github_token}`
        set -x
        composer install
    else
        composer install --prefer-source
    fi

    admin_frontame="admin"
    install_cmd="./bin/magento setup:install \
        --db-host=localhost \
        --db-name=magento \
        --db-user=magento \
        --db-password=magento \
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
    chmod +x bin/magento
    php ${install_cmd}

    chown -R www-data:www-data .
    usermod -a -G www-data vagrant #required to allow files modification via SSH

    # Enable Magento cron jobs
    echo "*/1 * * * * php ${magento_dir}/bin/magento cron:run &" | crontab -u www-data -

    set +x
    echo "Magento application was deployed in ${magento_dir} and installed"
    echo "Access front store at http://${HOST}/"
    echo "Access admin panel at http://${HOST}/${admin_frontame}/"
    if [ ${HOST} != ${IP} ]; then
        echo "Don't forget to update your 'hosts' file with '${IP} ${HOST}'"
    fi
fi