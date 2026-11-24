#!/bin/bash
# Recreate the game server container (world and settings live on /opt/enshrouded
# and in /root/enshrouded.env). Updates are off: see /root/enshrouded-updater-off.
set -e
# Stop gracefully first (up to 120 s) so the game saves the world before removal.
docker stop enshrouded >/dev/null 2>&1 || true
docker rm enshrouded >/dev/null 2>&1 || true
docker run -d --name enshrouded --restart unless-stopped --stop-timeout 120 --network host \
  -v /opt/enshrouded:/opt/enshrouded \
  -v /root/enshrouded-updater-off:/usr/local/etc/enshrouded/enshrouded-updater:ro \
  --env-file /root/enshrouded.env \
  mornedhels/enshrouded-server:latest
