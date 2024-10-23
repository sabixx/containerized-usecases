#!/bin/sh

# Generate certificates if necessary
generate_certificates() {
    mkdir -p /etc/tomcat
    mkdir -p /usr/share/tomcat/ssl


    for i in $(seq 0 $((PORT_COUNT - 1))); do
        port=$((START_PORT + $i))
        keystore_file="/usr/share/tomcat/ssl/tomcat_$port.jks"
        alias="tomcat$port"
        storepass="changeit"

        if [ ! -f "$keystore_file" ]; then
            keytool -genkey -alias "$alias" -keyalg RSA -keystore "$keystore_file" \
                -storepass "$storepass" -keypass "$storepass" \
                -dname "CN=${HOSTNAME}${port}.${DOMAIN_NAME}, OU=Denial, O=Dis, L=Springfield, ST=Denial, C=US" \
                -validity 365
            echo "Generated keystore for port $port"
        fi
    done
}

# Create Tomcat SSL configuration
create_tomcat_config() {
    rm -f /etc/tomcat/tomcat-ssl-*.xml

    for i in $(seq 0 $((PORT_COUNT - 1))); do
        port=$((START_PORT + $i))

        cat <<EOF > /etc/tomcat/tomcat-ssl-$port.xml
<Connector port="$port" protocol="org.apache.coyote.http11.Http11NioProtocol" 
    SSLEnabled="true" maxThreads="150" scheme="https" secure="true" 
    clientAuth="false" sslProtocol="TLS"
    keystoreFile="/usr/share/tomcat/ssl/tomcat_$port.jks"
    keystorePass="changeit"
    keyAlias="tomcat$port" />
EOF
        echo "Created Tomcat SSL configuration for port $port"
    done
}

# Modify the server.xml for SSL only
modify_server_xml() {
    echo "Adding SSL connectors dynamically"
    for i in $(seq 0 $((PORT_COUNT - 1))); do
        port=$((START_PORT + $i))

        if ! grep -q "port=\"$port\"" /usr/share/tomcat/conf/server.xml; then
            sed -i "/<\/Service>/i \
            <Connector port=\"$port\" protocol=\"org.apache.coyote.http11.Http11NioProtocol\" \n\
                maxThreads=\"150\" SSLEnabled=\"true\" scheme=\"https\" secure=\"true\" clientAuth=\"false\" \n\
                sslProtocol=\"TLS\" keystoreFile=\"/usr/share/tomcat/ssl/tomcat_$port.jks\" \n\
                keystorePass=\"changeit\" />" /usr/share/tomcat/conf/server.xml
            echo "Added SSL connector for port $port to server.xml"
        fi
    done

    sed -i 's/port="8005"/port="8006"/' /usr/share/tomcat/conf/server.xml
    echo "Shutdown port successfully updated to 8006."
}

# Monitor Tomcat to ensure it is running
monitor_tomcat() {
    while true; do
        if ! pgrep -f 'org.apache.catalina.startup.Bootstrap' > /dev/null; then
            echo "Tomcat is not running. Restarting Tomcat..."
            /usr/share/tomcat/bin/catalina.sh start
        fi
        sleep 30
    done
}

# Generate certificates and config
generate_certificates
create_tomcat_config
modify_server_xml

# Start Tomcat in the background
echo "Starting Tomcat..."
/usr/share/tomcat/bin/catalina.sh start &

# Start Tomcat monitoring
monitor_tomcat &

echo "version 000"

# Start ttyd in the foreground
echo "Starting ttyd..."
ttyd --writable -p 7681 /bin/sh -l
