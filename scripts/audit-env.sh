#!/usr/bin/env bash

# Audit .env file for security issues

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"

cd "$REPO_ROOT"

echo -e "${GREEN}Security Audit - .env File${NC}"
echo "================================"
echo ""

if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}✗ .env file not found${NC}"
    exit 1
fi

# Check file permissions
perms=$(stat -f "%Lp" "$ENV_FILE" 2>/dev/null || stat -c "%a" "$ENV_FILE" 2>/dev/null)
if [ "$perms" = "600" ]; then
    echo -e "${GREEN}✓ File permissions: 600 (secure)${NC}"
else
    echo -e "${RED}✗ File permissions: $perms (should be 600)${NC}"
    echo "  Fix with: chmod 600 $ENV_FILE"
fi

# Check if PLEX_CLAIM is still present and has a value
if grep -q "^PLEX_CLAIM=.\+" "$ENV_FILE"; then
    echo -e "${YELLOW}⚠ PLEX_CLAIM still has a value${NC}"
    echo "  This should only be present during initial setup"
    echo "  Remove after Plex is configured"
else
    echo -e "${GREEN}✓ PLEX_CLAIM removed or empty (good)${NC}"
fi

# Check if CLOUDFLARE_TUNNEL_TOKEN exists
if grep -q "^CLOUDFLARE_TUNNEL_TOKEN=.\+" "$ENV_FILE"; then
    echo -e "${GREEN}✓ CLOUDFLARE_TUNNEL_TOKEN present${NC}"
else
    echo -e "${RED}✗ CLOUDFLARE_TUNNEL_TOKEN missing or empty${NC}"
fi

# Check if .env is in git (it shouldn't be)
if git ls-files --error-unmatch "$ENV_FILE" &> /dev/null 2>&1; then
    echo -e "${RED}✗ CRITICAL: .env is tracked by git!${NC}"
    echo "  Remove with: git rm --cached .env"
else
    echo -e "${GREEN}✓ .env not tracked by git${NC}"
fi

# Check .gitignore
if grep -q "^\.env$" "$REPO_ROOT/.gitignore" 2>/dev/null; then
    echo -e "${GREEN}✓ .env listed in .gitignore${NC}"
else
    echo -e "${RED}✗ .env not in .gitignore${NC}"
fi

echo ""
echo "Audit complete"
