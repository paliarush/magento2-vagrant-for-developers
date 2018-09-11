#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"


magento_context="$(bash "${vagrant_dir}/scripts/host/get_magento_context.sh")"
instance_path="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "magento_context_${magento_context}_path")"
magento_ce_dir="${vagrant_dir}/magento/instances/${instance_path}"

cd ${magento_ce_dir}
bash "${vagrant_dir}/scripts/host/composer.sh" "$@" 2> >(logError)
