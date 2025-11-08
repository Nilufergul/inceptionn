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

exec php-fpm8.2 -F
