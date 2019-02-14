#!/bin/bash

source ~/custom_envs

thirty_days=2592000

# Ends with status code 1 if it will expired or 0 if it will not
if openssl x509 -checkend $thirty_days -noout -in $cert_path; then
    # make backup, create new cert and copy to cert_path
    echo "UPDATING SSL CERTIFICATES"
    cp -fv /etc/letsencrypt/live/$domain_cert_dir/* $cert_backup_dir 2>/dev/null # Before first renew could be different path
    certbot certonly --email ${EMAIL} --agree-tos --renew-by-default --non-interactive --webroot -w /usr/share/nginx/html -d $hostnames
    # If update was good
    le_result=$?

    if [ ${le_result} -ne 0 ]; then
        echo "failed to run certbot"
        exit 1
    fi

    cp -fv /etc/letsencrypt/live/$domain_cert_dir/* $cert_path
    echo "Reloading NGINX"
    nginx -s reload
fi

exit 0

# BAD usage because server can have other certificates from other applications not related to this project
#certificates_data=$(/opt/letsencrypt/certbot-auto certificates)
#days_untile_expired=$(echo $certificates_data | grep -oP '(?<=VALID:\s)\w+')
# AND I GET HERE NUMBER 67 for example/ If something goes wrong(more then 1 certificate I will receive several numbers)
