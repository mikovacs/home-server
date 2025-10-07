#!/bin/bash

MOUNT_POINT="/mnt/external-hdd"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🏠 Home Server Status${NC}"
echo "======================"

echo -e "\n${YELLOW}Mount Status:${NC}"
if mountpoint -q "$MOUNT_POINT"; then
    echo -e "${GREEN}✓ External HDD is mounted at $MOUNT_POINT${NC}"
    df -h "$MOUNT_POINT"
else
    echo -e "${RED}✗ External HDD is not mounted${NC}"
fi

echo -e "\n${YELLOW}Directory Structure:${NC}"
if [ -d "$MOUNT_POINT" ]; then
    tree "$MOUNT_POINT" 2>/dev/null || find "$MOUNT_POINT" -type d | sort
else
    echo -e "${RED}Mount point does not exist${NC}"
fi

echo -e "\n${YELLOW}Docker Services:${NC}"
if docker-compose ps 2>/dev/null; then
    docker-compose ps
else
    echo -e "${RED}No services running or docker-compose not found${NC}"
fi

echo -e "\n${YELLOW}Service Health:${NC}"
services=("plex" "grafana" "loki" "prometheus" "cloudflared")
for service in "${services[@]}"; do
    if docker-compose ps "$service" 2>/dev/null | grep -q "Up"; then
        echo -e "${GREEN}✓ $service is running${NC}"
    else
        echo -e "${RED}✗ $service is not running${NC}"
    fi
done