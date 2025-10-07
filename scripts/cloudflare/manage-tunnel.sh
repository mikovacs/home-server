#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_help() {
    echo -e "${GREEN}☁️ Cloudflare Tunnel Management${NC}"
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  status     Show tunnel status"
    echo "  logs       Show tunnel logs"
    echo "  restart    Restart tunnel"
    echo "  test       Test tunnel connectivity"
    echo "  config     Show current configuration"
    echo "  help       Show this help"
}

show_status() {
    echo -e "${YELLOW}Tunnel Status:${NC}"
    docker compose ps cloudflared
    echo ""
    
    if docker compose ps cloudflared | grep -q "Up"; then
        echo -e "${GREEN}✓ Tunnel is running${NC}"
    else
        echo -e "${RED}✗ Tunnel is not running${NC}"
    fi
}

show_logs() {
    echo -e "${YELLOW}Tunnel Logs:${NC}"
    docker compose logs -f cloudflared
}

restart_tunnel() {
    echo -e "${YELLOW}Restarting tunnel...${NC}"
    docker compose restart cloudflared
    echo -e "${GREEN}✓ Tunnel restarted${NC}"
}

test_connectivity() {
    echo -e "${YELLOW}Testing tunnel connectivity...${NC}"
    
    if docker exec cloudflared cloudflared tunnel info 2>/dev/null; then
        echo -e "${GREEN}✓ Tunnel connectivity OK${NC}"
    else
        echo -e "${RED}✗ Tunnel connectivity failed${NC}"
        echo "Check your tunnel token and network connection"
    fi
}

show_config() {
    echo -e "${YELLOW}Current Configuration:${NC}"
    if [ -f ".env" ]; then
        echo "Tunnel token: $(head -c 20 .env | tail -c +26)***"
    else
        echo -e "${RED}✗ No .env file found${NC}"
    fi
    
    echo -e "\n${YELLOW}Service URLs (configure these in Cloudflare Dashboard):${NC}"
    echo "- Plex: http://plex:32400"
    echo "- Grafana: http://grafana:3000"
    echo "- Prometheus: http://prometheus:9090"
    echo "- qBittorrent: http://qbittorrent:8080"
    echo "- Add more services as needed"
}

case "${1:-help}" in
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    restart)
        restart_tunnel
        ;;
    test)
        test_connectivity
        ;;
    config)
        show_config
        ;;
    help|*)
        show_help
        ;;
esac