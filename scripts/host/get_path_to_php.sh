#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"
incrementNestingLevel

# Find path to available PHP
if [[ -f "${vagrant_dir}/lib/php/php.exe" ]]; then
    php_executable="${vagrant_dir}/lib/php/php"
else
    php_executable="php"
fi
echo ${php_executable}

decrementNestingLevel
