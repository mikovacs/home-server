#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Path to .env file
ENV_FILE=".env"

echo -e "${GREEN}Home Server Setup Script${NC}"
echo "================================"
echo ""

# Function to validate Cloudflare token format
validate_cloudflare_token() {
    local token=$1
    # Cloudflare tokens are base64-encoded and typically start with "eyJ"
    if [[ ! $token =~ ^eyJ ]]; then
        echo -e "${YELLOW}Warning: Token doesn't match expected format (should start with 'eyJ')${NC}"
        read -p "Continue anyway? (y/N): " continue
        if [[ ! $continue =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    return 0
}

# Function to check if Docker is running
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        echo "Please install Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info &> /dev/null 2>&1; then
        echo -e "${RED}Error: Docker daemon is not running${NC}"
        echo "Please start Docker and try again"
        exit 1
    fi
}

# Function to check if external HDD is mounted (skip on macOS for now)
check_hdd_mounted() {
    # On macOS, use different check since mountpoint command may not exist
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [ ! -d "/mnt/external-hdd" ]; then
            echo -e "${YELLOW}Warning: /mnt/external-hdd directory not found${NC}"
            echo ""
            read -p "Run HDD setup script? (Y/n): " run_setup
            run_setup=${run_setup:-Y}
            
            if [[ $run_setup =~ ^[Yy]$ ]]; then
                if [ -f "$(dirname "$0")/setup-hdd.sh" ]; then
                    bash "$(dirname "$0")/setup-hdd.sh"
                else
                    echo -e "${RED}setup-hdd.sh not found${NC}"
                    exit 1
                fi
            else
                echo -e "${YELLOW}Continuing without HDD setup...${NC}"
                echo ""
            fi
        fi
    else
        # Linux check
        if ! mountpoint -q "/mnt/external-hdd" 2>/dev/null; then
            echo -e "${YELLOW}Warning: External HDD not mounted at /mnt/external-hdd${NC}"
            echo ""
            read -p "Run HDD setup script? (Y/n): " run_setup
            run_setup=${run_setup:-Y}
            
            if [[ $run_setup =~ ^[Yy]$ ]]; then
                if [ -f "$(dirname "$0")/setup-hdd.sh" ]; then
                    bash "$(dirname "$0")/setup-hdd.sh"
                else
                    echo -e "${RED}setup-hdd.sh not found${NC}"
                    exit 1
                fi
            else
                echo -e "${RED}Cannot start services without mounted HDD${NC}"
                exit 1
            fi
        fi
    fi
}

# Pre-flight checks
echo "Running pre-flight checks..."
check_docker
check_hdd_mounted
echo -e "${GREEN}✓ Pre-flight checks passed${NC}"
echo ""

# Function to prompt for variable
prompt_for_variable() {
    local var_name=$1
    local var_description=$2
    local current_value=$3
    local is_required=$4
    
    if [ -n "$current_value" ]; then
        echo -e "${YELLOW}$var_description${NC}"
        # Mask sensitive values in display (show only first 20 chars)
        if [[ "$var_name" == *"TOKEN"* ]] || [[ "$var_name" == *"CLAIM"* ]]; then
            echo "Current value: ${current_value:0:20}***"
        else
            echo "Current value: $current_value"
        fi
        read -p "Keep this value? (Y/n): " keep_value
        keep_value=${keep_value:-Y}
        
        if [[ $keep_value =~ ^[Yy]$ ]]; then
            echo "$var_name=$current_value"
            return 0
        fi
    fi
    
    echo -e "${YELLOW}$var_description${NC}"
    if [ "$is_required" = true ]; then
        while true; do
            read -p "Enter $var_name: " new_value
            if [ -n "$new_value" ]; then
                # Special validation for Cloudflare token
                if [ "$var_name" = "CLOUDFLARE_TUNNEL_TOKEN" ]; then
                    if validate_cloudflare_token "$new_value"; then
                        echo "$var_name=$new_value"
                        return 0
                    fi
                else
                    echo "$var_name=$new_value"
                    return 0
                fi
            else
                echo -e "${RED}This value is required!${NC}"
            fi
        done
    else
        read -p "Enter $var_name (optional): " new_value
        if [ -n "$new_value" ]; then
            echo "$var_name=$new_value"
        else
            echo "# $var_name="
        fi
        return 0
    fi
}

# Load existing .env if it exists
if [ -f "$ENV_FILE" ]; then
    echo -e "${GREEN}Found existing .env file${NC}"
    source "$ENV_FILE"
    echo ""
else
    echo -e "${YELLOW}No .env file found, creating new one${NC}"
    echo ""
fi

# Create temporary file for new .env
TEMP_ENV=$(mktemp)

# Collect all variables
echo "# Home Server Environment Variables" > "$TEMP_ENV"
echo "# Generated on $(date)" >> "$TEMP_ENV"
echo "" >> "$TEMP_ENV"

# Timezone
prompt_for_variable "TZ" "Timezone (e.g., Europe/Budapest, America/New_York)" "$TZ" false >> "$TEMP_ENV"

# Plex Claim Token
echo ""
echo -e "${YELLOW}Plex Claim Token${NC}"
echo "Get your claim token from: https://www.plex.tv/claim/"
echo -e "${GREEN}NOTE: This is only needed for first-time setup and can be removed after${NC}"
prompt_for_variable "PLEX_CLAIM" "Plex Claim Token (optional, expires in 4 minutes)" "$PLEX_CLAIM" false >> "$TEMP_ENV"

# Cloudflare Tunnel Token
echo ""
prompt_for_variable "CLOUDFLARE_TUNNEL_TOKEN" "Cloudflare Tunnel Token" "$CLOUDFLARE_TUNNEL_TOKEN" true >> "$TEMP_ENV"

# Review and confirm
echo ""
echo "================================"
echo -e "${GREEN}Review your configuration:${NC}"
echo "================================"
# Mask sensitive values in display
sed 's/CLOUDFLARE_TUNNEL_TOKEN=.*/CLOUDFLARE_TUNNEL_TOKEN=***MASKED***/; s/PLEX_CLAIM=.*/PLEX_CLAIM=***MASKED***/' "$TEMP_ENV"
echo ""
read -p "Save this configuration? (Y/n): " confirm
confirm=${confirm:-Y}

if [[ $confirm =~ ^[Yy]$ ]]; then
    mv "$TEMP_ENV" "$ENV_FILE"
    
    # Set restrictive permissions on .env file
    chmod 600 "$ENV_FILE"
    
    echo -e "${GREEN}✓ Configuration saved to $ENV_FILE${NC}"
    echo -e "${GREEN}✓ Set permissions to 600 (owner read/write only)${NC}"
    echo ""
    
    # Ask if user wants to start services
    read -p "Start services with docker-compose? (Y/n): " start_services
    start_services=${start_services:-Y}
    
    if [[ $start_services =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${GREEN}Starting services...${NC}"
        docker-compose up -d
        
        # Wait a moment and check health
        echo ""
        echo "Waiting for services to start..."
        sleep 5
        echo ""
        docker-compose ps
        
        echo ""
        echo -e "${GREEN}✓ Services started successfully!${NC}"
        echo ""
        echo "Access your services at:"
        echo "  - Plex: http://localhost:32400/web"
        echo "  - qBittorrent: http://localhost:8081"
        echo ""
        echo -e "${YELLOW}Security reminders:${NC}"
        echo "  ✓ .env file permissions set to 600"
        echo "  ✓ After Plex setup completes, remove PLEX_CLAIM from .env"
        echo "  ✓ .env is in .gitignore (never commit secrets)"
        echo "  ✓ Backup CLOUDFLARE_TUNNEL_TOKEN in password manager"
        echo ""
        echo "Run 'make audit-security' to check .env security status"
    fi
else
    rm "$TEMP_ENV"
    echo -e "${RED}Configuration cancelled${NC}"
    exit 1
fi
