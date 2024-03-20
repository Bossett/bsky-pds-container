#/bin/bash

COMMAND=""

if test -f "/pds/litefs.yml"; then
  rm -rf /etc/litefs.yml
  cp /pds/litefs.yml /etc/litefs.yml
  PDS_DATA_DIRECTORY=/litefs
  COMMAND="litefs run -- $COMMAND"
  litefs mount &
fi

if ! test -f "/pds/pds.env"; then
  mkdir -p $PDS_DATA_DIRECTORY
  curl https://raw.githubusercontent.com/bluesky-social/pds/main/installer.sh > /installer.sh
  PATH=/setup:$PATH $COMMAND /bin/bash /installer.sh /pds $PDS_HOSTNAME $PDS_ADMIN_EMAIL
  cd /app

  rm -rf /pds/caddy /pds/compose.yaml

  sed -i '/^PDS_DATA_DIRECTORY=/c\PDS_DATA_DIRECTORY=$PDS_DATA_DIRECTORY' /pds/pds.env

fi



if test -f "/pds/pds.env"; then
  set -a
  . /pds/pds.env
  set +a
       
  $COMMAND node --enable-source-maps /app/index.js
fi