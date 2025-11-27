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

# Backup .env file (encrypted with integrity verification)
# Uses AES-256-CBC with HMAC-SHA256 for authenticated encryption (encrypt-then-MAC pattern)
echo "Backing up .env file..."
if [ -f ".env" ]; then
    ENV_BACKUP="$BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc"
    ENV_HMAC="$BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc.hmac"
    
    # Prompt for password once and use for both encryption and HMAC
    echo -n "Enter backup password: " >&2
    read -rs BACKUP_PASSWORD
    echo >&2
    echo -n "Verify backup password: " >&2
    read -rs BACKUP_PASSWORD_VERIFY
    echo >&2
    
    if [ "$BACKUP_PASSWORD" != "$BACKUP_PASSWORD_VERIFY" ]; then
        echo -e "${RED}✗ Passwords do not match${NC}"
        exit 1
    fi
    
    # Encrypt with AES-256-CBC
    if tar czf - .env | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass pass:"$BACKUP_PASSWORD" -out "$ENV_BACKUP"; then
        # Generate HMAC for integrity verification (using password as HMAC key)
        openssl dgst -sha256 -hmac "$BACKUP_PASSWORD" "$ENV_BACKUP" | awk '{print $2}' > "$ENV_HMAC"
        echo -e "${GREEN}✓ .env backed up (encrypted with integrity verification)${NC}"
    else
        echo -e "${RED}✗ Failed to backup .env${NC}"
        exit 1
    fi
    
    # Clear password from memory
    unset BACKUP_PASSWORD BACKUP_PASSWORD_VERIFY
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
        if tar czf "$BACKUP_DIR/${config//\//_}_${TIMESTAMP}.tar.gz" -C "$MOUNT_POINT" "$config"; then
            echo -e "${GREEN}✓ $config backed up${NC}"
        else
            echo -e "${RED}✗ Failed to backup $config${NC}"
        fi
    fi
done

echo ""
echo -e "${GREEN}Backup complete!${NC}"
echo "Location: $BACKUP_DIR"
echo ""
echo "To restore .env (verify integrity first):"
echo "  # Verify HMAC integrity (requires backup password)"
echo "  openssl dgst -sha256 -hmac \"\$PASSWORD\" $BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc | awk '{print \$2}' | diff - $BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc.hmac"
echo "  # If verification passes (no output), decrypt"
echo "  openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 -in $BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc | tar xz"