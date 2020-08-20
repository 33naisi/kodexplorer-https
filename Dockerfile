FROM php:7.3-apache

ENV SERVERNAME="localhost.localdomain"
ENV PEM="ssl.pem"
ENV KEY="ssl.key"

COPY apache2-foreground /usr/local/bin/apache2-foreground
COPY ./ssl/ /ssl/

RUN set -x \
 && chmod 775 /usr/local/bin/apache2-foreground \
 && sed -i '/DocumentRoot/a\ \t\tServerName localhost.localdomain' /etc/apache2/sites-available/default-ssl.conf \
 && sed -i "33c SSLCertificateFile\t/ssl/ssl.pem" /etc/apache2/sites-available/default-ssl.conf \
 && sed -i "34c SSLCertificateKeyFile\t/ssl/ssl.key" /etc/apache2/sites-available/default-ssl.conf \
 && ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/000-default-ssl.conf \
 && a2enmod ssl

RUN set -x \
 && apt-get update \
 && apt-get install -y libwebp-dev libjpeg-dev libpng-dev libfreetype6-dev unzip \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install -j "$(getconf _NPROCESSORS_ONLN)" gd \
 && apt-get clean

RUN set -x \
 && mkdir -p /usr/src/kodexplorer \
 && curl -o /tmp/kodexplorer.zip http://static.kodcloud.com/update/download/kodexplorer4.40.zip \
 && unzip -d /usr/src/kodexplorer/ /tmp/kodexplorer.zip \
 && rm -rf /tmp/*

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
 && sed -i "s/max_execution_time = 30/max_execution_time = 3600/" /usr/local/etc/php/php.ini \
 && sed -i "s/max_input_time = 60/max_input_time = 3600/" /usr/local/etc/php/php.ini \
 && sed -i "s/post_max_size = 8M/post_max_size = 150M/" /usr/local/etc/php/php.ini \
 && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 150M/" /usr/local/etc/php/php.ini \
 && echo 'open_basedir = /var/www/html/:/tmp/' >> /usr/local/etc/php/php.ini \
 && echo -e '<?php\n//分片上传: 每个切片5M,需要php.ini 中upload_max_filesize大于此值\n$GLOBALS['config']['settings']['updloadChunkSize'] = 1024*1024*5;\n//上传并发数量; 推荐15个并发;\n$GLOBALS['config']['settings']['updloadThreads'] = 15;' > /usr/src/kodexplorer/config/setting_user.php

VOLUME /var/www/html/ /ssl/
EXPOSE 80 443
WORKDIR /var/www/html
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["apache2-foreground"]