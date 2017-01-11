#!/usr/bin/env bash

use_nfs_for_synced_folders=$1
guest_magento_dir=$2
magento_host_name=$3
use_php7=$4
host_magento_dir=$5
is_windows_host=$6

vagrant_dir="/vagrant"

source "${vagrant_dir}/scripts/output_functions.sh"

status "Configuring environment"
incrementNestingLevel

status "Enabling Magento virtual host"
custom_virtual_host_config="${vagrant_dir}/etc/magento2_virtual_host.conf"
default_virtual_host_config="${vagrant_dir}/etc/magento2_virtual_host.conf.dist"
if [[ -f ${custom_virtual_host_config} ]]; then
    virtual_host_config=${custom_virtual_host_config}
else
    virtual_host_config=${default_virtual_host_config}
fi
enabled_virtual_host_config="/etc/apache2/sites-available/magento2.conf"
cp "${virtual_host_config}" "${enabled_virtual_host_config}"
sed -i "s|<host>|${magento_host_name}|g" "${enabled_virtual_host_config}"
sed -i "s|<guest_magento_dir>|${guest_magento_dir}|g" "${enabled_virtual_host_config}"
a2ensite magento2.conf 2> >(logError) > >(log)

status "Disabling default virtual host"
sudo a2dissite 000-default 2> >(logError) > >(log)

status "Configuring composer"
composer_auth_json="${vagrant_dir}/etc/composer/auth.json"
if [[ -f ${composer_auth_json} ]]; then
    status "Installing composer OAuth tokens from ${composer_auth_json}"
    if [[ ! -d /home/vagrant/.composer ]] ; then
        sudo -H -u vagrant bash -c 'mkdir /home/vagrant/.composer' 2> >(logError) > >(log)
    fi
    if [[ -f ${composer_auth_json} ]]; then
        cp "${composer_auth_json}" "/home/vagrant/.composer/auth.json"
    fi
fi

if [[ ${use_nfs_for_synced_folders} -eq 0 ]]; then
    status "Setting permissions to allow Magento codebase upload by Vagrant provision script"
    chown -R vagrant:vagrant /var/www
    chmod -R 755 /var/www
fi

decrementNestingLevel
