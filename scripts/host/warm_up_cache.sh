#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"

cd "${vagrant_dir}"
vagrant ssh -c "bash /vagrant/scripts/guest/warm_up_cache" 2> >(logError)
