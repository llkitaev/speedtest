FROM unit:1.33.0-php8.2

COPY backend/ /speedtest/backend

COPY results/*.php /speedtest/results/
COPY results/*.ttf /speedtest/results/
COPY *.js /speedtest/results/

COPY *.js /speedtest/
COPY *.ico /speedtest/
COPY docker/servers.json /servers.json

COPY docker/*.php /speedtest/
COPY docker/entrypoint.sh /

RUN mkdir -p /var/www/html/ && chmod +x /entrypoint.sh && \
    touch /var/log/access.log

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
