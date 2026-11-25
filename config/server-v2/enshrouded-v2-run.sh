#!/bin/bash
# Recreate the "Pililiu v2" game server container. Game files and world live in
# /opt/enshrouded-v2, settings in /root/enshrouded-v2.env.
# Updates are off: see /root/enshrouded-v2-updater-off.
set -e
# Stop gracefully first (up to 120 s) so the game saves the world before removal.
docker stop enshrouded-v2 >/dev/null 2>&1 || true
docker rm enshrouded-v2 >/dev/null 2>&1 || true
docker run -d --name enshrouded-v2 --restart always --stop-timeout 120 --network host \
  -v /opt/enshrouded-v2:/opt/enshrouded \
  -v /root/enshrouded-v2-updater-off:/usr/local/etc/enshrouded/enshrouded-updater:ro \
  --env-file /root/enshrouded-v2.env \
  mornedhels/enshrouded-server:latest
