FROM nginx:stable-alpine

ENV HOSTNAMES=www.example.com \
    EMAIL=_@_._ \
    TIME_ZONE=Europe/Minsk

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf/ \
     ./nginx/services/ /etc/nginx/conf.d/ \
     ./scripts/ /opt/letsencrypt/


RUN  apk add --no-cache --update bash openssl tzdata && \
     mkdir -p mkdir /etc/nginx/conf.d /etc/nginx/certificates/backup && \
     echo "daemon off;" >> /etc/nginx/nginx.conf && \
     cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
     echo "${TIME_ZONE}" > /etc/timezone && \
     chmod +x /opt/letsencrypt/crons/cert_update.sh && \
     chmod +x /opt/letsencrypt/init.sh

ENTRYPOINT ["/opt/letsencrypt/init.sh"]
