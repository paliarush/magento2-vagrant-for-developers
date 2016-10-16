#!/usr/bin/env bash

# This script allows to use credentials specified in etc/composer/auth.json without declaring them globally

current_dir=${PWD}
cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"

status "Executing composer command"
incrementNestingLevel

composer_auth_json="${vagrant_dir}/etc/composer/auth.json"
composer_dir="${vagrant_dir}/scripts/host"
composer_phar="${composer_dir}/composer.phar"

bash "${vagrant_dir}/scripts/host/check_requirements.sh"

php_executable="$(bash "${vagrant_dir}/scripts/host/get_path_to_php.sh")"

if [[ ! -f ${composer_phar} ]]; then
    status "Installing composer"
    cd "${composer_dir}"
    curl -sS https://getcomposer.org/installer | ${php_executable} 2> >(logError) > >(log)
fi

# commented out due to composer conflicts
# ${php_executable} "${composer_phar}" global require "hirak/prestissimo:^0.3"

cd "${current_dir}"
if [[ -f ${composer_auth_json} ]]; then
    status "Exporting etc/auth.json to environment variable"
    export COMPOSER_AUTH="$(cat "${composer_auth_json}")"
fi

host_os="$(bash "${vagrant_dir}/scripts/host/get_host_os.sh")"
if [[ $(bash "${vagrant_dir}/scripts/get_config_value.sh" "environment_composer_prefer_source") == 1 ]]; then
    # prefer-source is slow but guarantees that there will be no issues related to max path length on Windows
    status "composer --ignore-platform-reqs --prefer-source --no-interaction "$@""
    ${php_executable} "${composer_phar}" --ignore-platform-reqs --prefer-source --no-interaction "$@" 2> >(log) > >(log)
else
    status "composer --ignore-platform-reqs --no-interaction "$@""
    ${php_executable} "${composer_phar}" --ignore-platform-reqs --no-interaction "$@" 2> >(log) > >(log)
fi

decrementNestingLevel
