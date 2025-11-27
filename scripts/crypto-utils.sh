#!/bin/bash

# Shared functions for backup and restore scripts
# This file is sourced by backup.sh and restore.sh

# Derive HMAC key from password using HMAC-SHA256 with a domain separator
# The fixed domain separator ("hmac-key-derivation-salt") is used to cryptographically
# separate the HMAC key from the encryption password. This prevents using the same
# key material for both encryption and authentication (key separation principle).
# Note: The salt being visible in source code is acceptable because:
# 1. The actual secret (password) is still required
# 2. The salt's purpose is domain separation, not secrecy
# 3. Standard AEAD schemes like AES-GCM also use fixed domain separators internally
derive_hmac_key() {
    local password="$1"
    echo -n "$password" | openssl dgst -sha256 -hmac "hmac-key-derivation-salt" | awk '{print $2}'
}
