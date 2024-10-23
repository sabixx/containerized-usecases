#!/bin/sh

# Function to generate SSL certificates
generate_certificates() {
    # Create SSL directory if not exists
    mkdir -p /etc/apache2/ssl

    # Generate multiple self-signed certificates for different ports
    for i in $(seq 0 $((PORT_COUNT - 1))); do
      port=$((START_PORT + $i))
      days=$((10 + $RANDOM % 10))
      openssl req -x509 -nodes -days $days -newkey rsa:2048 \
        -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=${HOSTNAME}${port}.${DOMAIN_NAME}" \
        -keyout /etc/apache2/ssl/apache_$port.key -out /etc/apache2/ssl/apache_$port.crt \
        -addext "basicConstraints=CA:FALSE"
    done
}

# Function to create Apache VirtualHost configuration
create_apache_config() {
    for i in $(seq 0 $((PORT_COUNT - 1))); do
        port=$((START_PORT + $i))

        echo "Listen $port" >> /etc/apache2/httpd.conf
        echo "<VirtualHost *:$port>" > /etc/apache2/conf.d/ssl_$port.conf        
        echo "  SSLEngine on" >> /etc/apache2/conf.d/ssl_$port.conf
        echo "  SSLCertificateFile /etc/apache2/ssl/apache_$port.crt" >> /etc/apache2/conf.d/ssl_$port.conf
        echo "  SSLCertificateChainFile /etc/apache2/ssl/apache_$port.crt" >> /etc/apache2/conf.d/ssl_$port.conf        
        echo "  SSLCertificateKeyFile /etc/apache2/ssl/apache_$port.key" >> /etc/apache2/conf.d/ssl_$port.conf
        echo "  RequestHeader set X-CERTPATH /etc/apache2/ssl/apache_$port.crt" >> /etc/apache2/conf.d/ssl_$port.conf
        echo "  ServerName ${HOSTNAME}${port}.${DOMAIN_NAME}" >> /etc/apache2/conf.d/ssl_$port.conf
        echo "  DocumentRoot /var/www/localhost/htdocs" >> /etc/apache2/conf.d/ssl_$port.conf
        echo "  <Directory \"/var/www/localhost/htdocs\">" >> /etc/apache2/conf.d/ssl_$port.conf
        echo "    AllowOverride None" >> /etc/apache2/conf.d/ssl_$port.conf
        echo "    Require all granted" >> /etc/apache2/conf.d/ssl_$port.conf
        echo "  </Directory>" >> /etc/apache2/conf.d/ssl_$port.conf
        echo "</VirtualHost>" >> /etc/apache2/conf.d/ssl_$port.conf
        echo "Created VirtualHost configuration for port $port"
    done
}

# Start SSH service
/usr/sbin/sshd

# Generate SSL certificates and Apache configuration
echo "Generating SSL certificates..."
generate_certificates

echo "Generating Apache VirtualHost configuration..."
create_apache_config

# Function to start HTTPD
start_httpd() {
    echo "Starting HTTPD..."
    php-fpm83
    httpd -D FOREGROUND 2>&1 &
}

# Function to monitor HTTPD
monitor_httpd() {
    while true; do
        if ! pgrep -x httpd > /dev/null; then
            echo "HTTPD is not running. Restarting HTTPD."
            start_httpd
        fi
        sleep 10
    done
}

# Start and monitor HTTPD
start_httpd
monitor_httpd &

# Echo the version
echo "version 010"

# Start ttyd as the main foreground process
ttyd --writable -p 7681 /bin/sh -l
