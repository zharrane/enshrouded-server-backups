# Pililiu Enshrouded server — backups

Private backup of the Enshrouded dedicated servers hosted on AWS EC2 (eu-west-3, `35.180.179.51:15637`).

## What's here

| Folder | Contents |
|---|---|
| `backups/server-v2/current-world/` | The live "Pililiu v2" world (`savegame/world0.ksd`) and its automatic 2-hourly backups |
| `backups/server-v2/old-world-2026-11-20/` | World replaced by the fresh start on 2026-11-20 |
| `backups/server-v2/old-world-2026-11-22/` | World replaced by the fresh start on 2026-11-22 |
| `backups/server-v2/manual-backups/` | Manual `.tgz` snapshots taken before updates / resets / resize |
| `backups/server-v1/` | The original (now stopped) server: world, auto backups, manual snapshots |
| `config/server-v1`, `config/server-v2` | Docker run scripts, updater override, env files, `enshrouded_server.json` |
| `config/systemd/` | Daily 06:00 (Africa/Algiers) game restart timer |

**Passwords are redacted** (`"password": "REDACTED"`). The real ones are only on the server
(`/root/enshrouded-passwords.txt` and `enshrouded_server.json`).

Not included: the game server program files (~8 GB, re-downloadable from Steam, app 2278520).

## Restore a world

1. Stop the game: `sudo docker stop -t 120 enshrouded-v2`
2. Back up the current `/opt/enshrouded-v2/server/savegame`.
3. Copy the chosen `world0.ksd` into `/opt/enshrouded-v2/server/savegame/`
   (or unzip a `backups/*.zip`, or `tar xzf` a manual `.tgz` and take its `savegame/`).
4. `sudo chown -R 4711:4711 /opt/enshrouded-v2/server/savegame`
5. Start the game: `sudo docker start enshrouded-v2`

## Update this repo

On the server: `sudo bash /root/enshrouded-github-backup.sh`
