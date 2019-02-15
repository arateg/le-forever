#!/bin/bash

#if someone decide to write "example.com, www.example.com"
echo export hostnames=$(echo $HOSTNAMES | sed "s/ //g") >> ~/custom_envs
echo export domain_cert_dir=$(echo $HOSTNAMES | cut -d"," -f1) >> ~/custom_envs
echo export certs_path=/etc/nginx/certificates >> ~/custom_envs
echo export cert_backup_dir=/etc/nginx/certificates/backup/ >> ~/custom_envs
echo export cert_fullchain=/etc/nginx/certificates/fullchain.pem >> ~/custom_envs
