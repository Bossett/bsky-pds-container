FROM ghcr.io/bluesky-social/pds:0.4 as pds
FROM node:20.11-bookworm as pdsadmin

COPY ./entrypoint.sh /entrypoint.sh

COPY --from=pds /app /app

# shim docker, systemctl & ufw so the installer proceeds without errors
RUN mkdir /setup && \
  echo "#!/bin/sh" > /setup/docker && \
  echo "exit 0" >> /setup/docker && \
  ln -s /setup/docker /setup/systemctl && \
  ln -s /setup/docker /setup/ufw && \
  chmod 777 /setup/*

RUN mkdir /etc/docker && \
  touch /etc/docker/daemon.json

# based on the output of apt-mark showmanual after installer ran
RUN apt-get update && apt-get install -y \
  autoconf automake bzip2 ca-certificates curl default-libmysqlclient-dev \
  dpkg-dev dumb-init file g++ gcc git gnupg imagemagick jq libbz2-dev \
  libc6-dev libcurl4-openssl-dev libdb-dev libevent-dev libffi-dev libgdbm-dev \
  libglib2.0-dev libgmp-dev libjpeg-dev libkrb5-dev liblzma-dev \
  libmagickcore-dev libmagickwand-dev libmaxminddb-dev libncurses5-dev \
  libncursesw5-dev libpng-dev libpq-dev libreadline-dev libsqlite3-dev \
  libssl-dev libtool libwebp-dev libxml2-dev libxslt1-dev libyaml-dev \
  lsb-release make mercurial musl netbase openssh-client openssl patch procps \
  sq sqlite3 subversion unzip wget xxd xz-utils zlib1g-dev && \
  apt-get clean all

# for litefs - some repetition in case the above changes
RUN apt-get update -y && apt-get install -y ca-certificates fuse3 sqlite3 \
  && apt-get clean all

COPY --from=flyio/litefs:0.5 /usr/local/bin/litefs /bin/litefs

RUN npm install -g pnpm
RUN cd /app && \
  pnpm install sharp better-sqlite3 && \
  pnpm rebuild sharp better-sqlite3

EXPOSE 3000
ENV PDS_PORT=3000
ENV NODE_ENV=production
# potential perf issues w/ io_uring on this version of node
ENV UV_USE_IO_URING=0

ENV PDS_DATA_DIRECTORY=/pds/data

ENTRYPOINT /entrypoint.sh