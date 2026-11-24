#!/bin/bash
# Rebuild the sanitized backup folder and push it to github.com/zharrane/enshrouded-server-backups
set -euo pipefail
R=/opt/enshrouded-github-repo
GIT_DIR_KEEP=/root/enshrouded-github.git
bash /root/enshrouded-github-build.sh
cp /root/enshrouded-github-README.md $R/README.md
cp /root/enshrouded-github-build.sh /root/enshrouded-github-backup.sh $R/config/
export GIT_SSH_COMMAND="ssh -i /root/.ssh/github_backup -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
[ -d $GIT_DIR_KEEP ] || git init -q --bare -b main $GIT_DIR_KEEP
cd $R
git --git-dir=$GIT_DIR_KEEP --work-tree=$R -c user.name=zharrane -c user.email=zharrane@users.noreply.github.com add -A
git --git-dir=$GIT_DIR_KEEP --work-tree=$R -c user.name=zharrane -c user.email=zharrane@users.noreply.github.com commit -q -m "Backup $(date -u +%Y-%m-%d_%H%MUTC)" || echo "nothing changed"
git --git-dir=$GIT_DIR_KEEP push -q git@github.com:zharrane/enshrouded-server-backups.git main
echo PUSHED
