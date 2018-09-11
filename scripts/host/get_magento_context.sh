#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"

cd "${vagrant_dir}"
# remove special characters if any
magento_context=$(vagrant ssh -c "bash /vagrant/scripts/guest/get_magento_context" | tr -cd "[:print:]\n") 2> >(logError)
echo ${magento_context}
