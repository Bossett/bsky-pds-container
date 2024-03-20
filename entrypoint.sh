#/bin/bash

if ! test -f "/pds/pds.env"; then
  curl https://raw.githubusercontent.com/bluesky-social/pds/main/installer.sh > /installer.sh
  PATH=/setup:$PATH /bin/bash /installer.sh /pds $PDS_HOSTNAME $PDS_ADMIN_EMAIL
  cd /app

  rm -rf /pds/caddy /pds/compose.yaml

fi

if test -f "/pds/pds.env"; then
  set -a
  . /pds/pds.env
  set +a
       
  node --enable-source-maps /app/index.js
fi