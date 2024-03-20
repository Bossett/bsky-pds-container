#/bin/bash

COMMAND=""

if test -f "/pds/litefs.yml"; then
  rm -rf /etc/litefs.yml
  cp /pds/litefs.yml /etc/litefs.yml
  PDS_DATA_DIRECTORY=/pds/data-litefs

  mkdir -p $PDS_DATA_DIRECTORY
  mkdir -p $PDS_DATA_DIRECTORY-persist

  COMMAND="litefs run -- $COMMAND"
  litefs mount &
fi

if ! test -f "/pds/pds.env"; then
  mkdir -p $PDS_DATA_DIRECTORY
  mkdir -p $PDS_ACTOR_STORE_DIRECTORY
  mkdir -p $PDS_BLOBSTORE_DISK_LOCATION
  
  curl https://raw.githubusercontent.com/bluesky-social/pds/main/installer.sh > /installer.sh
  PATH=/setup:$PATH $COMMAND /bin/bash /installer.sh /pds $PDS_HOSTNAME $PDS_ADMIN_EMAIL
  cd /app

  cp /usr/local/bin/pdsadmin /pds/pdsadmin

  rm -rf /pds/caddy /pds/compose.yaml
fi

if test -f "/pds/pds.env"; then
  sed -i '/^PDS_DATA_DIRECTORY=/c\PDS_DATA_DIRECTORY=$PDS_DATA_DIRECTORY' /pds/pds.env
  set -a
  . /pds/pds.env
  set +a
       
  $COMMAND node --enable-source-maps /app/index.js
fi