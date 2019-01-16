FROM magento2-monolith:dev

RUN   sed -i "s|;zend_extension=xdebug.so|zend_extension=xdebug.so|g" /usr/local/etc/php/conf.d/zz-xdebug-settings.ini
RUN   sed -i "s|listen = 0.0.0.0:9001|listen = 0.0.0.0:9002|g" /usr/local/etc/php-fpm.conf
