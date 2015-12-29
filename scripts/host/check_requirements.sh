#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "$0")/../.."; pwd)
composer_auth_json="${vagrant_dir}/local.config/composer/auth.json"

# Enable trace printing and exit on the first error
set -ex

if ! php -v | grep -q 'Copyright' ; then
    set +x
    echo "Please install PHP to allow Magento project management using Composer."
    set -x
    exit 255
fi

if [ ! -f ${composer_auth_json} ]; then
    set +x
    echo "Please specify GitHub and Magento repository credentials in ${composer_auth_json}"
    set -x
    exit 255
fi
