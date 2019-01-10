#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/functions.sh"

magento_app_code_dir="${vagrant_dir}/magento/app/code/Magento"

cd "${magento_app_code_dir}"

status "Deleting TestModule directories"
ls | grep "TestModule" | xargs rm -rf

cd "${vagrant_dir}"

# TODO: parameterize container

executeInMagento2Container "${vagrant_dir}/scripts/guest/m-reinstall" 2> >(logError)
# Explicit exit is necessary to bypass incorrect output from vagrant in case of errors
exit 0
