FROM shiftedreality/magento-kubernetes-components-php:7.1-fpm

RUN apt-get update && apt-get install -y mysql-client && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y redis-tools && rm -rf /var/lib/apt/lists/*

ENV PATH="/var/www/html/scripts/guest:/var/www/html/magento/bin:${PATH}"
ENV MAGENTO_ROOT "/var/www/html/magento"
# TODO: Generate host path dynamically
ENV MAGENTO_ROOT_HOST "/Users/<user>/Projects/magento2-kubernetes-for-developers/magento"
ENV VAGRANT_ROOT_HOST "/Users/<user>/Projects/magento2-kubernetes-for-developers"
ENV IS_WINDOWS_HOST 0
ENV VAGRANT_ROOT "/var/www/html"

CMD ["php-fpm", "-R"]
