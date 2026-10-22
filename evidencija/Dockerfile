ARG BUILD_FROM
FROM tailscale/tailscale:stable AS ts

# Službena PHP slika (Debian + Apache + mod_php).
# 8.3.36 ispravlja PHP2Shell (CVE-2026-109618, CVE-2026-109619) – Alpine 3.21 ima samo 8.3.19.
FROM php:8.3.36-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq tzdata procps util-linux \
         libpng-dev libjpeg62-turbo-dev libfreetype6-dev libwebp-dev libzip-dev libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j"$(nproc)" gd zip intl \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod rewrite \
    && sed -i 's/^Listen 80$/Listen 5080/' /etc/apache2/ports.conf \
    && sed -i -e 's/<VirtualHost \*:80>/<VirtualHost *:5080>/' \
              -e 's#DocumentRoot /var/www/html#DocumentRoot /app#' \
              /etc/apache2/sites-available/000-default.conf \
    && printf '<Directory /app>\n    Options FollowSymLinks\n    AllowOverride All\n    Require all granted\n</Directory>\nServerName evidencija\nServerTokens Prod\nServerSignature Off\n' \
         > /etc/apache2/conf-enabled/zz-evidencija.conf \
    && printf 'upload_max_filesize = 64M\npost_max_size = 64M\nmemory_limit = 256M\nmax_execution_time = 300\nexpose_php = Off\nsession.gc_maxlifetime = 2592000\n; dodatna zaštita (PHP2Shell)\nsession.upload_progress.enabled = 0\n' \
         > /usr/local/etc/php/conf.d/99-evidencija.ini

COPY --from=ts /usr/local/bin/tailscaled /usr/local/bin/tailscaled
COPY --from=ts /usr/local/bin/tailscale /usr/local/bin/tailscale

COPY app/ /app/
COPY failover/ /failover/
COPY run.sh /run.sh
RUN chmod +x /run.sh /failover/fo.sh && chown -R www-data:www-data /app \
    && sed -i 's#DocumentRoot /app#DocumentRoot /app\n\tInclude /failover/apache-failover.conf#' /etc/apache2/sites-available/000-default.conf

ENV TZ=Europe/Zagreb
WORKDIR /app
CMD ["/run.sh"]
