#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

MOUNT_POINT="/mnt/external-hdd"
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups/home-server}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Encryption parameters (AES-256-CBC with PBKDF2 for strong key derivation)
ENC_CIPHER="aes-256-cbc"
ENC_OPTS="-salt -pbkdf2 -iter 100000"
# Source shared crypto utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./crypto-utils.sh
source "$SCRIPT_DIR/crypto-utils.sh"

backup_env_file() {
    local -r ENV_BACKUP="$BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc"
    local -r ENV_HMAC="$BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc.hmac"
    
    # Prompt for password
    echo -n "Enter backup password: " >&2
    local password
    read -rs password
    echo >&2
    echo -n "Verify backup password: " >&2
    local password_verify
    read -rs password_verify
    echo >&2
    
    if [ "$password" != "$password_verify" ]; then
        echo -e "${RED}✗ Passwords do not match${NC}"
        return 1
    fi
    
    # Derive separate HMAC key from password
    local -r hmac_key=$(derive_hmac_key "$password")
    
    # Encrypt with AES-256-CBC
    if tar czf - .env | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass pass:"$password" -out "$ENV_BACKUP"; then
        # Generate HMAC for integrity verification using derived key
        openssl dgst -sha256 -hmac "$hmac_key" "$ENV_BACKUP" | awk '{print $2}' > "$ENV_HMAC"
        echo -e "${GREEN}✓ .env backed up (encrypted with integrity verification)${NC}"
    else
        echo -e "${RED}✗ Failed to backup .env${NC}"
        return 1
    fi
}

echo -e "${GREEN}Home Server Backup Script${NC}"
echo "================================"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup .env file (encrypted with integrity verification)
# Uses AES-256-CBC with HMAC-SHA256 for authenticated encryption (encrypt-then-MAC pattern)
echo "Backing up .env file..."
if [ -f ".env" ]; then
    tar czf - .env | openssl enc -${ENC_CIPHER} ${ENC_OPTS} -out "$BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc"
    if [ $? -eq 0 ] && [ -f "$BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc" ]; then
        echo -e "${GREEN}✓ .env backed up (encrypted)${NC}"
    else
        echo -e "${RED}✗ Failed to backup .env${NC}"
    if ! backup_env_file; then
        exit 1
    fi
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
echo "To restore .env:"
echo "  openssl enc -${ENC_CIPHER} -d ${ENC_OPTS} -in $BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc | tar xz"
echo "To restore .env, use the restore script:"
echo "  ./scripts/restore.sh $BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc"
echo ""
echo "Or use 'make restore BACKUP_FILE=$BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc'"
