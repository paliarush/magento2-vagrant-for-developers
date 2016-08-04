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

php_executable=$(bash "${vagrant_dir}/scripts/host/get_path_to_php.sh")

# Setup composer if necessary
if [[ ! -f ${composer_phar} ]]; then
    cd "${composer_dir}"
    curl -sS https://getcomposer.org/installer | ${php_executable}
fi

# Configure composer credentials
auth_json_already_exists=0
if [[ -f "${current_dir}/auth.json" ]]; then
    auth_json_already_exists=1
fi

cd "${current_dir}"
if [[ ! ${auth_json_already_exists} = 1 ]] && [[ -f ${composer_auth_json} ]]; then
    cp "${composer_auth_json}" "${current_dir}/auth.json"
fi

host_os=$(bash "${vagrant_dir}/scripts/host/get_host_os.sh")
if [[ $(bash "${vagrant_dir}/scripts/get_config_value.sh" "environment_composer_prefer_source") == 1 ]]; then
    # prefer-source is slow but guarantees that there will be no issues related to max path length on Windows
    ${php_executable} "${composer_phar}" --ignore-platform-reqs --prefer-source "$@"
else
    ${php_executable} "${composer_phar}" --ignore-platform-reqs "$@"
fi

if [[ ! ${auth_json_already_exists} = 1 ]] && [[ -f "${current_dir}/auth.json" ]]; then
    rm "${current_dir}/auth.json"
fi
