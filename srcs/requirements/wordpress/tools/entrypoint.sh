#!/bin/sh
set -e

if [ ! -f /var/www/html/wp-config.php ]; then
  cp wp-config-sample.php wp-config.php
  sed -i "s/database_name_here/${WP_DB_NAME}/" wp-config.php
  sed -i "s/username_here/${WP_DB_USER}/" wp-config.php
  sed -i "s/password_here/${WP_DB_PASSWORD}/" wp-config.php
  sed -i "s/localhost/${WP_DB_HOST}/" wp-config.php
fi

exec php-fpm8.2 -F
