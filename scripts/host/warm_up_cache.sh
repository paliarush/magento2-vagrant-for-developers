#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/functions.sh"

cd "${vagrant_dir}"
executeInMagento2Container "${vagrant_dir}/scripts/guest/warm_up_cache" 2> >(logError)
# Explicit exit is necessary to bypass incorrect output from vagrant in case of errors
exit 0
