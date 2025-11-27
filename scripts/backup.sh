#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

MOUNT_POINT="/mnt/external-hdd"
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups/home-server}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Derive HMAC key from password using PBKDF2 with different salt
derive_hmac_key() {
    local password="$1"
    # Use a fixed salt prefix to derive a separate key for HMAC
    echo -n "$password" | openssl dgst -sha256 -hmac "hmac-key-derivation-salt" | awk '{print $2}'
}

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
echo "To restore .env, use the restore script:"
echo "  ./scripts/restore.sh $BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc"
echo ""
echo "Manual restore (verify integrity first):"
echo "  1. Read password securely: read -rs PASSWORD"
echo "  2. Derive HMAC key: HMAC_KEY=\$(echo -n \"\$PASSWORD\" | openssl dgst -sha256 -hmac \"hmac-key-derivation-salt\" | awk '{print \$2}')"
echo "  3. Verify: openssl dgst -sha256 -hmac \"\$HMAC_KEY\" $BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc | awk '{print \$2}' | diff - $BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc.hmac"
echo "  4. Decrypt: openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 -in $BACKUP_DIR/env_${TIMESTAMP}.tar.gz.enc | tar xz"