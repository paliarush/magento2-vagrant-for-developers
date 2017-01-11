#!/usr/bin/env bash

function process_php_config () {
    php_ini_paths=$1

    for php_ini_path in "${php_ini_paths[@]}"
    do
        if [[ -f ${php_ini_path} ]]; then
            echo "date.timezone = America/Chicago" >> ${php_ini_path}
            sed -i "s|;include_path = \".:/usr/share/php\"|include_path = \".:/usr/share/php:${guest_magento_dir}/vendor/phpunit/phpunit\"|g" ${php_ini_path}
            sed -i "s|display_errors = Off|display_errors = On|g" ${php_ini_path}
            sed -i "s|display_startup_errors = Off|display_startup_errors = On|g" ${php_ini_path}
            sed -i "s|error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT|error_reporting = E_ALL|g" ${php_ini_path}
            sed -i "s|;always_populate_raw_post_data = -1|always_populate_raw_post_data = -1|g" ${php_ini_path}

            # TODO: Fix for a bug, should be removed in 3.0
            sed -i "s|:/vendor/phpunit/phpunit|:${guest_magento_dir}/vendor/phpunit/phpunit|g" ${php_ini_path}
        fi
    done
}

function init_php56 () {
    status "Installing PHP 5.6"
    add-apt-repository ppa:ondrej/php 2> >(logError) > >(log)
    apt-get update 2> >(logError) > >(log)
    apt-get install -y php5.6 php-xdebug php5.6-xml php5.6-mcrypt php5.6-curl php5.6-cli php5.6-mysql php5.6-gd php5.6-intl php5.6-bcmath php5.6-mbstring php5.6-soap php5.6-zip libapache2-mod-php5.6 2> >(logError) > >(log)
    echo '
    xdebug.max_nesting_level=200
    xdebug.remote_enable=1
    xdebug.remote_host=192.168.10.1' >> /etc/php/5.6/mods-available/xdebug.ini
}

function isServiceAvailable() {
    all_services="$(service --status-all 2> >(log))"
    if [[ ${all_services} =~ ${1} ]]; then
        echo 1
    else
        echo 0
    fi
}

function isNodeJsInstalled() {
    nodejs_status="$(dpkg -s nodejs | grep Status 2> >(log))"
    npm_status="$(dpkg -s npm | grep Status 2> >(log))"
    [[ ${npm_status} == "Status: install ok installed" && ${nodejs_status} == "Status: install ok installed" ]]
}

guest_magento_dir=$2
use_php7=$4
vagrant_dir="/vagrant"

source "${vagrant_dir}/scripts/output_functions.sh"

status "Configuring environment (recurring)"
incrementNestingLevel

status "Removing configs from host in case of force stop of virtual machine before linking restored ones"
cd "${vagrant_dir}/etc" && mv guest/.gitignore guest_gitignore.back && rm -rf guest && mkdir guest && mv guest_gitignore.back guest/.gitignore

status "Making sure configs are restored on system halt and during reboot"
# Unlink here helps in case when Virtual Machine was suspended
bash "${vagrant_dir}/scripts/guest/unlink_configs"
bash "${vagrant_dir}/scripts/guest/link_configs"

rm -f /etc/init.d/unlink-configs
cp "${vagrant_dir}/scripts/guest/unlink_configs" /etc/init.d/unlink-configs
update-rc.d unlink-configs defaults 04 2> >(log) > >(log)

status "Upgrading existing environment"
if [[ -f "${vagrant_dir}/.idea/deployment.xml" ]]; then
    sed -i.back "s|magento2ce/var/generation|magento2ce/var|g" "${vagrant_dir}/.idea/deployment.xml"
fi

status "Copying varnish vcl file"
custom_vcl_config="${vagrant_dir}/etc/magento2_default_varnish.vcl"
default_vcl_config="${vagrant_dir}/etc/magento2_default_varnish.vcl.dist"
if [ -f ${custom_vcl_config} ]; then
    cp ${custom_vcl_config}  /etc/varnish/default.vcl
else
    cp ${default_vcl_config}  /etc/varnish/default.vcl
fi

status "Setting up PHP"
php_ini_paths=( /etc/php/7.0/cli/php.ini /etc/php/5.6/cli/php.ini )
process_php_config ${php_ini_paths}

if [[ ${use_php7} -eq 1 ]]; then
    status "Configuring PHP 7"
    update-alternatives --set php /usr/bin/php7.0
    if [[ -d "/etc/php/5.6" ]]; then
        a2dismod php5.6 2> >(logError) > >(log)
    fi
    sed -i "s|xdebug.remote_connect_back=1|xdebug.remote_host=192.168.10.1|g" /etc/php/7.0/cli/conf.d/20-xdebug.ini
    a2enmod php7.0 2> >(logError) > >(log)
    # TODO: Fix for a bug, should be removed in 3.0
    sed -i "/zend_extension=.*so/d" /etc/php/7.0/cli/conf.d/20-xdebug.ini
    echo "zend_extension=xdebug.so" >> /etc/php/7.0/cli/conf.d/20-xdebug.ini
else
    status "Configuring PHP 5.6"
    if [[ ! -d "/etc/php/5.6" ]]; then
        init_php56
    fi
    update-alternatives --set php /usr/bin/php5.6 && a2dismod php7.0 && a2enmod php5.6 2> >(logError) > >(log)
    rm -rf /etc/php/5.6/apache2
    ln -s /etc/php/5.6/cli /etc/php/5.6/apache2
    sed -i "s|xdebug.remote_connect_back=1|xdebug.remote_host=192.168.10.1|g" /etc/php/5.6/mods-available/xdebug.ini
fi
service apache2 restart 2> >(logError) > >(log)

is_elastic_search_installed="$(isServiceAvailable elasticsearch)"
if [[ ${is_elastic_search_installed} -eq 0 ]]; then
    status "Setting up ElasticSearch"
    apt-get update 2> >(logError) > >(log)
    apt-get install -y openjdk-7-jre 2> >(logError) > >(log)
    wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb 2> >(logError) > >(log)
    dpkg -i elasticsearch-1.7.2.deb 2> >(logError) > >(log)
    update-rc.d elasticsearch defaults 2> >(logError) > >(log)
fi

status "Enabling email logging"
if [[ ${use_php7} -eq 1 ]]; then
    php_ini_file="/etc/php/7.0/cli/php.ini"
else
    php_ini_file="/etc/php/5.6/cli/php.ini"
fi
pattern=";sendmail_path"
php_config_content="$(cat ${php_ini_file})"
if [[ ${php_config_content} =~ ${pattern} ]]; then
    sed -i "s|;sendmail_path =|sendmail_path = \"/vagrant/scripts/guest/log_email ${vagrant_dir}/log/email\"|g" ${php_ini_file}
    service apache2 restart 2> >(logError) > >(log)
fi

if ! isNodeJsInstalled; then
    status "Installing js build tools"
    {
    apt-get install -y nodejs npm
    ln -s /usr/bin/nodejs /usr/bin/node
    npm install -g grunt-cli
    npm install gulp -g 
    } 2> >(logError) > >(log)
fi

decrementNestingLevel
