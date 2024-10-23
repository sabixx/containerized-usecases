# Base image for Jenkins (Debian-based)
FROM jenkins/jenkins:lts

# Switch to the root user to install dependencies
USER root

# Copy your certificates into the appropriate location
COPY ZTPKIEUDemoECCICA1 /usr/local/share/ca-certificates/ZTPKIEUDemoECCICA1.crt
COPY ZTPKIEUDemoRSAICA1 /usr/local/share/ca-certificates/ZTPKIEUDemoRSAICA1.crt

# Update the trusted certificates
RUN chmod 644 /usr/local/share/ca-certificates/ZTPKIEUDemoECCICA1.crt /usr/local/share/ca-certificates/ZTPKIEUDemoRSAICA1.crt && \
    update-ca-certificates

# Copy the Venafi Code Signing Client tar.gz file from the local directory into the image
COPY venafi-codesigningclients-24.3.0-linux-x86_64.tar.gz /tmp/venafi-client.tar.gz

# Extract the tar.gz file into the /opt/venafi-client directory
RUN mkdir -p /opt/venafi-client && \
    tar -xzf /tmp/venafi-client.tar.gz -C /opt/venafi-client && \
    rm /tmp/venafi-client.tar.gz

# Add the Venafi client to the PATH
ENV PATH="$PATH:/opt/venafi-client/bin"

# Set environment variable for JCasC configuration file path
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs/jenkins.yaml

# Copy Jenkins Configuration as Code (JCasC) YAML file
COPY jenkins.yaml /var/jenkins_home/casc_configs/jenkins.yaml

# Expose necessary ports for Jenkins
EXPOSE 8080
EXPOSE 50000

# Mark Jenkins as fully set up by disabling the setup wizard
RUN echo "2.0" > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
RUN echo "2.0" > /var/jenkins_home/jenkins.install.UpgradeWizard.state


# Jenkins will run as the Jenkins user
USER jenkins

# Start Jenkins
CMD ["/usr/local/bin/jenkins.sh"]
