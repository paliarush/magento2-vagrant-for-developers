#!/usr/bin/env bash

# This script allows to use credentials specified in etc/composer/auth.json without declaring them globally

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/functions.sh"

status "Executing composer command"
incrementNestingLevel

composer_auth_json="${vagrant_dir}/etc/composer/auth.json"

# commented out due to composer conflicts
# ${php_executable} "${composer_phar}" global require "hirak/prestissimo:^0.3"

cd "${VAGRANT_ROOT}/magento"
if [[ -f ${composer_auth_json} ]]; then
    status "Exporting etc/auth.json to environment variable"
    export COMPOSER_AUTH="$(cat "${composer_auth_json}")"
fi

status "composer --no-interaction "$@""
composer --no-interaction "$@" 2> >(log) > >(log)

decrementNestingLevel
