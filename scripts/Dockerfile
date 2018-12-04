FROM shiftedreality/magento-kubernetes-components-php:7.1-fpm

RUN apt-get update && apt-get install -y mysql-client && rm -rf /var/lib/apt

ENV PATH="/var/www/html/scripts/guest:/var/www/html/magento/bin:${PATH}"
ENV MAGENTO_ROOT "/var/www/html/magento"
ENV MAGENTO_ROOT_HOST "/Users/<user>/Projects/magento2-kubernetes-for-developers/magento"
ENV IS_WINDOWS_HOST 0
ENV VAGRANT_ROOT "/var/www/html"
ENV VAGRANT_ROOT_HOST "/Users/<user>/Projects/magento2-kubernetes-for-developers"

CMD ["php-fpm", "-R"]
