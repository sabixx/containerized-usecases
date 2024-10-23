#!/bin/sh
set -e  # Exit on any command failure
set -x  # Print commands and their arguments as they are executed

# Function to generate SSL certificates
generate_certificates() {
    mkdir -p /etc/nginx/ssl

    for i in $(seq 0 $((PORT_COUNT - 1))); do
        port=$((START_PORT + $i))
        days=$((10 + $RANDOM % 10))
        cert_file="/etc/nginx/ssl/nginx_$port.crt"
        key_file="/etc/nginx/ssl/nginx_$port.key"

        # Generate certificates if not existing
        if [ ! -f "$cert_file" ] || [ ! -f "$key_file" ]; then
            openssl req -x509 -nodes -days $days -newkey rsa:2048 \
                -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=${HOSTNAME}${port}.${DOMAIN_NAME}" \
                -keyout $key_file -out $cert_file -addext "basicConstraints=CA:FALSE"
            echo "Generated SSL certificate for port $port"
        fi
    done
}

# Function to create Nginx configuration
create_nginx_config() {
    rm -f /etc/nginx/http.d/ssl_*.conf

    for i in $(seq 0 $((PORT_COUNT - 1))); do
        port=$((START_PORT + $i))

        cat <<EOF > /etc/nginx/http.d/ssl_$port.conf
server {
    listen $port ssl;
    server_name ${HOSTNAME}${port}.${DOMAIN_NAME};

    ssl_certificate /etc/nginx/ssl/nginx_$port.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx_$port.key;

    root /var/www/localhost/htdocs;
    index certificate_info_pretty.php;

    add_header X-CERTPATH /etc/nginx/ssl/nginx_$port.crt;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        fastcgi_pass 127.0.0.1:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        add_header X-CERTPATH /etc/nginx/ssl/nginx_$port.crt;
        fastcgi_param HTTP_X_CERTPATH /etc/nginx/ssl/nginx_$port.crt;
    }
}
EOF
        echo "Created Nginx configuration for port $port"
    done
}

# Function to start Nginx
start_nginx() {
    echo "Starting Nginx..."
    nginx -g "daemon off;" || { echo "Failed to start Nginx"; exit 1; }
}

# Function to monitor Nginx
monitor_nginx() {
    while true; do
        if ! pgrep -x nginx > /dev/null; then
            echo "Nginx is not running. Restarting Nginx."
            start_nginx
        fi
        sleep 10
    done
}

# Generate SSL certificates and create Nginx config
echo "Generating SSL certificates..."
generate_certificates

echo "Generating Nginx server block configuration..."
create_nginx_config

# Start PHP-FPM and Nginx
echo "Starting PHP-FPM..."
php-fpm83 || { echo "Failed to start PHP-FPM"; exit 1; }


# Start SSH service
/usr/sbin/sshd

# Function to start Nginx
start_nginx() {
    nginx 2>&1 &
    echo "Nginx started." &
    /usr/sbin/sshd
}

# Function to monitor Nginx
monitor_nginx() {
    while true; do
        if ! pgrep -x nginx > /dev/null; then
            echo "Nginx is not running. Restarting Nginx."
            start_nginx
        fi
        sleep 10
    done
}

# Start and monitor Nginx
start_nginx
monitor_nginx &

# Echo the version
echo "version 010"

# Start ttyd as the main foreground process
ttyd --writable -p 7681 /bin/sh -l