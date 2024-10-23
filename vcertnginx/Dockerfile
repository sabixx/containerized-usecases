# Use Alpine Linux as the base image
FROM alpine:latest

# Set environment variables for ports, hostname, and domain name
ENV START_PORT=30744
ENV PORT_COUNT=1
ENV HOSTNAME=myvcertapp
ENV DOMAIN_NAME=tlsp.demo
ENV PLAYBOOK_URL="https://raw.githubusercontent.com/sabixx/vcertplaybooks/refs/heads/main/TLSPC_US_POD_NGINX_Demo.yaml"
## ENV username=venafi
## ENV password=Insecure123!

# Install OpenSSH, Nginx, PHP 8.3, PHP-FPM, OpenSSL, and required PHP modules
RUN apk update && \
    apk add libc6-compat unzip curl coreutils nginx openssl php83 php83-fpm php83-openssl sudo ttyd && \
    rm -rf /var/cache/apk/*

## removed: openssh

# Install openrc and sudo
RUN apk add --no-cache openrc sudo

# Add command to display MOTD to the profile
COPY motd /etc/motd
RUN echo "[ -f /etc/motd ] && cat /etc/motd" >> /etc/profile

# Configure SSH
## RUN echo 'root:root' | chpasswd
## RUN ssh-keygen -A
## RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
##     sed -i 's/PasswordAuthentication no/#PasswordAuthentication no/' /etc/ssh/sshd_config

# Create a user and add them to the sudoers file
## RUN adduser -D $username && \
##    echo "$username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$username && \
##    chmod 0440 /etc/sudoers.d/$username && \
##    echo "$username:$password" | chpasswd

# Install and configure SSH
## RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
##    echo "AllowUsers ${username}" >> /etc/ssh/sshd_config   

# Update the CA certificates store so the system trusts the root certificate
RUN update-ca-certificates

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

COPY gettoken.sh /root
RUN chmod +x /root/gettoken.sh

# Copy the custom startup script
COPY run-services.sh /usr/local/bin/run-services.sh
RUN chmod +x /usr/local/bin/run-services.sh

# Expose SSH and all SSL ports
EXPOSE 30744 30745 30746 30747 30748 7681
## 22

# Set the entrypoint to our custom script
ENTRYPOINT ["/usr/local/bin/run-services.sh"]
