# Debian tabanlı minimal imaj (penultimate version: bookworm)
FROM debian:bookworm

# PHP-FPM, MySQL modülü ve gerekli araçlar
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2 php8.2-fpm php8.2-mysql curl wget mariadb-client unzip \
 && rm -rf /var/lib/apt/lists/*

# PHP-FPM ayarları (Docker uyumlu)
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf \
 && sed -i 's|^;*daemonize = yes|daemonize = no|' /etc/php/8.2/fpm/php-fpm.conf \
 && sed -i 's|^;*clear_env = yes|clear_env = no|' /etc/php/8.2/fpm/pool.d/www.conf

# WordPress dosyaları
WORKDIR /var/www/html
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz \
 && tar -xvzf wordpress.tar.gz --strip-components=1 \
 && rm wordpress.tar.gz

# İlk açılışta wp-config.php oluşturacak basit script
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000
CMD ["/entrypoint.sh"]
