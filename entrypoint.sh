#! /usr/bin/env bash
set -e

/uwsgi-nginx-entrypoint.sh

# Get the URL for static files from the environment variable
USE_STATIC_URL=${STATIC_URL:-'/static'}
# Get the absolute path of the static files from the environment variable
USE_STATIC_PATH=${STATIC_PATH:-'/app/static'}
# Get the listen port for Nginx, default to 80
USE_LISTEN_PORT=${LISTEN_PORT:-80}

if [ -f /app/nginx.conf ]; then
    cp /app/nginx.conf /etc/nginx/nginx.conf
else
    content_server='server {\n'
    content_server=$content_server"    listen ${USE_LISTEN_PORT};\n"
    content_server=$content_server'    location / {\n'
    content_server=$content_server'        try_files $uri @app;\n'
    content_server=$content_server'    }\n'
    content_server=$content_server'    location @app {\n'
    content_server=$content_server'        include uwsgi_params;\n'
    content_server=$content_server'        uwsgi_pass unix:///tmp/uwsgi.sock;\n'
    content_server=$content_server'    }\n'
    content_server=$content_server"    location $USE_STATIC_URL {\n"
    content_server=$content_server"        alias $USE_STATIC_PATH;\n"
    content_server=$content_server'    }\n'
    # If STATIC_INDEX is 1, serve / with /static/index.html directly (or the static URL configured)
    if [ "$STATIC_INDEX" = 1 ] ; then
        content_server=$content_server'    location = / {\n'
        content_server=$content_server"        index $USE_STATIC_URL/index.html;\n"
        content_server=$content_server'    }\n'
    fi
    content_server=$content_server'}\n'
    # Save generated server /etc/nginx/conf.d/nginx.conf
    printf "$content_server" > /etc/nginx/conf.d/nginx.conf
fi

# our container specific additions to startup

# get env variables from linked container if there
if [[ ${REPOSADO_ENV_LOCALCATALOGURLBASE} ]]; then
  LOCALCATALOGURLBASE=${REPOSADO_ENV_LOCALCATALOGURLBASE}
fi
if [[ ${REPOSADO_ENV_MINOSVERSION} ]]; then
  MINOSVERSION=${REPOSADO_ENV_MINOSVERSION}
fi
if [[ ${REPOSADO_ENV_HUMANREADABLESIZES} ]]; then
  HUMANREADABLESIZES=${REPOSADO_ENV_HUMANREADABLESIZES}
fi
if [[ ${REPOSADO_ENV_ONLYHOSTDEPRECATED} ]]; then
  ONLYHOSTDEPRECATED=${REPOSADO_ENV_ONLYHOSTDEPRECATED}
fi
if [[ ${REPOSADO_ENV_ALWAYSREWRITEDISTRIBUTIONURLS} ]]; then
  ALWAYSREWRITEDISTRIBUTIONURLS=${REPOSADO_ENV_ALWAYSREWRITEDISTRIBUTIONURLS}
fi

# set up nginx for margarita
sed -i "s|REPOSADO_PORT|${PORT}|g" /etc/nginx/conf.d/reposado.conf

# set up reposado prefs
echo "Setting LocalCatalogURLBase to $LOCALCATALOGURLBASE"
sed -i "s|REPLACEME|$LOCALCATALOGURLBASE|g" /reposado/code/preferences.plist

if [[ ${MINOSVERSION} ]]; then
  echo "Setting AppleCatalogURLs to 10.$MINOSVERSION.X as minimum"

  catalogs="<key>AppleCatalogURLs</key>\n<array>"
  if [[ ${MINOSVERSION} -le 6 ]]; then
    catalogs="${catalogs}\n  <string>http://swscan.apple.com/content/catalogs/index.sucatalog</string>\n  <string>http://swscan.apple.com/content/catalogs/index-1.sucatalog</string>\n  <string>http://swscan.apple.com/content/catalogs/others/index-leopard.merged-1.sucatalog</string>\n  <string>http://swscan.apple.com/content/catalogs/others/index-leopard-snowleopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 7 ]]; then
    catalogs="${catalogs}\n  <string>http://swscan.apple.com/content/catalogs/others/index-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 8 ]]; then
    catalogs="${catalogs}\n  <string>http://swscan.apple.com/content/catalogs/others/index-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 9 ]]; then
    catalogs="${catalogs}\n  <string>http://swscan.apple.com/content/catalogs/others/index-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 10 ]]; then
    catalogs="${catalogs}\n  <string>http://swscan.apple.com/content/catalogs/others/index-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 11 ]]; then
    catalogs="${catalogs}\n  <string>http://swscan.apple.com/content/catalogs/others/index-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 12 ]]; then
    catalogs="${catalogs}\n  <string>http://swscan.apple.com/content/catalogs/others/index-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 14 ]]; then
    catalogs="${catalogs}\n  <string>https://swscan.apple.com/content/catalogs/others/index-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 13 ]]; then
    catalogs="${catalogs}\n  <string>http://swscan.apple.com/content/catalogs/others/index-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  catalogs="${catalogs}\n</array>"

  sed -i "s|REPLACECATALOGS|$catalogs|g" /reposado/code/preferences.plist
else
  sed -i "s|REPLACECATALOGS||g" /reposado/code/preferences.plist
fi

extra_key=""
if [[ ${HUMANREADABLESIZES} ]]; then
  echo "Setting HumanReadableSizes key to ${HUMANREADABLESIZES}"
  extra_key="<key>HumanReadableSizes</key>\n<${HUMANREADABLESIZES}/>\n"
fi

if [[ ${ONLYHOSTDEPRECATED} ]]; then
  echo "Setting OnlyRewriteDeprecatedURLs key to ${ONLYHOSTDEPRECATED}"
  extra_key="${extra_key}<key>OnlyRewriteDeprecatedURLs</key>\n<${ONLYHOSTDEPRECATED}/>\n"
fi

if [[ ${ALWAYSREWRITEDISTRIBUTIONURLS} ]]; then
  echo "Setting AlwaysRewriteDistributionURLs key to ${ALWAYSREWRITEDISTRIBUTIONURLS}"
  extra_key="${extra_key}<key>AlwaysRewriteDistributionURLs</key>\n<${ALWAYSREWRITEDISTRIBUTIONURLS}/>"
fi
sed -i "s|REPLACEEXTRAKEYS|$extra_key|g" /reposado/code/preferences.plist

# set up basic auth for magarita
if [[ ${USERNAME} && ${PASSWORD} ]]; then
  echo "Setting Margarita username/password"

  sed -i "s|'admin'|'$USERNAME'|g" /app/margarita.py
  sed -i "s|'password'|'$PASSWORD'|g" /app/margarita.py
fi

# execute what was passed on commandline
exec "$@"
