FROM php:7.3-apache

ENV SERVERNAME="localhost.localdomain"
ENV PEM="ssl.pem"
ENV KEY="ssl.key"

COPY apache2-foreground /usr/local/bin/apache2-foreground
COPY ./ssl/ /ssl/

#配置apache。
RUN set -x \
 && sed -i '/DocumentRoot/a\ \t\tServerName localhost.localdomain' /etc/apache2/sites-available/default-ssl.conf \
 && sed -i "33c SSLCertificateFile\t/ssl/ssl.pem" /etc/apache2/sites-available/default-ssl.conf \
 && sed -i "34c SSLCertificateKeyFile\t/ssl/ssl.key" /etc/apache2/sites-available/default-ssl.conf \
 && ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/000-default-ssl.conf \
 && sed -i "/<\/VirtualHost>/i\ \tRewriteEngine on\n\tRewriteCond %{HTTPS} !=on\n\tRewriteRule ^(.*) https://%{SERVER_NAME}$1 [L,R]" /etc/apache2/sites-available/000-default.conf \
 && a2enmod rewrite \
 && a2enmod ssl

#安装环境。
RUN set -x \
 && chmod 775 /usr/local/bin/apache2-foreground \
 && apt-get update \
 && apt-get install -y libwebp-dev libjpeg-dev libpng-dev libfreetype6-dev unzip \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install -j "$(getconf _NPROCESSORS_ONLN)" gd \
 && apt-get clean \
 && mkdir -p /usr/src/kodexplorer \
 && curl -o /tmp/kodexplorer.zip http://static.kodcloud.com/update/download/kodexplorer4.40.zip \
 && unzip -d /usr/src/kodexplorer/ /tmp/kodexplorer.zip \
 && rm -rf /tmp/*

COPY php.ini /usr/local/etc/php/php.ini
COPY setting_user.php /usr/src/kodexplorer/config/setting_user.php

VOLUME /var/www/html/ /ssl/
EXPOSE 80 443
WORKDIR /var/www/html
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["apache2-foreground"]
