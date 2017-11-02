#!/bin/bash
set -e

# BasicAuth
echo '' > /etc/nginx/basic_auth.conf
if [ -n "$BASIC_AUTH" ]; then
    echo 'auth_basic "Restricted";' > /etc/nginx/basic_auth.conf
    echo 'auth_basic_user_file /etc/nginx/.htpasswd;' >> /etc/nginx/basic_auth.conf
    echo "$BASIC_AUTH" > /etc/nginx/.htpasswd
    chmod 644 /etc/nginx/.htpasswd
fi

exec "$@"