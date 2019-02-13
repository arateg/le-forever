FROM nginx:stable-alpine

ARG TIME_ZONE
ENV TZ=${TIME_ZONE}

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/services/ /etc/nginx/conf.d/

RUN  apk add --no-cache --update bash certbot openssl tzdata && \
     mkdir -p mkdir /scripts /etc/nginx/certificates/backup && \
     rm /etc/nginx/conf.d/default.conf && \
     echo "daemon off;" >> /etc/nginx/nginx.conf


RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" >> /etc/timezone

COPY ./scripts/ /scripts/

RUN  chmod +x /scripts/crons/cert_update.sh && \
     chmod +x /scripts/init.sh

ENTRYPOINT ["/scripts/init.sh"]
