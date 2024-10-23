#!/bin/sh

# Set environment variables
TLSPC_OAuthIdpURL="https://dev-opv4np2n306var5k.us.auth0.com/oauth/token"
TokenURL="https://api.venafi.cloud/v1/oauth2/v2.0/0ce51ed1-da6f-11ec-a787-89187550eb51/token"
TLSPC_ClientID="ZwkLAcWEE2gwz7ntpmlD76gQFhHXNVPP"
TLSPC_SyslogServer="k8cluster.tlsp.demo"
TLSPC_SyslogPort=30514

# Create JSON payload
jsonPayload=$(cat <<EOF
{
    "client_id": "$TLSPC_ClientID",
    "client_secret": "$TLSPC_ClientSecret",
    "audience": "https://api.venafi.cloud/",
    "grant_type": "client_credentials"
}
EOF
)

# Try to obtain JWT
response=$(curl -s -X POST -H "Content-Type: application/json" \
  -d "$jsonPayload" "$TLSPC_OAuthIdpURL")

# Check if the response contains an access token
access_token=$(echo "$response" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$access_token" ]; then
    echo "ERROR: Could not obtain external JWT"
    
    # Send syslog message to the specified syslog server and port in case of failure
    message="ERROR: Could not obtain external JWT"
    echo "<14>$message" | nc -w 1 $TLSPC_SyslogServer $TLSPC_SyslogPort
    
    exit 1
else
    # Export JWT and TokenURL to environment variables
    export ExternalJWT="$access_token"
    export TokenURL="$TokenURL"
    echo "DEBUG: ExternalJWT and TokenURL retrieved successfully and set to environment."
fi
