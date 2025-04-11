FROM php:7.4-apache
#FROM php:apache

# Omeka-S web publishing platform for digital heritage collections (https://omeka.org/s/)
# Initial maintainer: Godwin Yeboah - Warwick Research Computing
LABEL maintainer_name="Godwin Yeboah"
LABEL maintainer_email="g.yeboah@warwick.ac.uk"
LABEL maintainer_email2="yeboahgodwin@gmail.com"
LABEL description="Docker for Omeka-S (version 4.1.1) \
web publishing platform for digital heritage collections (https://omeka.org/s/)."

RUN a2enmod rewrite

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -qq -y upgrade
RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
    unzip \
    zip \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libmcrypt-dev \
    nano \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick \
    libmagickwand-dev

# Install the PHP extensions we need
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql mysqli gd xml xmlrpc xmlwriter calendar json
RUN pecl install mcrypt-1.0.4 && docker-php-ext-enable mcrypt && pecl install imagick && docker-php-ext-enable imagick 
RUN docker-php-ext-install exif && docker-php-ext-enable exif

COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml
COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml
COPY ./database.ini /tmp/omeka-install/database.ini
COPY ./.htaccess /tmp/omeka-install/.htaccess

COPY omekaLocalDirectory.sh /omekaLocalDirectory.sh
RUN chmod +x /omekaLocalDirectory.sh

# Commande d'entrée
ENTRYPOINT ["/omekaLocalDirectory.sh"]


