#!/bin/bash

env_file=/scripts/custom_envs
#if someone decide to write "example.com, www.example.com"
echo export hostnames=$(echo $HOSTNAMES | sed "s/ //g") >> $env_file
echo export domain_cert_dir=$(echo $HOSTNAMES | cut -d"," -f1) >> $env_file
echo export certs_path=/etc/nginx/certificates >> $env_file
echo export certs_backup_dir=${certs_path}/backup/ >> $env_file
echo export cert_fullchain=${certs_path}/fullchain.pem >> $env_file
