#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.."; pwd)

source "${vagrant_dir}/scripts/output_functions.sh"

magento_ce_dir="${vagrant_dir}/magento2ce"

cd ${magento_ce_dir}
bash "${vagrant_dir}/scripts/host/composer.sh" "$@" 2> >(logError)
