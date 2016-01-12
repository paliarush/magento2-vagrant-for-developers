#!/usr/bin/env bash

vagrant_dir=$PWD
magento_ce_dir="${vagrant_dir}/magento2ce"
magento_ee_dir="${magento_ce_dir}/magento2ee"

# Enable trace printing and exit on the first error
set -ex

bash "${vagrant_dir}/scripts/host/shell/check_requirements.sh"

# Check out CE repository
ce_repository_url=$(sh "${vagrant_dir}/scripts/host/shell/get_variable_value.sh" "repository_url_ce")
git clone ${ce_repository_url} ${magento_ce_dir}
# Check out EE repository
# By default EE repository is not specified and EE project is not checked out
ee_repository_custom="${vagrant_dir}/local.config/ee_repository_url.txt"
if [ -f ${ee_repository_custom} ]; then
    ee_repository_url=$(cat ${ee_repository_custom})
    git clone ${ee_repository_url} ${magento_ee_dir}
else
    set +x
    echo "Note: URL to Magento EE repository may be specified in ${ee_repository_custom}, then it will be checked out automatically."
    set -x
fi

# Update Magento dependencies via Composer
cd ${magento_ce_dir}
bash "${vagrant_dir}/scripts/host/shell/composer.sh" install

# Install necessary vagrant plugins if not installed
if ! vagrant plugin list | grep -q 'hostmanager' ; then
    vagrant plugin install vagrant-hostmanager
fi
if ! vagrant plugin list | grep -q 'vbguest' ; then
    vagrant plugin install vagrant-vbguest
fi

# Create vagrant project
cd ${vagrant_dir}
vagrant up

bash "${vagrant_dir}/scripts/host/shell/configure_php_storm.sh"
