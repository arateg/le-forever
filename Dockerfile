FROM nginx:stable-alpine
    
COPY nginx/nginx.conf /etc/nginx/nginx.conf

RUN  apk add --no-cache --update bash certbot openssl tzdata && \
     mkdir -p /scripts \
              /etc/nginx/certificates/backup \
              /etc/nginx/outside \
              /etc/nginx/conf.d && \
     rm /etc/nginx/conf.d/default.conf

COPY /scripts/ /scripts/

RUN  chmod +x /scripts/init.sh \
              /scripts/create_variables.sh \
              /scripts/create_certs.sh

ENTRYPOINT ["/scripts/init.sh"]
