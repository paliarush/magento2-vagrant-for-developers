#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "$0")/../.."; pwd)
magento_ce_dir="${vagrant_dir}/magento2ce"
magento_ee_dir="${magento_ce_dir}/magento2ee"
ce_repository_default="${vagrant_dir}/local.config/ce_repository_url.txt.dist"
ce_repository_custom="${vagrant_dir}/local.config/ce_repository_url.txt"
# By default EE repository is not specified and EE project cannot be checked out
ee_repository_custom="${vagrant_dir}/local.config/ee_repository_url.txt"

# Enable trace printing and exit on the first error
set -ex

bash "${vagrant_dir}/scripts/host/check_requirements.sh"

# Check out CE repository
rm -f "${magento_ee_dir}/.gitkeep"
rm -rf ${magento_ee_dir}
if [ -f ${ce_repository_custom} ]; then
    ce_repository_url=$(cat ${ce_repository_custom})
else
    ce_repository_url=$(cat ${ce_repository_default})
fi
git clone ${ce_repository_url} ${magento_ce_dir}

# Check out EE repository
if [ -f ${ee_repository_custom} ]; then
    ee_repository_url=$(cat ${ee_repository_custom})
    git clone ${ee_repository_url} ${magento_ee_dir}
else
    set +x
    echo "Note: URL to Magento EE repository may be specified in ${ee_repository_custom}, then it will be checked out automatically."
    set -x
    mkdir ${magento_ee_dir}
fi

# Update Magento dependencies via Composer
cd ${magento_ce_dir}
bash "${vagrant_dir}/scripts/host/composer.sh" install

# Create vagrant project
cd ${vagrant_dir}
vagrant up
