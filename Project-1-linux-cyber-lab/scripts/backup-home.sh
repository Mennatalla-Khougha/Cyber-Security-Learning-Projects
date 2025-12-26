#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/backups"
sudo mkdir -p "$BACKUP_DIR"

DATE=$(date +%Y%m%d)
TARGET="$BACKUP_DIR/home-$DATE.tar.gz"

# Create backup
sudo tar -czf "$TARGET" /home

# Keep last 7 backups, delete older
cd "$BACKUP_DIR" || exit 1
ls -1t home-*.tar.gz | tail -n +8 | xargs -r sudo rm --
