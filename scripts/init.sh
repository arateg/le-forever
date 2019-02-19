#!/bin/bash

TZ=${TIME_ZONE:-Europe/Minsk}
cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
echo ${TZ} > /etc/timezone

/scripts/create_variables.sh
source /scripts/custom_envs

SSL_CERT=$cert_fullchain
SSL_KEY=${certs_path}/privkey.pem
SSL_CHAIN_CERT=${certs_path}/chain.pem

# Replace SSL_* for path of files
sed -i "s~SSL_CERT~${SSL_CERT}~g" /etc/nginx/conf.d/*.conf
sed -i "s~SSL_KEY~${SSL_KEY}~g" /etc/nginx/conf.d/*.conf
sed -i "s~SSL_CHAIN_CERT~${SSL_CHAIN_CERT}~g" /etc/nginx/conf.d/*.conf

# Move configs for starting nginx without path to ssl certs which could be not exists
mv -v /etc/nginx/conf.d /etc/nginx/moved

nginx -g "daemon off;"
sleep(3)
# 
mv -v /etc/nginx/moved /etc/nginx/conf.d
/scripts/create_certs.sh

crontab /scripts/crons/cron_renew

nginx -s reload
