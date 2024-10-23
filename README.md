# containerized-usecases

## Push Provissioning
### apache 
webserver for push provissioning with self signed certs, the certificates are created at runtime and will soon expire.<br>
  configurable items:<br>
    ENV START_PORT=30444          start port, will define the first port that a webpage will be listening on<br>
    ENV PORT_COUNT=5              the number of webpages hosted following +1 from the start port<br>
    ENV DOMAIN_NAME=tlsp.demo     domain name, used in the certificate<br>
    ENV HOSTNAME=myhaproxy.       name of the app, used in the certificate<br>
    ENV username=venafi           SSH credentials for push provisioning<br>
    ENV password=ChangeMe123!     SSH credentials for push provisioning<br>

### nginx
webserver for push provissioning with self signed certs, the certificates are created at runtime and will soon expire.<br>
  configurable items:<br>
    ENV START_PORT=30544          start port, will define the first port that a webpage will be listening on<br>
    ENV PORT_COUNT=5              the number of webpages hosted following +1 from the start port<br>
    ENV DOMAIN_NAME=tlsp.demo     domain name, used in the certificate<br>
    ENV HOSTNAME=myhaproxy.       name of the app, used in the certificate<br>
    ENV username=venafi           SSH credentials for push provisioning<br>
    ENV password=ChangeMe123!     SSH credentials for push provisioning<br>

### haproxy
load balancer for push provissioning with self signed certs. There's a nginx running as a backend service running all VIPs point to the same nginx, the certificates are created at runtime and will soon expire.<br>
  configurable items:<br>   
    ENV START_PORT=30643          start port, will define the first port that a webpage will be listening on<br>
    ENV PORT_COUNT=5              the number of webpages hosted following +1 from the start port<br>
    ENV DOMAIN_NAME=tlsp.demo     domain name, used in the certificate<br>
    ENV HOSTNAME=myhaproxy.       name of the app, used in the certificate<br>
    ENV username=venafi           SSH credentials for push provisioning<br>
    ENV password=ChangeMe123!     SSH credentials for push provisioning<br>

## Pull Provssioning
### vcert with nginx
environment with vcert and nginx, the certificate is created at runtime and will soon expire. Downloads a playbook at startup<br>
  configurable items:<br>
    ENV START_PORT=30744          port the app is listening on<br>
    ENV PORT_COUNT=1              number of webpages, this demo is only using one.<br>
    ENV HOSTNAME=myvcertapp       name of the app, used in the certificate<br>
    ENV DOMAIN_NAME=tlsp.demo     domain name, used in the certificate<br>
    ENV PLAYBOOK_URL="https..."   playbook URL to be downloaded<br>
    TLSPC_APIKEY                  TLS PS API key (inject via secret, not via config map)<br>

