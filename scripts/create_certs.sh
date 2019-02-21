#!/bin/bash

source /scripts/custom_envs

command="certbot certonly --email ${EMAIL} --renew-by-default --agree-tos --non-interactive --webroot -w /usr/share/nginx/html -d $hostnames"
thirty_days=2592000
new_domains=false

if [ -f $cert_fullchain ]; then
    echo "Fullchain.pem exists"
    # Looking for domains regarding current certificate
    current_certs=$(openssl x509 -in $cert_fullchain -text -noout | egrep -o 'DNS.*' | sed -e "s/DNS://g" | sed -e "s/,/ /g")
    # compare domains from cert.pem and ENV HOSTNAMES
    IFS=$',' # Delimeter
    sorted_currents_certs=($(sort <<<"${current_certs[*]}"))
    sorted_hostnames=($(sort <<<"${hostnames[*]}"))
    unset IFS
    certs_domains_diff=$(echo ${sorted_currents_certs[@]} ${sorted_hostnames[@]} | tr ' ' '\n' | sort | uniq -u)
    # IF new names then create new certificate, but make backup it at first. Later copy new cert to cert_dir
    if [ ! -z "$certs_domains_diff" ]; then
        # Directory could be named by another domain
        echo "Domain defference: $certs_domains_diff"
        command="${command} --expand"
        new_domains=true
    fi
fi

if [ ! -f $cert_fullchain ] || [ "$new_domains" = true ] || ! openssl x509 -checkend $thirty_days -noout -in $cert_fullchain ; then
   echo "Creating Certificate"
   cp -fv /etc/letsencrypt/live/$domain_cert_dir/* $certs_backup_dir 2>/dev/null # Before first renew could be different path
   
   $command
   
   le_result=$?
   if [ ${le_result} -ne 0 ]; then
        echo "failed to run certbot"
        exit 1
    fi
   cp -fv /etc/letsencrypt/live/$domain_cert_dir/* ${certs_path}/ 2>/dev/null

   echo "Reloading NGINX"
   nginx -s reload
fi
