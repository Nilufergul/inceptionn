# Debian tabanlı minimal imaj (penultimate version: bullseye)
FROM debian:bullseye

# NGINX ve OpenSSL kurulumu
RUN apt-get update && apt-get install -y --no-install-recommends nginx openssl iputils-ping \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /etc/nginx/ssl /run/nginx /var/www/html \
 # Self-signed SSL sertifikası oluştur
 && openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
      -keyout /etc/nginx/ssl/server.key \
      -out /etc/nginx/ssl/server.crt \
      -subj "/C=TR/ST=Istanbul/L=Istanbul/O=42/OU=student/CN=ngulcift.42.fr"

# NGINX konfigürasyon dosyasını kopyala
COPY conf/nginx.conf /etc/nginx/nginx.conf

# HTTPS portunu dışa aç
EXPOSE 443

# NGINX'i ön planda (daemon off) çalıştır
CMD ["nginx", "-g", "daemon off;"]
