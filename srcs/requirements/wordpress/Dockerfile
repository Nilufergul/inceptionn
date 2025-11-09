# Debian tabanlı minimal imaj (penultimate version: bullseye)
FROM debian:bullseye

# PHP-FPM, MySQL modülü ve gerekli araçlar
RUN apt-get update && apt-get install -y --no-install-recommends \
    php7.4 php7.4-fpm php7.4-mysql curl wget mariadb-client unzip ca-certificates iputils-ping \
 && rm -rf /var/lib/apt/lists/*

# PHP-FPM ayarları (Docker uyumlu)
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf \
 && sed -i 's|^;*daemonize = yes|daemonize = no|' /etc/php/7.4/fpm/php-fpm.conf \
 && sed -i 's|^;*clear_env = yes|clear_env = no|' /etc/php/7.4/fpm/pool.d/www.conf

# WordPress dosyaları
WORKDIR /var/www/html
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz \
 && tar -xvzf wordpress.tar.gz --strip-components=1 \
 && rm wordpress.tar.gz

# wp-cli kur
RUN curl -sS https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
 && chmod +x /usr/local/bin/wp

# İlk açılışta wp-config.php oluşturacak basit script
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000
CMD ["/entrypoint.sh"]
