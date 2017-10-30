#!/bin/bash
set -e

sed -i \
        -e "s/;\?newrelic.enabled =.*/newrelic.enabled = ${NEWRELIC_ENABLED}/" \
        -e "s/newrelic.license =.*/newrelic.license = \"${NEWRELIC_LICENSE}\"/" \
        -e "s/newrelic.appname =.*/newrelic.appname = \"${NEWRELIC_APPNAME}\"/" \
        /usr/local/etc/php/conf.d/newrelic.ini

exec "$@"