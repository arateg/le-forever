#!/bin/bash

SSL_CERT=/etc/nginx/certificates/fullchain.pem
SSL_KEY=/etc/nginx/certificates/privkey.pem
SSL_CHAIN_CERT=/etc/nginx/certificates/chain.pem

echo $(ls -la /etc/nginx/conf.d/)

# Replace SSL_* for path of files
sed -i "s~SSL_CERT~${SSL_CERT}~g" /etc/nginx/conf.d/*.conf
sed -i "s~SSL_KEY~${SSL_KEY}~g" /etc/nginx/conf.d/*.conf
sed -i "s~SSL_CHAIN_CERT~${SSL_CHAIN_CERT}~g" /etc/nginx/conf.d/*.conf

# Maybe if someone decide to write HOSTNAMES="example.com, www.example.com"
echo export hostnames=$(echo $HOSTNAMES | sed "s/ //g") >> ~/custom_envs
# name of first domain
echo export domain_cert_dir=$(echo $HOSTNAMES | cut -d"," -f1) >> ~/custom_envs
echo export cert_path=/etc/nginx/certificates/cert.pem >> ~/custom_envs

source ~/custom_envs

# If certificate exists, then chack domains
if [ -f $cert_path ]; then
    # Looking for domains regarding current certificate
    current_certs=$(openssl x509 -in ${cert_path} -text -noout | egrep -o 'DNS.*' | sed -e "s/DNS://g" | sed -e "s/,/ /g")
    # compare domains from cert.pem and ENV HOSTNAMES
    IFS=$',' # Delimeter
    sorted_currents_certs=($(sort <<<"${current_certs[*]}"))
    sorted_hostnames=($(sort <<<"${hostnames[*]}"))
    unset IFS
    certs_domains_diff=$(echo ${sorted_currents_certs[@]} ${sorted_hostnames[@]} | tr ' ' '\n' | sort | uniq -u)
    # IF new names then create new certificate, but make backup it at first. Later copy new cert to cert_dir
    if [-z "$certs_domains_diff"]; then
        # Directory could be named by another domain
        cp -fv /etc/letsencrypt/live/$domain_cert_dir . /etc/nginx/certificates/backup 2>/dev.null
        certbot certonly --email ${EMAIL} --renew-by-default --agree-tos --expand --non-interactive --webroot -w /usr/share/nginx/html -d $hostnames
        update_cert_result=$?
        cp -fv /etc/letsencrypt/live/$domain_cert_dir . $cert_path
    fi
fi

#If no cert.pem create certificate
if [ ! -f $cert_path ]; then
    certbot certonly --email ${EMAIL} --agree-tos --non-interactive --webroot -w /usr/share/nginx/html -d $hostnames
    update_cert_result
    cp -fv /etc/letsencrypt/live/$domain_cert_dir . $cert_path
fi

# cp twice. I thought to create COPY independent but  there is a possible
# situation when file exists, domains are the same but first domain name is different. So path to cert could differ


# Commented because last command became "copy" but was letsencrypt early
# le_result=$?
# if [ ${le_result} -ne 0 ]; then
#    echo "failed to run certbot"
#    return 1
# fi

#check 30 days before cron
/scripts/crons/cert_update.sh
# ========== Script for crontab for updating =======
# Run monthly
crontab /scripts/crons/cron_renew

return 0
