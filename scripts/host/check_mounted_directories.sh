#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/functions.sh"

cd "${vagrant_dir}"
#if [[ ! -f "${vagrant_dir}/magento/composer.json" ]]; then
#    error "Directory '${vagrant_dir}/magento' was not mounted as expected by Vagrant.
#        Please make sure that 'paliarush/magento2.ubuntu' Vagrant box was downloaded successfully (if not, this may help http://stackoverflow.com/questions/35519389${vagrant_dir}-cannot-find-box)
#        And that Vagrant is able to mount VirtualBox shared folders on your environment (see https://www.vagrantup.com/docs/synced-folders/basic_usage.html ).
#        Also remove any stale declarations from /etc/exports on the host."
#    exit 1
#fi
executeInMagento2Container bash -- "${vagrant_dir}/scripts/guest/check_mounted_directories" 2> >(logError)
# Explicit exit is necessary to bypass incorrect output from vagrant in case of errors
exit 0
