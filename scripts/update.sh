#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Updating Home Server${NC}"
echo "================================"
echo ""

echo "Pulling latest images..."
docker-compose pull

echo ""
echo "Recreating containers with new images..."
docker-compose up -d --force-recreate

echo ""
echo "Cleaning up old images..."
docker image prune -f

echo ""
echo -e "${GREEN}✓ Update complete!${NC}"
docker-compose ps