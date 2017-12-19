FROM tiangolo/uwsgi-nginx-flask:python2.7

# Set correct environment variables.
ENV LOCALCATALOGURLBASE http://reposado:8080

ADD https://api.github.com/repos/wdas/reposado/git/refs/heads/master /tmp/reposado-version.json

RUN cd / && \
    git clone https://github.com/wdas/reposado.git /reposado && \
    rm -rf /app

COPY margarita /app
ADD preferences.plist /reposado/code/
ADD reposado.conf /etc/nginx/conf.d/reposado.conf
ADD uwsgi.ini /app/
ADD prestart.sh /app/

RUN ln -s /reposado/code/reposadolib /reposado/code/preferences.plist /app && \
    rm -f /tmp/*-version.json

VOLUME ["/reposado/html", "/reposado/metadata"]

EXPOSE 80 8080
