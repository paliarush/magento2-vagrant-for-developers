#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "$0")/../.."; pwd)
host_os=$(bash "${vagrant_dir}/scripts/host/get_host_os.sh")

# Enable trace printing and exit on the first error
set -ex

if [[ ${host_os} == "Windows" ]]; then
    wget http://windows.php.net/downloads/releases/php-7.0.2-nts-Win32-VC14-x86.zip -O ${vagrant_dir}/lib/php.zip
    unzip -q ${vagrant_dir}/lib/php.zip -d ${vagrant_dir}/lib/php
    rm -f ${vagrant_dir}/lib/php.zip
fi

if ! php -v | grep -q 'Copyright' ; then
    set +x
    echo "Automatic PHP installation is not available for your host OS. Please install any version of PHP to allow Magento dependencies management using Composer. Check out http://php.net/manual/en/install.php"
    exit 255
    set -x
else
    set +x
    echo "PHP installed successfully."
    set -x
fi