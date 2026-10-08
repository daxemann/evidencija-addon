ARG BUILD_FROM
FROM tailscale/tailscale:stable AS ts

FROM alpine:3.21
RUN apk add --no-cache bash jq tzdata apache2 php83 php83-apache2 \
        php83-pdo php83-pdo_sqlite php83-sqlite3 php83-mbstring php83-openssl php83-zip php83-dom php83-xml \
        php83-simplexml php83-xmlwriter php83-gd php83-session php83-ctype php83-fileinfo php83-iconv \
        php83-curl php83-tokenizer php83-intl \
    && sed -i -e 's/^Listen 80$/Listen 5080/' \
              -e 's/^#LoadModule rewrite_module/LoadModule rewrite_module/' \
              -e 's#^DocumentRoot ".*"#DocumentRoot "/app"#' \
              -e 's#<Directory "/var/www/localhost/htdocs">#<Directory "/app">#' \
              -e 's/AllowOverride None/AllowOverride All/g' \
              -e 's#^ErrorLog .*#ErrorLog /dev/stderr#' \
              -e 's#^\(\s*CustomLog .*\)#\#\1#' \
              -e 's/^#ServerName .*/ServerName evidencija/' \
              /etc/apache2/httpd.conf \
    && printf 'upload_max_filesize = 64M\npost_max_size = 64M\nmemory_limit = 256M\nmax_execution_time = 300\nexpose_php = Off\nsession.gc_maxlifetime = 2592000\n' > /etc/php83/conf.d/99-evidencija.ini \
    && printf 'ServerTokens Prod\nServerSignature Off\n' >> /etc/apache2/httpd.conf

COPY --from=ts /usr/local/bin/tailscaled /usr/local/bin/tailscaled
COPY --from=ts /usr/local/bin/tailscale /usr/local/bin/tailscale

COPY app/ /app/
COPY run.sh /run.sh
RUN chmod +x /run.sh && chown -R apache:apache /app

ENV TZ=Europe/Zagreb
WORKDIR /app
CMD ["/run.sh"]
