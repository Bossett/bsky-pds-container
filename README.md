# Bluesky PDS Dockerfile

A single Dockerfile that stands up an atproto PDS without requiring any additional work on the host (i.e. this should launch with just `docker compose up --build`).

You will need to update docker-compose.yml to accurately reflect your info, and make sure the volume/bind mount is correct.

Once it is running `docker compose exec pds pdsadmin` to create your users.

This won't auto-update, but as long as the image structures stay much the same (i.e. app in /app in the official image, and the same invocation - this should continue to work by just incrementing the first line of the Dockerfile).

## fly.io

I am running this on fly.io at the moment - `fly machine exec <machine id> "pdsadmin create-invite-code"` to get an invitation code to sign up. Remember to set up SSL certificates for <pds_host> and *.<pds_host>, and mount a volume at /pds. It needs to be deployed with --ha=false or scaled down to a single machine or else it will not work properly.

## Backups

I'd recommend you grab a copy of your pds.env in case you need to recreate - you can do this by running `docker compose exec pds cat /pds/pds.env` or `fly machine exec <machine id> "cat /pds/pds.env"` on fly.io. And back up your volumes.

## LiteFS

If you choose to use LiteFS - you need to place a valid litefs.yml in your pds data volume. Do not specify any exec lines.