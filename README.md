# containerized-usecases

## Push Provisioning

### Apache 
Webserver for push provisioning with self-signed certs, the certificates are created at runtime and will soon expire.

**Configurable items:**
- `ENV START_PORT=30444`: Start port, will define the first port that a webpage will be listening on.
- `ENV PORT_COUNT=5`: The number of webpages hosted following +1 from the start port.
- `ENV DOMAIN_NAME=tlsp.demo`: Domain name, used in the certificate.
- `ENV HOSTNAME=myhaproxy.`: Name of the app, used in the certificate.
- `ENV username=venafi`: SSH credentials for push provisioning.
- `ENV password=ChangeMe123!`: SSH credentials for push provisioning.

### Nginx
Webserver for push provisioning with self-signed certs, the certificates are created at runtime and will soon expire.

**Configurable items:**
- `ENV START_PORT=30544`: Start port, will define the first port that a webpage will be listening on.
- `ENV PORT_COUNT=5`: The number of webpages hosted following +1 from the start port.
- `ENV DOMAIN_NAME=tlsp.demo`: Domain name, used in the certificate.
- `ENV HOSTNAME=myhaproxy.`: Name of the app, used in the certificate.
- `ENV username=venafi`: SSH credentials for push provisioning.
- `ENV password=ChangeMe123!`: SSH credentials for push provisioning.

### HAProxy
Load balancer for push provisioning with self-signed certs. There's a Nginx running as a backend service, and all VIPs point to the same Nginx. The certificates are created at runtime and will soon expire.

**Configurable items:**
- `ENV START_PORT=30643`: Start port, will define the first port that a webpage will be listening on.
- `ENV PORT_COUNT=5`: The number of webpages hosted following +1 from the start port.
- `ENV DOMAIN_NAME=tlsp.demo`: Domain name, used in the certificate.
- `ENV HOSTNAME=myhaproxy.`: Name of the app, used in the certificate.
- `ENV username=venafi`: SSH credentials for push provisioning.
- `ENV password=ChangeMe123!`: SSH credentials for push provisioning.

## Pull Provisioning

### VCert with Nginx
Environment with VCert and Nginx, the certificate is created at runtime and will soon expire. Downloads a playbook at startup.

**Configurable items:**
- `ENV START_PORT=30744`: Port the app is listening on.
- `ENV PORT_COUNT=1`: Number of webpages, this demo is only using one.
- `ENV HOSTNAME=myvcertapp`: Name of the app, used in the certificate.
- `ENV DOMAIN_NAME=tlsp.demo`: Domain name, used in the certificate.
- `ENV PLAYBOOK_URL="https..."`: Playbook URL to be downloaded.
- `TLSPC_APIKEY`: TLS PS API key (inject via secret, not via config map).
