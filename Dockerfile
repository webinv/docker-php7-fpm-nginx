FROM php:7-fpm

# Maintainer
LABEL maintainer "krzysztof@kardasz.eu"

# Update system and install required packages
ENV DEBIAN_FRONTEND noninteractive

ARG APP_ENV
ENV APP_ENV ${APP_ENV:-prod}

# Common tools
RUN \
    apt-get -y update && \
    apt-get -y install curl git telnet vim autoconf file g++ gcc libc-dev make pkg-config re2c wget ca-certificates supervisor apt-transport-https software-properties-common

# Nginx
RUN \
    curl -fsSL http://nginx.org/keys/nginx_signing.key | apt-key add - && \
    add-apt-repository -s "deb http://nginx.org/packages/debian/ $(lsb_release -cs) nginx" && \
    apt-get -y update && \
    apt-get -y install nginx

# NodeJS and frontend utils
RUN \
    curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
    apt-get install -y nodejs; \
    npm install -g gulp bower;

# PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq-dev \
        libzip-dev \
        libicu-dev \
        libmcrypt-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        libwebp-dev \
        librabbitmq-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install intl \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install iconv \
    && docker-php-ext-install opcache \
    && docker-php-ext-install bcmath \
    && rm -rf /var/lib/apt/lists/*

# PECL extensions
RUN \
    pecl install zip-1.13.5 && \
    docker-php-ext-enable zip

# PHP Tools
RUN \
    wget -O /usr/local/bin/apigen http://apigen.org/apigen.phar && chmod +x /usr/local/bin/apigen && \
    curl -sS https://getcomposer.org/installer | /usr/local/bin/php -- --install-dir=/usr/local/bin --filename=composer && \
    wget -O /usr/local/bin/phpdoc http://phpdoc.org/phpDocumentor.phar && chmod +x /usr/local/bin/phpdoc && \
    wget -O /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar && chmod +x /usr/local/bin/phpunit && \
    curl -LsS http://symfony.com/installer > /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony

# Create directories
RUN mkdir -p /etc/nginx/apps.d;

# add configs & data after package install (so packages won't override them)
ADD ./etc /etc
ADD ./usr /usr

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]