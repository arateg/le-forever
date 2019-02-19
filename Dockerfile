FROM nginx:stable-alpine

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

RUN  apk add --no-cache --update bash certbot openssl tzdata && \
     mkdir -p /scripts /etc/nginx/certificates/backup /etc/nginx/moved && \
     rm /etc/nginx/conf.d/default.conf

COPY ./scripts/ /scripts/

RUN  chmod +x /scripts/crons/cert_update.sh \
              /scripts/init.sh \
              /scripts/create_variables.sh \
              /sripts/create_certs.sh

CMD ["/scripts/init.sh"]
