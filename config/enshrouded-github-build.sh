#!/bin/bash
set -euo pipefail
R=/opt/enshrouded-github-repo
rm -rf "$R"; mkdir -p "$R"; cd "$R"
redact_json() { python3 -c 'import sys,re;t=open(sys.argv[1]).read();print(re.sub(r"(\"password\"\s*:\s*\")[^\"]*(\")",r"\1REDACTED\2",t),end="")' "$1"; }
redact_env() { sed -E "s/^([A-Za-z0-9_]*(PASSWORD|PASS|SECRET|TOKEN)[A-Za-z0-9_]*=).*/\1REDACTED/I" "$1"; }
# --- configs ---
mkdir -p config/server-v1 config/server-v2 config/systemd
cp /root/enshrouded-run.sh /root/enshrouded-updater-off config/server-v1/
redact_env /root/enshrouded.env > config/server-v1/enshrouded.env
cp /root/enshrouded-v2-run.sh /root/enshrouded-v2-updater-off config/server-v2/
redact_env /root/enshrouded-v2.env > config/server-v2/enshrouded-v2.env
redact_json /opt/enshrouded/server/enshrouded_server.json > config/server-v1/enshrouded_server.json
redact_json /opt/enshrouded-v2/server/enshrouded_server.json > config/server-v2/enshrouded_server.json
cp /etc/systemd/system/enshrouded-daily-restart.service /etc/systemd/system/enshrouded-daily-restart.timer config/systemd/
# --- world data ---
copy_world() { src=$1 dst=$2; mkdir -p "$dst"; for d in savegame backups; do [ -d "$src/$d" ] && cp -a "$src/$d" "$dst/"; done; true; }
copy_world /opt/enshrouded/server backups/server-v1/current-world
copy_world /opt/enshrouded-v2/server backups/server-v2/current-world
copy_world /opt/enshrouded-v2/old-world-2026-11-20 backups/server-v2/old-world-2026-11-20
copy_world /opt/enshrouded-v2/old-world-2026-11-22 backups/server-v2/old-world-2026-11-22
# manual archives: copy as-is unless they hold enshrouded_server.json (then rebuild with password redacted)
for side in "/opt/enshrouded:server-v1" "/opt/enshrouded-v2:server-v2"; do
  base=${side%%:*}; name=${side##*:}; mkdir -p backups/$name/manual-backups
  for f in "$base"/manual-backups/*.tgz; do
    out=backups/$name/manual-backups/$(basename "$f")
    if tar tzf "$f" | grep -qE '(^|/)(enshrouded_server\.json|.*\.env)$'; then
      t=$(mktemp -d); tar xzf "$f" -C "$t"
      find "$t" -name '*.env' -delete
      [ -f "$t/enshrouded_server.json" ] && { redact_json "$t/enshrouded_server.json" > "$t/x"; mv "$t/x" "$t/enshrouded_server.json"; }
      tar czf "$out" -C "$t" .; rm -rf "$t"; echo "sanitized $(basename "$f")"
    else cp "$f" "$out"; fi
  done
done
chown -R root:root "$R"
# safety checks
if grep -rIl -iE '"password"\s*:\s*"[^R"]' "$R" ; then echo "PASSWORD LEAK"; exit 1; fi
for f in $(find "$R" -name '*.tgz'); do tar xzOf "$f" --wildcards '*.json' 2>/dev/null | grep -iE '"password"\s*:\s*"[^R"]' && { echo "LEAK in $f"; exit 1; }; done
find "$R" -size +95M -print | grep . && { echo "FILE TOO BIG"; exit 1; }
for p in $(grep -o -E "[^ :=]{4,}$" /root/enshrouded-passwords.txt | sort -u) $(grep -h -o -E "\"password\"\s*:\s*\"[^\"]{4,}\"" /opt/enshrouded*/server/enshrouded_server.json | cut -d\" -f4 | sort -u); do
  grep -rIl -F -- "$p" "$R" && { echo "REAL PASSWORD LEAK"; exit 1; }
  for f in $(find "$R" -name "*.tgz"); do tar xzOf "$f" 2>/dev/null | grep -a -q -F -- "$p" && { echo "REAL PASSWORD LEAK in $f"; exit 1; }; done
done
echo "leak check: clean"
du -sh "$R"; find "$R" -type f | wc -l
