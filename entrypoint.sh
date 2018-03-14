#!/bin/bash
set -e

# Get the maximum upload file size for Nginx, default to 0: unlimited
USE_NGINX_MAX_UPLOAD=${NGINX_MAX_UPLOAD:-0}
# Generate Nginx config for maximum upload file size
echo "client_max_body_size $USE_NGINX_MAX_UPLOAD;" > /etc/nginx/conf.d/upload.conf

# Get the listen port for Nginx, default to 80
USE_LISTEN_PORT=${LISTEN_PORT:-80}
# Modify Nignx config for listen port
if ! grep -q "listen ${USE_LISTEN_PORT};" /etc/nginx/conf.d/nginx.conf ; then
    sed -i -e "/server {/a\    listen ${USE_LISTEN_PORT};" /etc/nginx/conf.d/nginx.conf
fi

# our container specific additions to startup

# get env variables from linked container if there
if [[ ${REPOSADO_ENV_LOCALCATALOGURLBASE} ]]; then
  LOCALCATALOGURLBASE=${REPOSADO_ENV_LOCALCATALOGURLBASE}
fi
if [[ ${REPOSADO_ENV_MINOSVERSION} ]]; then
  MINOSVERSION=${REPOSADO_ENV_MINOSVERSION}
fi

# set up nginx for margarita
sed -i "s|REPOSADO_PORT|${PORT}|g" /etc/nginx/conf.d/reposado.conf

# set up reposado prefs
echo "Setting LocalCatalogURLBase to $LOCALCATALOGURLBASE"
sed -i "s|REPLACEME|$LOCALCATALOGURLBASE|g" /reposado/code/preferences.plist

if [[ ${MINOSVERSION} || ${REPOSADO_ENV_MINOSVERSION} ]]; then
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
  if [[ ${MINOSVERSION} -le 13 ]]; then
    catalogs="${catalogs}\n  <string>http://swscan.apple.com/content/catalogs/others/index-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  catalogs="${catalogs}\n</array>"

  sed -i "s|REPLACECATALOGS|$catalogs|g" /reposado/code/preferences.plist
else
  sed -i "s|REPLACECATALOGS||g" /reposado/code/preferences.plist
fi

# execute what was passed on commandline
exec "$@"
