#/bin/bash

COMMAND=""

process_sqlite_files() {
  while true; do
    sleep 300
    find "$PDS_ACTOR_STORE_DIRECTORY" -type f -name "*.sqlite" | while read original_path; do
      processed_path=$(echo $original_path | sed "s|$PDS_ACTOR_STORE_DIRECTORY/||; s|/|_|g; s|:|_|g")
      full_new_path=$PDS_DATA_DIRECTORY/$processed_path
      if [ -L "$original_path" ]; then
        continue
      fi
      litefs import -name $processed_path $original_path
      if [ $? -eq 0 ]; then
        [ ! -L "$original_path" ] && rm $original_path
        ln -s $full_new_path $original_path
      fi
    done
  done
}

if test -f "/pds/litefs.yml"; then
  rm -rf /etc/litefs.yml
  cp /pds/litefs.yml /etc/litefs.yml
  PDS_DATA_DIRECTORY=/pds/data-litefs

  mkdir -p $PDS_DATA_DIRECTORY
  mkdir -p $PDS_DATA_DIRECTORY-persist

  COMMAND="litefs run -- $COMMAND"
  litefs mount &
  process_sqlite_files &
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
  
  [ -n "$COMMAND" ] && sleep 20

  $COMMAND node --enable-source-maps /app/index.js
fi