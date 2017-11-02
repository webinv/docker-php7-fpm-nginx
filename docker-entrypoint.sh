#!/bin/bash
set -e

# NewRelic
sed -i \
        -e "s/;\?newrelic.enabled =.*/newrelic.enabled = ${NEWRELIC_ENABLED}/" \
        -e "s/newrelic.license =.*/newrelic.license = \"${NEWRELIC_LICENSE}\"/" \
        -e "s/newrelic.appname =.*/newrelic.appname = \"${NEWRELIC_APPNAME}\"/" \
        /usr/local/etc/php/conf.d/newrelic.ini

# BasicAuth
echo '' > /etc/nginx/basic_auth.conf
if [ -n "$BASIC_AUTH" ]; then
    echo 'auth_basic "Restricted";' > /etc/nginx/basic_auth.conf
    echo 'auth_basic_user_file /etc/nginx/.htpasswd;' >> /etc/nginx/basic_auth.conf
    echo "$BASIC_AUTH" > /etc/nginx/.htpasswd
    chmod 644 /etc/nginx/.htpasswd
fi

exec "$@"