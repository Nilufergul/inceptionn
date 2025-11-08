#!/bin/bash
set -e

# MariaDB veri dizinini kontrol et ve initialize et
if [ ! -d /var/lib/mysql/mysql ]; then
    # İlk kurulum: MariaDB'yi initialize et
    mariadb-install-db --datadir=/var/lib/mysql --user=mysql --skip-test-db
    
    # Init SQL dosyasını oluştur
    cat > /tmp/init.sql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    # MariaDB'yi init-file ile başlat (ilk kurulum)
    exec mysqld_safe --datadir=/var/lib/mysql --user=mysql --init-file=/tmp/init.sql
else
    # Veritabanı zaten var, arka planda başlat ve veritabanı/kullanıcı kontrolü yap
    mysqld_safe --datadir=/var/lib/mysql --user=mysql &
    MYSQL_PID=$!
    
    # MariaDB'nin başlamasını bekle
    until mysqladmin ping -h localhost -u root --silent 2>/dev/null; do
        sleep 1
    done
    
    # Veritabanı ve kullanıcıyı kontrol et ve oluştur
    mysql -u root -p${MYSQL_ROOT_PASSWORD} <<EOF 2>/dev/null || mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    # Foreground'a al
    wait $MYSQL_PID
fi
