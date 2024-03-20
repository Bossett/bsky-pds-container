# Bluesky PDS Dockerfile

A single Dockerfile that stands up an atproto PDS without requiring any additional work on the host (i.e. this should launch with just `docker compose up --build`).

You will need to update docker-compose.yml to accurately reflect your info, and make sure the volume/bind mount is correct.

Once it is running `docker compose exec pds pdsadmin` to create your users.