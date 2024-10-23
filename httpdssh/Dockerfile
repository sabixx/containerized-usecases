# Use Alpine Linux as the base image
FROM alpine:latest

# Set environment variables for ports, hostname, and domain name
ENV START_PORT=30444
ENV PORT_COUNT=5
ENV HOSTNAME=myapp
ENV DOMAIN_NAME=tlsp.demo
ENV username=venafi
ENV password=Insecure123!

# Install OpenSSH, Apache2 with SSL support, PHP 8.3, OpenSSL, and required Apache modules
RUN apk update && \
    apk add coreutils openssh apache2 apache2-ssl openssl php83 php83-openssl php83-fpm apache2-proxy apache2-proxy-html ttyd && \
    rm -rf /var/cache/apk/*

# Install openrc and sudo
RUN apk add --no-cache openrc sudo

# Add command to display MOTD to the profile
COPY motd /etc/motd
RUN echo "[ -f /etc/motd ] && cat /etc/motd" >> /etc/profile

# Configure SSH
RUN echo 'root:root' | chpasswd
RUN ssh-keygen -A
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/#PasswordAuthentication no/' /etc/ssh/sshd_config

# Create a user and add them to the sudoers file
RUN adduser -D $username && \
    echo "$username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$username && \
    chmod 0440 /etc/sudoers.d/$username && \
    echo "$username:$password" | chpasswd

 # Install and configure SSH
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "AllowUsers ${username}" >> /etc/ssh/sshd_config   

# Enable SSL, Proxy, and PHP-FPM Modules in Apache and set DirectoryIndex
RUN echo "LoadModule ssl_module modules/mod_ssl.so" >> /etc/apache2/httpd.conf && \
    echo "LoadModule proxy_module modules/mod_proxy.so" >> /etc/apache2/httpd.conf && \
    echo "LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so" >> /etc/apache2/httpd.conf && \
    echo "Include /etc/apache2/conf.d/php-fpm.conf" >> /etc/apache2/httpd.conf && \
    echo "DirectoryIndex certificate_info_pretty.php index.html" >> /etc/apache2/httpd.conf && \
    echo "<FilesMatch \\.php$>" > /etc/apache2/conf.d/php-fpm.conf && \
    echo "    SetHandler \"proxy:fcgi://127.0.0.1:9000\"" >> /etc/apache2/conf.d/php-fpm.conf && \
    echo "</FilesMatch>" >> /etc/apache2/conf.d/php-fpm.conf

# Set a global ServerName to avoid warnings
RUN echo "ServerName localhost" >> /etc/apache2/httpd.conf

# remove the default index.html
RUN rm /var/www/localhost/htdocs/index.html
RUN echo "extension=openssl" >> /etc/php83/php.ini

# Copy the PHP file into the container's web root directory
COPY certificate_info_pretty.php /var/www/localhost/htdocs/
COPY Venafi_CYBR_logo_R.svg /var/www/localhost/htdocs/

# copy the reset command
COPY reset_pod.sh /usr/local/bin/reset_pod.sh
RUN chmod +x /usr/local/bin/reset_pod.sh

# Copy the servie restart commands
COPY systemctl /usr/local/bin/systemctl
RUN chmod +x /usr/local/bin/systemctl
COPY service /usr/local/bin/service
RUN chmod +x /usr/local/bin/service

# Copy the custom startup script
COPY run-services.sh /usr/local/bin/run-services.sh
RUN chmod +x /usr/local/bin/run-services.sh

# Expose SSH and all SSL ports
EXPOSE 22 7681 30444 30445 30446 30447 30448

# Set the entrypoint to our custom script
ENTRYPOINT ["/usr/local/bin/run-services.sh"]
 