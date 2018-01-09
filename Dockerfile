FROM tiangolo/uwsgi-nginx-flask:python2.7

# Set correct environment variables.
ENV LOCALCATALOGURLBASE http://reposado:8080
ENV PORT 8080
ENV LISTEN_PORT 8089

COPY reposado /reposado
RUN rm -rf /app
COPY margarita /app
ADD preferences.plist /reposado/code/
ADD reposado.conf /etc/nginx/conf.d/reposado.conf
ADD uwsgi.ini /app/
ADD entrypoint.sh /

RUN ln -s /reposado/code/reposadolib /reposado/code/preferences.plist /app && \
    chmod +x /entrypoint.sh

VOLUME ["/reposado/html", "/reposado/metadata"]

EXPOSE 8080 8089
