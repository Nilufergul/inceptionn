# Debian tabanlı minimal imaj (penultimate version: bookworm)
FROM debian:bookworm

# MariaDB ve gerekli araçları kur
RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# MariaDB veri dizinini oluştur
RUN mkdir -p /var/lib/mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# Init script'i kopyala
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

# MariaDB'nin veri dizinlerini kalıcı hale getireceğiz
VOLUME ["/var/lib/mysql"]

# MariaDB'nin dinlediği portu expose ediyoruz
EXPOSE 3306

# Init script'i çalıştır ve MariaDB'yi başlat
CMD ["/init.sh"]
