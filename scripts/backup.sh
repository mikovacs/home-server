#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

MOUNT_POINT="/mnt/external-hdd"
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups/home-server}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo -e "${GREEN}Home Server Backup Script${NC}"
echo "================================"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup .env file (encrypted)
echo "Backing up .env file..."
if [ -f ".env" ]; then
    tar czf - .env | openssl enc -aes-256-cbc -salt -pbkdf2 -out "$BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc"
    echo -e "${GREEN}✓ .env backed up (encrypted)${NC}"
else
    echo -e "${YELLOW}⚠ .env not found${NC}"
fi

# Backup config directories
echo ""
echo "Backing up service configurations..."
CONFIGS=("plex/config" "qbittorrent/config" "cloudflared")

for config in "${CONFIGS[@]}"; do
    if [ -d "$MOUNT_POINT/$config" ]; then
        echo "Backing up $config..."
        tar czf "$BACKUP_DIR/${config//\//_}_${TIMESTAMP}.tar.gz" -C "$MOUNT_POINT" "$config"
        echo -e "${GREEN}✓ $config backed up${NC}"
    fi
done

echo ""
echo -e "${GREEN}Backup complete!${NC}"
echo "Location: $BACKUP_DIR"
echo ""
echo "To restore .env:"
echo "  openssl enc -aes-256-cbc -d -pbkdf2 -in $BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc | tar xz"