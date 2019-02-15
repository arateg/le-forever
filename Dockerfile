FROM nginx:stable-alpine

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

RUN  apk add --no-cache --update bash certbot openssl tzdata && \
     mkdir -p mkdir /scripts /etc/nginx/certificates/backup && \
     rm /etc/nginx/conf.d/default.conf

COPY ./scripts/ /scripts/

RUN  chmod +x /scripts/crons/cert_update.sh \
              /scripts/init.sh \
              /scripts/create_variables.sh

CMD ["/scripts/init.sh"]
