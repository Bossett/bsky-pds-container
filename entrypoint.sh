#/bin/bash

if ! test -f "/pds/pds.env"; then
  curl https://raw.githubusercontent.com/bluesky-social/pds/main/installer.sh > /installer.sh
  PATH=/setup:$PATH /bin/bash /installer.sh /pds $PDS_HOSTNAME $PDS_ADMIN_EMAIL
  cd /app

  rm -rf /etc/docker /setup/* /pds/caddy /pds/compose.yaml
  apt-mark showmanual > /setup/packages.txt

fi

if ! test -f /setup/setup_complete; then
  apt-get update && apt-get install -y $(cat /setup/packages.txt) && apt-get clean all
  
  pnpm install sharp better-sqlite3
  pnpm rebuild sharp better-sqlite3

  touch /setup/setup_complete
  rm /setup/packages.txt
fi

if test -f "/pds/pds.env"; then
  set -a
  . /pds/pds.env
  set +a
       
  node --enable-source-maps /app/index.js
fi