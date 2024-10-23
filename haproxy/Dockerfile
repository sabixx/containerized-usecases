# Use Alpine Linux as the base image
FROM alpine:latest

ENV PORT_COUNT=5
ENV START_PORT=30643
ENV DOMAIN_NAME=tlsp.demo
ENV HOSTNAME=myhaproxy
ENV username=venafi
ENV password=Insecure123!

# Install necessary packages: HAProxy, OpenSSL, OpenSSH, Nginx, PHP
RUN apk add --no-cache openssl coreutils haproxy openssh nginx php83 php83-fpm php83-openssl sudo ttyd && \
rm -rf /var/cache/apk/*
#RUN apk add --no-cache openssl haproxy openssh nginx sudo

# Copy the PHP file into the container's web root directory
COPY index.php /var/www/html/
COPY Venafi_CYBR_logo_R.svg /var/www/html/

# copy the reset command
COPY reset_pod.sh /usr/local/bin/reset_pod.sh
RUN chmod +x /usr/local/bin/reset_pod.sh

# Copy the servie restart commands
COPY systemctl /usr/local/bin/systemctl
RUN chmod +x /usr/local/bin/systemctl
COPY service /usr/local/bin/service
RUN chmod +x /usr/local/bin/service

# Copy the run-services.sh startup script into the container
COPY run-services.sh /usr/local/bin/run-services.sh

# Copy the PHP page into the web server directory
COPY index.php /var/www/html/index.php
#COPY certificate_info_pretty.php /var/www/html/certificate_info_pretty.php

# Configure Nginx
COPY default.conf /etc/nginx/http.d/default.conf

# Add command to display MOTD to the profile
COPY motd /etc/motd
RUN echo "[ -f /etc/motd ] && cat /etc/motd" >> /etc/profile


# Configure SSH
RUN echo 'root:root' | chpasswd
RUN ssh-keygen -A
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/#PasswordAuthentication no/' /etc/ssh/sshd_config

# Create sudoers directory and a user, then add the user to the sudoers file
RUN mkdir -p /etc/sudoers.d && \
    adduser -D $username && \
    echo "$username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$username && \
    chmod 0440 /etc/sudoers.d/$username && \
    echo "$username:$password" | chpasswd

# Install and configure SSH
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "AllowUsers ${username}" >> /etc/ssh/sshd_config

# remove the default index.html
# RUN rm /var/www/localhost/htdocs/index.html
RUN echo "extension=openssl" >> /etc/php83/php.ini

# Make sure the script is executable
RUN chmod +x /usr/local/bin/run-services.sh

# Expose port 443 for HTTPS traffic, 80 for HTTP traffic, and 22 for SSH
EXPOSE 22 80 443 444 445 446 447 448 7681


# Define the entrypoint script
ENTRYPOINT ["sh", "/usr/local/bin/run-services.sh"]


