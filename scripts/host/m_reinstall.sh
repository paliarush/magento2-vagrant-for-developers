#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"

magento_context="$(bash "${vagrant_dir}/scripts/host/get_magento_context.sh")"

instance_path="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "magento_context_${magento_context}_path")"
magento_ce_dir="${vagrant_dir}/magento/instances/${instance_path}"

magento_app_code_dir="${magento_ce_dir}/app/code/Magento"
if [[ -d "${magento_app_code_dir}" ]]; then
    cd "${magento_app_code_dir}"
    status "Deleting TestModule directories"
    ls | grep "TestModule" | xargs rm -rf
fi

cd "${vagrant_dir}"
vagrant ssh -c "bash /vagrant/scripts/guest/m-reinstall" 2> >(logError)
# Explicit exit is necessary to bypass incorrect output from vagrant in case of errors
exit 0
