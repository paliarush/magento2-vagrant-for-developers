#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "$0")/../.."; pwd)
magento_ce_dir="${vagrant_dir}/magento2ce"
magento_ee_dir="${magento_ce_dir}/magento2ee"

# Enable trace printing and exit on the first error
set -ex

bash "${vagrant_dir}/scripts/host/check_requirements.sh"

# Check out CE repository
ce_repository_url=$(sh "${vagrant_dir}/scripts/host/get_variable_value.sh" "ce_repository_url")
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
bash "${vagrant_dir}/scripts/host/composer.sh" install

# Create vagrant project
cd ${vagrant_dir}
vagrant up

bash "${vagrant_dir}/scripts/host/configure_php_storm.sh"
