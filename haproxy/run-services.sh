#!/bin/sh

generate_certificates() {
    # Create SSL directory if it doesn't exist
    mkdir -p /etc/haproxy/certs

    # Generate multiple self-signed certificates for different ports
    for i in $(seq 0 $((PORT_COUNT - 1))); do
      port=$((START_PORT + $i))
      days=$((10 + $RANDOM % 10))
      cert_file="/etc/haproxy/certs/haproxy_$port.pem"

      # Generate self-signed certificate
      openssl req -x509 -nodes -days $days -newkey rsa:2048 \
        -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=${HOSTNAME}${port}.${DOMAIN_NAME}" \
        -keyout /tmp/haproxy_$port.key -out /tmp/haproxy_$port.crt \
        -addext "basicConstraints=CA:FALSE"

      # Combine key and certificate into a single .pem file for HAProxy
      cat /tmp/haproxy_$port.key /tmp/haproxy_$port.crt > $cert_file

      echo "Generated certificate for port $port"

      # Clean up temporary files
      rm /tmp/haproxy_$port.key /tmp/haproxy_$port.crt
    done
}

generate_haproxy_config() {
    # Create the HAProxy configuration
    cat << EOF > /etc/haproxy/haproxy.cfg
global
    log stdout format raw local0
    maxconn 4096
    user haproxy
    group haproxy
    ssl-default-bind-options ssl-min-ver TLSv1.2

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
EOF

    # Generate frontend configurations for each port
    for i in $(seq 0 $((PORT_COUNT - 1))); do
      port=$((START_PORT + $i))
      cat << EOF >> /etc/haproxy/haproxy.cfg

frontend https-in-$port
    bind *:$port ssl crt /etc/haproxy/certs/haproxy_$port.pem ca-file /etc/haproxy/certs/haproxy_$port.pem
    http-request set-header X-Original-Port %[dst_port]
    default_backend servers
EOF
    done

    # Append the backend configuration
    cat << EOF >> /etc/haproxy/haproxy.cfg

backend servers
    balance roundrobin
    server server1 127.0.0.1:80 check
EOF
}

# Set defaults for the environment variables if not provided
PORT_COUNT=${PORT_COUNT:-1}
START_PORT=${START_PORT:-443}
DOMAIN_NAME=${DOMAIN_NAME:-example.com}
HOSTNAME=${HOSTNAME:-haproxy}

# Generate certificates and HAProxy configuration
generate_certificates
generate_haproxy_config

# Start SSH service
/usr/sbin/sshd

# Start PHP-FPM service
php-fpm83 || { echo "Failed to start PHP-FPM"; exit 1; }

# Start Nginx service in the background
nginx || { echo "Failed to start Nginx"; exit 1; } &

start_haproxy() {
    echo "Starting HAProxy..."
    haproxy -f /etc/haproxy/haproxy.cfg
}

monitor_haproxy() {
    while true; do
        if ! pgrep -x haproxy > /dev/null; then
            echo "HAProxy is not running. Restarting HAProxy."
            start_haproxy
        fi
        sleep 10
    done
}

echo "version 013"

monitor_haproxy & 

# Display MOTD when ttyd starts (local shell)
#[ -f /etc/motd ] && cat /etc/motd

# Start ttyd as the main foreground process
ttyd --writable -p 7681 /bin/sh -l