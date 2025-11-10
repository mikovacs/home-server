#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MOUNT_POINT="/mnt/external-hdd"
REQUIRED_FOLDERS=(
    "plex/config"
    "plex/transcode"
    "media/movies"
    "media/tv"
    "media/kids_movies"
    "media/kids_tv"
    "media/music"
    "qbittorrent/config"
    "downloads/complete"
    "downloads/incomplete"
    "cloudflared/config"
)

echo -e "${GREEN}External HDD Setup Script${NC}"
echo "================================"
echo ""

# Function to check if HDD is mounted
check_mounted() {
    if mountpoint -q "$MOUNT_POINT"; then
        echo -e "${GREEN}✓ HDD is mounted at $MOUNT_POINT${NC}"
        return 0
    else
        echo -e "${YELLOW}✗ HDD is not mounted at $MOUNT_POINT${NC}"
        return 1
    fi
}

# Function to list available disks
list_disks() {
    echo -e "${BLUE}Available disks:${NC}"
    diskutil list
}

# Function to mount HDD
mount_hdd() {
    echo ""
    echo -e "${YELLOW}Please mount your external HDD${NC}"
    echo ""
    
    list_disks
    
    echo ""
    echo "Enter the disk identifier (e.g., disk2s1) or 'q' to quit:"
    read -p "> " disk_id
    
    if [ "$disk_id" = "q" ]; then
        echo -e "${RED}Setup cancelled${NC}"
        exit 1
    fi
    
    # Create mount point if it doesn't exist
    if [ ! -d "$MOUNT_POINT" ]; then
        echo -e "${YELLOW}Creating mount point at $MOUNT_POINT${NC}"
        sudo mkdir -p "$MOUNT_POINT"
    fi
    
    # Mount the disk
    echo -e "${YELLOW}Mounting /dev/$disk_id to $MOUNT_POINT${NC}"
    sudo mount -t apfs "/dev/$disk_id" "$MOUNT_POINT" 2>/dev/null || \
    sudo mount -t hfs "/dev/$disk_id" "$MOUNT_POINT" 2>/dev/null || \
    sudo mount -t exfat "/dev/$disk_id" "$MOUNT_POINT" 2>/dev/null || \
    sudo diskutil mount -mountPoint "$MOUNT_POINT" "$disk_id"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ HDD mounted successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to mount HDD${NC}"
        return 1
    fi
}

# Function to create folder structure
create_folders() {
    echo ""
    echo -e "${YELLOW}Checking folder structure...${NC}"
    
    local missing_folders=0
    
    for folder in "${REQUIRED_FOLDERS[@]}"; do
        local full_path="$MOUNT_POINT/$folder"
        
        if [ -d "$full_path" ]; then
            echo -e "${GREEN}✓${NC} $folder"
        else
            echo -e "${YELLOW}✗${NC} $folder (missing)"
            ((missing_folders++))
        fi
    done
    
    if [ $missing_folders -gt 0 ]; then
        echo ""
        read -p "Create missing folders? (Y/n): " create
        create=${create:-Y}
        
        if [[ $create =~ ^[Yy]$ ]]; then
            for folder in "${REQUIRED_FOLDERS[@]}"; do
                local full_path="$MOUNT_POINT/$folder"
                
                if [ ! -d "$full_path" ]; then
                    echo -e "${YELLOW}Creating${NC} $folder"
                    mkdir -p "$full_path"
                    
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}✓${NC} Created $folder"
                    else
                        echo -e "${RED}✗${NC} Failed to create $folder"
                    fi
                fi
            done
        else
            echo -e "${YELLOW}Skipping folder creation${NC}"
        fi
    else
        echo -e "${GREEN}✓ All required folders exist${NC}"
    fi
}

# Function to set permissions
set_permissions() {
    echo ""
    read -p "Set ownership to current user for all folders? (Y/n): " set_perms
    set_perms=${set_perms:-Y}
    
    if [[ $set_perms =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Setting ownership...${NC}"
        sudo chown -R $(id -u):$(id -g) "$MOUNT_POINT"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Permissions set successfully${NC}"
        else
            echo -e "${RED}✗ Failed to set permissions${NC}"
        fi
    fi
}

# Function to display summary
display_summary() {
    echo ""
    echo "================================"
    echo -e "${GREEN}Setup Summary${NC}"
    echo "================================"
    echo "Mount point: $MOUNT_POINT"
    echo ""
    echo "Folder structure:"
    for folder in "${REQUIRED_FOLDERS[@]}"; do
        echo "  - $folder"
    done
    echo ""
    df -h "$MOUNT_POINT" | tail -1
    echo ""
}

# Main script execution
echo "Step 1: Check if HDD is mounted"
if ! check_mounted; then
    echo ""
    read -p "Would you like to mount the HDD now? (Y/n): " should_mount
    should_mount=${should_mount:-Y}
    
    if [[ $should_mount =~ ^[Yy]$ ]]; then
        if ! mount_hdd; then
            echo -e "${RED}Failed to mount HDD. Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}HDD must be mounted to continue. Exiting.${NC}"
        exit 1
    fi
fi

echo ""
echo "Step 2: Create folder structure"
create_folders

echo ""
echo "Step 3: Set permissions"
set_permissions

display_summary

echo -e "${GREEN}HDD setup complete!${NC}"
echo ""
echo "You can now run the services with:"
echo "  ./scripts/start.sh"
echo ""
