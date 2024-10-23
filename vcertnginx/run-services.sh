#!/bin/sh
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


# update the motd witht he playbook variable:
# sed -i "s|<playbook>|$(basename ${PLAYBOOK_URL})|g" /etc/motd

##############################

# Set variables
VCERT_URL="https://github.com/Venafi/vcert/releases/download/v5.7.1/vcert_v5.7.1_linux.zip"
export PLAYBOOK_URL="$PLAYBOOK_URL"
DOWNLOAD_DIR="$HOME"
TARGET_DIR="/usr/local/bin"

# Download the specific version of vcert
echo "Downloading vcert from $VCERT_URL..."
curl -L -o "$DOWNLOAD_DIR/vcert.zip" "$VCERT_URL"

# Check if the download was successful
if [ ! -f "$DOWNLOAD_DIR/vcert.zip" ]; then
  echo "Download failed or the file does not exist."
  exit 1
fi

# Unpack the zip file
echo "Unzipping vcert to $DOWNLOAD_DIR..."
unzip -o "$DOWNLOAD_DIR/vcert.zip" -d "$DOWNLOAD_DIR"

# Make the vcert binary executable
chmod +x "$DOWNLOAD_DIR/vcert"

# Move the binary to /usr/local/bin for global access
echo "Moving vcert to $TARGET_DIR..."
mv "$DOWNLOAD_DIR/vcert" "$TARGET_DIR/"

# Clean up the zip file
echo "Cleaning up..."
rm "$DOWNLOAD_DIR/vcert.zip"

# Download the YAML playbook file and place it in the home directory
echo "Downloading TLSPC_US_POD_NGINX_Demo.yaml..."
curl -L -o "$DOWNLOAD_DIR/playbook.yaml" "$PLAYBOOK_URL"

# Verify if the YAML file was downloaded successfully
if [ -f "$DOWNLOAD_DIR/TLSPC_US_POD_NGINX_Demo.yaml" ]; then
  echo "YAML playbook has been successfully downloaded and placed in $DOWNLOAD_DIR."
else
  echo "Failed to download the YAML playbook."
fi

echo "vcert setup completed successfully."

##############################

# Start SSH service
#/usr/sbin/sshd

# Function to start Nginx
start_nginx() {
    nginx 2>&1 &
    echo "Nginx started." &   
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
echo "version 02"

# Start ttyd as the main foreground process
ttyd --writable -p 7681 /bin/sh -l