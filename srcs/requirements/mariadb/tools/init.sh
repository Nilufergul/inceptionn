#!/bin/bash
set -e

# MariaDB veri dizinini kontrol et ve initialize et
if [ ! -d /var/lib/mysql/mysql ]; then
    # İlk kurulum: MariaDB'yi initialize et
    mariadb-install-db --datadir=/var/lib/mysql --user=mysql --skip-test-db
    
    # Init SQL dosyasını oluştur (environment variable'ları kullanarak)
    cat > /tmp/init.sql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

# MariaDB'yi başlat (init-file varsa otomatik çalıştırır, yoksa normal başlar)
if [ -f /tmp/init.sql ]; then
    exec mysqld_safe --datadir=/var/lib/mysql --user=mysql --init-file=/tmp/init.sql
else
    exec mysqld_safe --datadir=/var/lib/mysql --user=mysql
fi
