FROM nginx:stable-alpine

ENV HOSTNAMES=www.example.com \
    EMAIL=_@_._ \
    TIME_ZONE=Europe/Minsk


RUN  apk add --no-cache --update bash openssl tzdata && \
     mkdir -p mkdir /scripts /etc/nginx/conf.d /etc/nginx/certificates/backup && \
     echo "daemon off;" >> /etc/nginx/nginx.conf && \
     cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
     echo "${TIME_ZONE}" > /etc/timezone && \
     chmod +x /scripts/crons/cert_update.sh && \
     chmod +x /scripts/init.sh

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf/ \
     ./nginx/services/ /etc/nginx/conf.d/ \
     ./scripts/ /scripts/


ENTRYPOINT ["/opt/letsencrypt/init.sh"]
