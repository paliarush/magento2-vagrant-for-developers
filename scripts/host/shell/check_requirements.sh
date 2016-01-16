#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "$0")/../../.."; pwd)
composer_auth_json="${vagrant_dir}/local.config/composer/auth.json"

# Enable trace printing and exit on the first error
set -ex

if ! vagrant list | grep -q 'port' ; then
    set +x
    echo "Please install Vagrant 1.8 or newer (see https://www.vagrantup.com/downloads.html)"
    exit 255
    set -x
fi

if ! php -v | grep -q 'Copyright' ; then
    set +x
    echo "Please install PHP (any version) to allow Magento dependencies management using Composer."
    exit 255
    set -x
fi

if [ ! -f ${composer_auth_json} ]; then
    set +x
    echo "Please specify GitHub token in ${composer_auth_json} to bypass GitHub rate limits (see https://github.com/paliarush/magento2-vagrant-for-developers/tree/develop#github-limitations)"
    exit 255
    set -x
fi