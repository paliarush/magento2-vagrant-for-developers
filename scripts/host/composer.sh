#!/usr/bin/env bash

# This script allows to use credentials specified in etc/composer/auth.json without declaring them globally

current_dir=${PWD}
vagrant_dir=$(cd "$(dirname "$0")/../.."; pwd)
composer_auth_json="${vagrant_dir}/etc/composer/auth.json"
composer_dir="${vagrant_dir}/scripts/host"
composer_phar="${composer_dir}/composer.phar"

# Enable trace printing and exit on the first error
set -ex

bash "${vagrant_dir}/scripts/host/check_requirements.sh"

# Setup composer if necessary
if [ ! -f ${composer_phar} ]; then
    cd ${composer_dir}
    curl -sS https://getcomposer.org/installer | php
fi

# Configure composer credentials
cd ${current_dir}
cp ${composer_auth_json} "${PWD}/auth.json"

php_executable=$(bash "${vagrant_dir}/scripts/host/get_path_to_php.sh")
host_os=$(bash "${vagrant_dir}/scripts/host/get_host_os.sh")
if [[ $(bash "${vagrant_dir}/scripts/get_config_value.sh" "environment_composer_prefer_source") == 1 ]]; then
    # prefer-source is slow but guarantees that there will be no issues related to max path length on Windows
    ${php_executable} ${composer_phar} --ignore-platform-reqs --prefer-source "$@"
else
    ${php_executable} ${composer_phar} --ignore-platform-reqs "$@"
fi
rm "${PWD}/auth.json"
