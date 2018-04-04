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
        fi
    done
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
use_php7=$4 # TODO: Remove deprecated argument, php_version should be used instead
php_version=$8

# TODO: Remove support for deprecated argument use_php7
if [[ -z ${php_version} ]]; then
    if [[ ${use_php7} -eq 1 ]]; then
        php_version="7.0"
    else
        php_version="5.6"
    fi
fi


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

php_ini_paths=( /etc/php/5.6/cli/php.ini /etc/php/7.0/cli/php.ini /etc/php/7.1/cli/php.ini /etc/php/7.2/cli/php.ini )
process_php_config ${php_ini_paths}

if [[ ${php_version} == "5.6" ]] || [[ ${php_version} == "7.0" ]] || [[ ${php_version} == "7.1" ]] || [[ ${php_version} == "7.2" ]]; then
    status "Configuring PHP ${php_version}"
    update-alternatives --set php "/usr/bin/php${php_version}"
    a2dismod php5.6 2> >(logError) > >(log) && a2dismod php7.0 2> >(logError) > >(log) && a2dismod php7.1 2> >(logError) > >(log) && a2dismod php7.2 2> >(logError) > >(log)
    a2enmod "php${php_version}" 2> >(logError) > >(log)
    sed -i "s|xdebug.remote_connect_back=1|xdebug.remote_host=192.168.10.1|g" "/etc/php/${php_version}/cli/conf.d/20-xdebug.ini"
else
    error "PHP version specified in the etc/config.yam is not supported."
    decrementNestingLevel
    exit 1
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
php_ini_file="/etc/php/${php_version}/cli/php.ini"
pattern=";sendmail_path"
php_config_content="$(cat ${php_ini_file})"
if [[ ${php_config_content} =~ ${pattern} ]]; then
    sed -i "s|;sendmail_path =|sendmail_path = \"/vagrant/scripts/guest/log_email ${vagrant_dir}/log/email\"|g" ${php_ini_file}
    service apache2 restart 2> >(logError) > >(log)
fi

# 'n lts' below installs the latest long term support version of Nodejs
if ! isNodeJsInstalled; then
    status "Installing js build tools"
    {
    apt-get install -y nodejs npm
    ln -s /usr/bin/nodejs /usr/bin/node
    npm install -g grunt-cli
    npm install gulp -g
    npm install -g n
    n lts
    } 2> >(logError) > >(log)
fi

decrementNestingLevel
