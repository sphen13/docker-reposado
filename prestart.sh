#!/bin/bash
# our container specific additions to startup

echo "Setting LocalCatalogURLBase to $LOCALCATALOGURLBASE"
sed -i "s|REPLACEME|$LOCALCATALOGURLBASE|g" /reposado/code/preferences.plist

if [[ ${MINOSVERSION} ]]; then
  echo "Setting AppleCatalogURLs to 10.$MINOSVERSION.X as minimum"

  catalogs="<key>AppleCatalogURLs</key>\n<array>"
  if [[ ${MINOSVERSION} -le 6 ]]; then
    catalogs="${catalogs}\n  <string>http://swscan.apple.com/content/catalogs/index.sucatalog</string>\n  <string>http://swscan.apple.com/content/catalogs/index-1.sucatalog</string>\n  <string>http://swscan.apple.com/content/catalogs/others/index-leopard.merged-1.sucatalog</string>\n  <string>http://swscan.apple.com/content/catalogs/others/index-leopard-snowleopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 7 ]]; then
    catalogs="${catalogs}\n  <string>index-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 8 ]]; then
    catalogs="${catalogs}\n  <string>index-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 9 ]]; then
    catalogs="${catalogs}\n  <string>index-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 10 ]]; then
    catalogs="${catalogs}\n  <string>index-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 11 ]]; then
    catalogs="${catalogs}\n  <string>index-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 12 ]]; then
    catalogs="${catalogs}\n  <string>index-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  if [[ ${MINOSVERSION} -le 13 ]]; then
    catalogs="${catalogs}\n  <string>index-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog</string>"
  fi
  catalogs="${catalogs}\n</array>"

  sed -i "s|REPLACECATALOGS|$catalogs|g" /reposado/code/preferences.plist
fi

if [[ ${USERNAME} && ${PASSWORD} ]]; then
  echo "Setting Margarita username/password"

  sed -i "s|'admin'|'$USERNAME'|g" /app/margarita.py
  sed -i "s|'password'|'$PASSWORD'|g" /app/margarita.py
fi
