#!/bin/sh
set -e

# MariaDB'nin hazır olmasını bekle
DB_HOST=$(echo ${WP_DB_HOST} | cut -d: -f1)
DB_PORT=$(echo ${WP_DB_HOST} | cut -d: -f2)
DB_PORT=${DB_PORT:-3306}

until mysqladmin ping -h${DB_HOST} -P${DB_PORT} -u${WP_DB_USER} -p${WP_DB_PASSWORD} --silent 2>/dev/null; do
  echo "Waiting for MariaDB..."
  sleep 2
done

# wp-config.php oluştur
if [ ! -f /var/www/html/wp-config.php ]; then
  cp wp-config-sample.php wp-config.php
  sed -i "s/database_name_here/${WP_DB_NAME}/" wp-config.php
  sed -i "s/username_here/${WP_DB_USER}/" wp-config.php
  sed -i "s/password_here/${WP_DB_PASSWORD}/" wp-config.php
  sed -i "s/localhost/${WP_DB_HOST}/" wp-config.php
fi

# wp-cli yardımcı fonksiyonu
wp_cli() {
  wp --allow-root --path=/var/www/html "$@"
}

# Alan adını URL'e dönüştür (http(s) prefiksi yoksa https varsay)
SITE_URL="${DOMAIN_NAME:-localhost}"
case "$SITE_URL" in
  http://*|https://*) ;;
  *) SITE_URL="https://${SITE_URL}" ;;
esac

# WordPress kurulu değilse otomatik kur
if ! wp_cli core is-installed >/dev/null 2>&1; then
  wp_cli core install \
    --url="${SITE_URL}" \
    --title="${WP_SITE_TITLE:-Inception Site}" \
    --admin_user="${WP_ADMIN_USER:-manager42}" \
    --admin_password="${WP_ADMIN_PASSWORD:-managerpass}" \
    --admin_email="${WP_ADMIN_EMAIL:-manager42@example.com}"
fi

# İkinci kullanıcıyı oluştur (yoksa)
if [ -n "${WP_USER:-}" ] && ! wp_cli user get "${WP_USER}" >/dev/null 2>&1; then
  wp_cli user create "${WP_USER}" "${WP_USER_EMAIL:-editor42@example.com}" \
    --role=author \
    --user_pass="${WP_USER_PASSWORD:-userpass}"
fi

# PHP-FPM pid/socket dizinini oluştur (Debian'da /run tmpfs olduğu için runtime'da yok)
mkdir -p /run/php
chown -R www-data:www-data /run/php

exec php-fpm7.4 -F
