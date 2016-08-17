#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.."; pwd)

source "${vagrant_dir}/scripts/functions.sh"

status "Checking requirements"
incrementNestingLevel

php_executable=$(bash "${vagrant_dir}/scripts/host/get_path_to_php.sh")

if ! ${php_executable} -v | grep -q 'Copyright' ; then
    bash "${vagrant_dir}/scripts/host/install_php.sh"
fi

decrementNestingLevel
