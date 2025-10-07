#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🏠 Home Server Initial Setup${NC}"
echo "================================"

# Make scripts executable
echo -e "${YELLOW}Making scripts executable...${NC}"
chmod +x scripts/external-hdd/*.sh
chmod +x scripts/cloudflare/*.sh
chmod +x scripts/monitoring/*.sh
chmod +x scripts/create-env.sh

echo -e "${GREEN}✓ Scripts are now executable${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker not found. Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${GREEN}✓ Docker installed${NC}"
else
    echo -e "${GREEN}✓ Docker is already installed${NC}"
fi

# Check if Docker Compose is installed
if ! docker compose version &> /dev/null; then
    echo -e "${YELLOW}Installing Docker Compose...${NC}"
    sudo apt update
    sudo apt install -y docker-compose-plugin
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✓ Docker Compose is already installed${NC}"
fi

echo -e "\n${GREEN}🎉 Initial setup complete!${NC}"
echo -e "\nNext steps:"
echo -e "1. Run: ${YELLOW}make create-env${NC} to create environment file"
echo -e "2. Edit the .env file with your tokens and passwords"
echo -e "3. Run: ${YELLOW}sudo make mount${NC} to setup external HDD"
echo -e "4. Run: ${YELLOW}make monitoring-setup${NC} to setup monitoring"
echo -e "5. Run: ${YELLOW}make tunnel-setup${NC} to setup Cloudflare tunnel"
echo -e "6. Run: ${YELLOW}make start${NC} to start all services"
echo -e "7. Check status: ${YELLOW}make status${NC}"

if groups $USER | grep &>/dev/null '\bdocker\b'; then
    echo -e "\n${GREEN}✓ You're already in the docker group${NC}"
else
    echo -e "\n${YELLOW}⚠ You may need to reboot for docker group changes to take effect${NC}"
fi