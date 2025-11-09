#!/bin/sh
set -e

DATA_DIR="/var/lib/mysql"
SYSTEM_DB="${DATA_DIR}/mysql"
RUNTIME_DIR="/run/mysqld"

# Environment fallbacks (common variable names used by various setups)
MYSQL_DATABASE=${MYSQL_DATABASE:-wordpress}
MYSQL_USER=${MYSQL_USER:-wp_user}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-wp_pass}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-${DB_ROOT_PASSWORD:-${WP_DB_ROOT:-}}}

# Require a root password to avoid leaving the DB unsecured
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "ERROR: MYSQL_ROOT_PASSWORD is not set. Set it in your environment or .env file." >&2
  exit 1
fi

# Sistem DB henüz yoksa veritabanı dizinini hazırlayıp initialize et
mkdir -p "$DATA_DIR" "$RUNTIME_DIR"
chown -R mysql:mysql "$DATA_DIR" "$RUNTIME_DIR"

# Sistem DB henüz yoksa veritabanı dizinini hazırlayıp initialize et
if [ ! -d "$SYSTEM_DB" ]; then
    echo "Initializing MariaDB data directory..."

    if command -v mysql_install_db >/dev/null 2>&1; then
        mysql_install_db --basedir=/usr --datadir="$DATA_DIR" --user=mysql --rpm
    else
        mariadb-install-db --basedir=/usr --datadir="$DATA_DIR" --user=mysql --skip-test-db
    fi
fi

# WordPress veritabanı yoksa oluştur ve kullanıcıyı yetkilendir
if [ ! -d "${DATA_DIR}/${MYSQL_DATABASE}" ]; then
    echo "Creating database and user ${MYSQL_DATABASE} / ${MYSQL_USER}..."

    cat > /tmp/create_db.sql <<-EOF
USE mysql;
FLUSH PRIVILEGES;

DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';

DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    mysqld --user=mysql --bootstrap < /tmp/create_db.sql
    rm -f /tmp/create_db.sql
fi

# MariaDB'yi foreground'da çalıştır (runtime dizinini yeniden sahiplen)
chown mysql:mysql "$RUNTIME_DIR"
exec mysqld_safe --user=mysql --datadir="$DATA_DIR"
