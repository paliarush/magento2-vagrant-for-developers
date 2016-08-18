#!/usr/bin/env bash

set -e

guest_magento_dir=$2
host_magento_dir=$5
is_windows_host=$6
host_vagrant_dir=$7
vagrant_dir="/vagrant"

source "${vagrant_dir}/scripts/output_functions.sh"

status "Exporting environment variables"
incrementNestingLevel

if ! cat /etc/profile | grep -q 'export PATH=' ; then
    echo "export PATH=\$PATH:${vagrant_dir}/scripts/guest:$\"{guest_magento_dir}/bin\"" >> /etc/profile
fi

if ! cat /etc/profile | grep -q 'export MAGENTO_ROOT=' ; then
    echo "export MAGENTO_ROOT=\"${guest_magento_dir}\"" >> /etc/profile
    echo "export MAGENTO_ROOT_HOST=\"${host_magento_dir}\"" >> /etc/profile
    echo "export IS_WINDOWS_HOST=${is_windows_host}" >> /etc/profile
fi

if ! cat /etc/profile | grep -q 'export VAGRANT_ROOT=' ; then
    echo "export VAGRANT_ROOT=${vagrant_dir}" >> /etc/profile
    echo "export VAGRANT_ROOT_HOST=\"${host_vagrant_dir}\"" >> /etc/profile
fi

decrementNestingLevel
