#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/functions.sh"

magento_ce_dir="${vagrant_dir}/magento"

cd ${magento_ce_dir}
bash "${vagrant_dir}/scripts/host/composer.sh" "$@" 2> >(logError)
