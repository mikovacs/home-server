#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ENV_FILE=".env"

echo -e "${GREEN}🔧 Creating Environment File${NC}"
echo "============================"

if [ -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}⚠ .env file already exists${NC}"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted. Existing .env file preserved."
        exit 0
    fi
fi

echo -e "${YELLOW}Creating .env file template...${NC}"
cat > "$ENV_FILE" << 'EOF'
# Cloudflare Tunnel Token (get from https://one.dash.cloudflare.com/)
# Navigate to Zero Trust > Access > Tunnels > Create Tunnel
CLOUDFLARE_TUNNEL_TOKEN=

# Grafana Admin Password (change from default!)
GRAFANA_PASSWORD=admin123

# Plex Claim Token (optional, get from https://plex.tv/claim)
# This token expires in 4 minutes, so get it right before setup
PLEX_CLAIM=

# Timezone for containers (change to your timezone)
TZ=America/New_York
EOF

chmod 600 "$ENV_FILE"

echo -e "${GREEN}✓ .env file created successfully${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "1. Edit the .env file with your actual values:"
echo -e "   ${YELLOW}nano .env${NC}"
echo -e "2. Get your Cloudflare tunnel token from:"
echo -e "   ${YELLOW}https://one.dash.cloudflare.com/${NC}"
echo -e "3. Get your Plex claim token (if needed) from:"
echo -e "   ${YELLOW}https://plex.tv/claim${NC}"
echo -e "4. Change the default Grafana password!"
echo -e "\n${RED}⚠ Important: Keep this .env file secure and never commit it to git!${NC}"