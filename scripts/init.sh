#!/bin/bash

TZ=${TIME_ZONE:-Europe/Minsk}
cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
echo ${TZ} > /etc/timezone

/scripts/create_variables.sh

source ~/custom_envs

SSL_CERT=$cert_fullchain
SSL_KEY=${certs_path}/privkey.pem
SSL_CHAIN_CERT=${certs_path}/chain.pem

# Replace SSL_* for path of files
sed -i "s~SSL_CERT~${SSL_CERT}~g" /etc/nginx/conf.d/*.conf
sed -i "s~SSL_KEY~${SSL_KEY}~g" /etc/nginx/conf.d/*.conf
sed -i "s~SSL_CHAIN_CERT~${SSL_CHAIN_CERT}~g" /etc/nginx/conf.d/*.conf

crontab /scripts/crons/cron_renew

#If certificate exists, then chack domains
(if [ -f $cert_fullchain ]; then
    # Looking for domains regarding current certificate
    current_certs=$(openssl x509 -in $cert_fullchain -text -noout | egrep -o 'DNS.*' | sed -e "s/DNS://g" | sed -e "s/,/ /g")
    # compare domains from cert.pem and ENV HOSTNAMES
    IFS=$',' # Delimeter
    sorted_currents_certs=($(sort <<<"${current_certs[*]}"))
    sorted_hostnames=($(sort <<<"${hostnames[*]}"))
    unset IFS
    certs_domains_diff=$(echo ${sorted_currents_certs[@]} ${sorted_hostnames[@]} | tr ' ' '\n' | sort | uniq -u)
    # IF new names then create new certificate, but make backup it at first. Later copy new cert to cert_dir
    if [[ certs_domains_diff ]]; then
        # Directory could be named by another domain
        cp -fv /etc/letsencrypt/live/$domain_cert_dir/* $cert_backup_dir 2>/dev/null
        certbot certonly --email ${EMAIL} --renew-by-default --agree-tos --expand --non-interactive --webroot -w /usr/share/nginx/html -d $hostnames
        le_result=$?
        cp -fv /etc/letsencrypt/live/$domain_cert_dir/* ${certs_path}/
    fi
fi

#If no fullchain.pem create certificate
if [ ! -f $cert_fullchain ]; then
   certbot certonly --email ${EMAIL} --agree-tos --non-interactive --webroot -w /usr/share/nginx/html -d $hostnames
   le_result=$?
   cp -fv /etc/letsencrypt/live/$domain_cert_dir/* ${certs_path}/ 2>/dev/null
fi

#cp twice. I thought to create COPY independent but  there is a possible
#situation when file exists, domains are the same but first domain name is different. So path to cert could differ

if [[ -v le_result ]]; then
    if [ "$le_result" -ne 0 ]; then
        echo "failed to run certbot"
        exit 1
    fi
    nginx -s reload
fi

/scripts/crons/cert_update.sh

nginx -g "daemon off;"
