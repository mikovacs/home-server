#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}☁️ Cloudflare Tunnel Setup${NC}"
echo "=========================="

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo -e "${YELLOW}Installing cloudflared...${NC}"
    
    # Download and install cloudflared for ARM64 (Raspberry Pi)
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
    sudo dpkg -i cloudflared-linux-arm64.deb
    rm cloudflared-linux-arm64.deb
    
    echo -e "${GREEN}✓ cloudflared installed${NC}"
fi

# Create config directory
CLOUDFLARED_DIR="/mnt/external-hdd/cloudflared/config"
sudo mkdir -p "$CLOUDFLARED_DIR"
sudo chown -R 1000:1000 "/mnt/external-hdd/cloudflared"

echo -e "\n${YELLOW}Cloudflare Tunnel Setup Instructions:${NC}"
echo "1. Go to https://one.dash.cloudflare.com/"
echo "2. Navigate to Zero Trust > Access > Tunnels"
echo "3. Create a new tunnel"
echo "4. Choose 'Cloudflared' as connector"
echo "5. Give it a name (e.g., 'home-server')"
echo "6. Copy the tunnel token from the installation command"
echo ""

read -p "Enter your Cloudflare Tunnel Token: " TUNNEL_TOKEN

if [ -z "$TUNNEL_TOKEN" ]; then
    echo -e "${RED}✗ Tunnel token cannot be empty${NC}"
    exit 1
fi

# Create or update .env file
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    # Update existing .env file
    if grep -q "CLOUDFLARE_TUNNEL_TOKEN" "$ENV_FILE"; then
        sed -i "s/CLOUDFLARE_TUNNEL_TOKEN=.*/CLOUDFLARE_TUNNEL_TOKEN=$TUNNEL_TOKEN/" "$ENV_FILE"
    else
        echo "CLOUDFLARE_TUNNEL_TOKEN=$TUNNEL_TOKEN" >> "$ENV_FILE"
    fi
else
    # Create new .env file
    echo "CLOUDFLARE_TUNNEL_TOKEN=$TUNNEL_TOKEN" > "$ENV_FILE"
fi

chmod 600 "$ENV_FILE"

echo -e "${GREEN}✓ Tunnel token saved to .env file${NC}"

echo -e "\n${YELLOW}Next steps in Cloudflare Dashboard:${NC}"
echo "1. Configure public hostnames for your services:"
echo "   - Subdomain: plex"
echo "   - Domain: your-domain.com"
echo "   - Service: http://plex:32400"
echo ""
echo "2. Add additional services as needed:"
echo "   - Subdomain: grafana"
echo "   - Service: http://grafana:3000"
echo ""
echo "3. Save the tunnel configuration"
echo ""
echo -e "${GREEN}Then run: docker compose up -d cloudflared${NC}"

# Test tunnel token format
if [[ $TUNNEL_TOKEN =~ ^[A-Za-z0-9+/=]+$ ]]; then
    echo -e "${GREEN}✓ Tunnel token format looks valid${NC}"
else
    echo -e "${YELLOW}⚠ Warning: Tunnel token format may be incorrect${NC}"
fi