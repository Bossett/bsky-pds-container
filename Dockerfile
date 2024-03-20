FROM ghcr.io/bluesky-social/pds:0.4 as pds
FROM node:20.11-bookworm as pdsadmin

COPY ./entrypoint.sh /entrypoint.sh

COPY --from=pds /app /app

RUN mkdir /setup

# shim docker, systemctl & ufw so the installer proceeds without errors
RUN echo "#!/bin/sh" > /setup/docker && \
  echo "exit 0" >> /setup/docker && \
  ln -s /setup/docker /setup/systemctl && \
  ln -s /setup/docker /setup/ufw && \
  chmod 777 /setup/*

RUN mkdir /etc/docker && \
  touch /etc/docker/daemon.json

RUN apt-get update && apt-get install -y lsb-release curl dumb-init musl && apt-get clean all
RUN npm install -g pnpm

EXPOSE 3000
ENV PDS_PORT=3000
ENV NODE_ENV=production
# potential perf issues w/ io_uring on this version of node
ENV UV_USE_IO_URING=0

ENTRYPOINT /entrypoint.sh