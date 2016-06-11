#!/usr/bin/env bash

# Enable trace printing and exit on the first error
set -ex

use_php7=$4

# Upgrade for vagrant box paliarush/magento2.ubuntu v1.1.0
if [[ ${use_php7} -eq 1 ]]; then
    if /usr/bin/php7.0 -v | grep -q '7.0.5' ; then
        apt-get update
        a2dismod php7.0
        rm -rf /etc/php/7.0/apache2
        export DEBIAN_FRONTEND=noninteractive
        apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install php7.0 php7.0-mcrypt php7.0-curl php7.0-cli php7.0-mysql php7.0-gd php7.0-intl php7.0-xsl php7.0-bcmath php7.0-mbstring php7.0-soap php7.0-zip libapache2-mod-php7.0
        a2enmod php7.0

        # Install XDebug
        cd /usr/lib
        rm -rf xdebug
        git clone git://github.com/xdebug/xdebug.git
        cd xdebug
        phpize
        ./configure --enable-xdebug
        make
        make install

        rm -rf /etc/php/7.0/apache2
        ln -s /etc/php/7.0/cli /etc/php/7.0/apache2

        # Restart Apache
        service apache2 restart
    fi
fi