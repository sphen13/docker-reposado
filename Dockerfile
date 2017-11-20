FROM tiangolo/uwsgi-nginx-flask:flask

# Set correct environment variables.
ENV LOCALCATALOGURLBASE http://reposado

RUN git clone https://github.com/wdas/reposado.git /reposado
ADD preferences.plist /reposado/code/
ADD reposado.conf /etc/nginx/conf.d/reposado.conf
RUN rm -rf /app
RUN git clone https://github.com/jessepeterson/margarita.git /app
ADD uwsgi.ini /app/
RUN ln -s /reposado/code/reposadolib /app
RUN ln -s /reposado/code/preferences.plist /app

VOLUME /reposado/html
VOLUME /reposado/metadata
EXPOSE 80 8088
