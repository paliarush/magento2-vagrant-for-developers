#!/usr/bin/env bash

# Enable trace printing and exit on the first error
set -e

guest_magento_dir=$2
host_magento_dir=$5
is_windows_host=$6

export MAGENTO_ROOT=${guest_magento_dir}
export MAGENTO_ROOT_HOST=${host_magento_dir}
export IS_WINDOWS_HOST=${is_windows_host}
