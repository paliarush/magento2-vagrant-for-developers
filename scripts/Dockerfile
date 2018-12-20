FROM php:7.1-fpm

# Install dependencies
RUN apt-get update \
  && apt-get install -y \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libxslt1-dev \
    sendmail-bin \
    sendmail \
    sudo \
    net-tools \
    nano

# Configure the gd library
RUN docker-php-ext-configure \
  gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN docker-php-ext-configure opcache --enable-opcache

# Install required PHP extensions
RUN docker-php-ext-install \
  dom \
  gd \
  intl \
  mbstring \
  mcrypt \
  pdo_mysql \
  xsl \
  zip \
  bcmath \
  soap \
  opcache

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN pecl install -o -f xdebug

RUN apt-get update && apt-get install -y mysql-client && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y redis-tools && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y rsync && rm -rf /var/lib/apt/lists/*

ENV DUMMY="Dummy variable which can be modified for image regeneration, when changes are done to the files copied later"

ENV PATH="/var/www/html/scripts/guest:/var/www/html/magento/bin:${PATH}"
ENV MAGENTO_ROOT "/var/www/html/magento"
# TODO: Generate host path dynamically
ENV MAGENTO_ROOT_HOST "/Users/<user>/Projects/magento2-kubernetes-for-developers/magento"
ENV VAGRANT_ROOT_HOST "/Users/<user>/Projects/magento2-kubernetes-for-developers"
ENV IS_WINDOWS_HOST 0
ENV VAGRANT_ROOT "/var/www/html"
ENV COMPOSER_HOME "/var/www/shared/.composer"

COPY etc/php-xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug-settings.ini
COPY etc/php-fpm.ini /usr/local/etc/php/conf.d/zz-magento.ini
COPY etc/php-fpm.conf /usr/local/etc/

CMD ["php-fpm", "-R"]
