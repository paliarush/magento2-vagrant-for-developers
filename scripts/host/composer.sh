#!/usr/bin/env bash

# This script allows to use credentials specified in etc/composer/auth.json without declaring them globally

vagrant_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.."; pwd)

source "${vagrant_dir}/scripts/functions.sh"

status "Executing composer command" 1

current_dir=${PWD}
composer_auth_json="${vagrant_dir}/etc/composer/auth.json"
composer_dir="${vagrant_dir}/scripts/host"
composer_phar="${composer_dir}/composer.phar"

bash "${vagrant_dir}/scripts/host/check_requirements.sh"

php_executable=$(bash "${vagrant_dir}/scripts/host/get_path_to_php.sh")

if [[ ! -f ${composer_phar} ]]; then
    status "Installing composer"
    cd "${composer_dir}"
    curl -sS https://getcomposer.org/installer | ${php_executable}
fi

auth_json_already_exists=0
if [[ -f "${current_dir}/auth.json" ]]; then
    auth_json_already_exists=1
fi

cd "${current_dir}"
if [[ ! ${auth_json_already_exists} = 1 ]] && [[ -f ${composer_auth_json} ]]; then
    status "Copying auth.json to magento2ce"
    cp "${composer_auth_json}" "${current_dir}/auth.json"
fi

host_os=$(bash "${vagrant_dir}/scripts/host/get_host_os.sh")
if [[ $(bash "${vagrant_dir}/scripts/get_config_value.sh" "environment_composer_prefer_source") == 1 ]]; then
    # prefer-source is slow but guarantees that there will be no issues related to max path length on Windows
    status "composer --ignore-platform-reqs --prefer-source "$@""
    ${php_executable} "${composer_phar}" --ignore-platform-reqs --prefer-source "$@" 2> >(logError) > >(log)
else
    status "composer --ignore-platform-reqs "$@""
    ${php_executable} "${composer_phar}" --ignore-platform-reqs "$@" 2> >(logError) > >(log)
fi

if [[ ! ${auth_json_already_exists} = 1 ]] && [[ -f "${current_dir}/auth.json" ]]; then
    status "Removing auth.json from magento2ce"
    rm "${current_dir}/auth.json"
fi
