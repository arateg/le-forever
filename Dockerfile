FROM nginx:stable-alpine

ENV HOSTNAMES=example.com,www.example.com \
    EMAIL=_@_._ \
    TIME_ZONE=Europe/Minsk

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/services/ /etc/nginx/conf.d/

RUN  apk add --no-cache --update bash certbot openssl tzdata && \
     mkdir -p mkdir /scripts /etc/nginx/certificates/backup && \
     echo "daemon off;" >> /etc/nginx/nginx.conf && \
     cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
     echo "${TIME_ZONE}" > /etc/timezone

COPY ./scripts/ /scripts/

RUN  chmod +x /scripts/crons/cert_update.sh && \
     chmod +x /scripts/init.sh

ENTRYPOINT ["/scripts/init.sh"]
