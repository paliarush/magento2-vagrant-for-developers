#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"

status "Checking requirements"
incrementNestingLevel

php_executable="$(bash "${vagrant_dir}/scripts/host/get_path_to_php.sh")"

if ! ${php_executable} -v 2> >(log) | grep -q 'Copyright' ; then
    bash "${vagrant_dir}/scripts/host/install_php.sh"
fi

decrementNestingLevel
