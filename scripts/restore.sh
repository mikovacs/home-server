#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Source shared crypto utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./crypto-utils.sh
source "$SCRIPT_DIR/crypto-utils.sh"

restore_env_file() {
    local -r enc_file="$1"
    local -r hmac_file="${enc_file}.hmac"
    
    if [ ! -f "$enc_file" ]; then
        echo -e "${RED}✗ Encrypted backup file not found: $enc_file${NC}"
        return 1
    fi
    
    if [ ! -f "$hmac_file" ]; then
        echo -e "${RED}✗ HMAC file not found: $hmac_file${NC}"
        return 1
    fi
    
    # Prompt for password
    echo -n "Enter backup password: " >&2
    local password
    read -rs password
    echo >&2
    
    # Derive HMAC key from password
    local -r hmac_key=$(derive_hmac_key "$password")
    
    # Verify integrity
    echo "Verifying backup integrity..."
    local computed_hmac
    computed_hmac=$(openssl dgst -sha256 -hmac "$hmac_key" "$enc_file" | awk '{print $2}')
    local stored_hmac
    stored_hmac=$(cat "$hmac_file")
    
    if [ "$computed_hmac" != "$stored_hmac" ]; then
        echo -e "${RED}✗ Integrity verification failed! Backup may have been tampered with or password is incorrect.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Integrity verified${NC}"
    
    # Decrypt and extract
    echo "Decrypting and restoring .env..."
    if openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 -pass pass:"$password" -in "$enc_file" | tar xz; then
        echo -e "${GREEN}✓ .env restored successfully${NC}"
    else
        echo -e "${RED}✗ Failed to restore .env${NC}"
        return 1
    fi
}

echo -e "${GREEN}Home Server Restore Script${NC}"
echo "================================"
echo ""

if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <encrypted_backup_file>${NC}"
    echo "Example: $0 ~/backups/home-server/env_20241127_120000.tar.gz.enc"
    exit 1
fi

if ! restore_env_file "$1"; then
    exit 1
fi

echo ""
echo -e "${YELLOW}⚠ Important: After restoring, consider rotating all tokens for security.${NC}"
echo "Run 'make audit-security' to verify the restored configuration."
