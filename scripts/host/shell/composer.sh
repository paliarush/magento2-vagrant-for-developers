#!/usr/bin/env bash

# This script allows to use credentials specified in local.config/composer/auth.json without declaring them globally

current_dir=${PWD}
vagrant_dir=$(cd "$(dirname "$0")/../../.."; pwd)
composer_auth_json="${vagrant_dir}/local.config/composer/auth.json"
composer_dir="${vagrant_dir}/scripts/host"
composer_phar="${composer_dir}/composer.phar"

# Enable trace printing and exit on the first error
set -ex

bash "${vagrant_dir}/scripts/host/shell/check_requirements.sh"

# Setup composer if necessary
if [ ! -f ${composer_phar} ]; then
    cd ${composer_dir}
    curl -sS https://getcomposer.org/installer | php
fi

# Configure composer credentials
cd ${current_dir}
cp ${composer_auth_json} "${PWD}/auth.json"
php ${composer_phar} --ignore-platform-reqs "$@"
rm "${PWD}/auth.json"
