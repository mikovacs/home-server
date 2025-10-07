#!/bin/bash

set -e  # Exit on any error

# Configuration
MOUNT_POINT="/mnt/external-hdd"
USER_ID=1000
GROUP_ID=1000

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🏠 Home Server External HDD Setup Script${NC}"
echo "============================================="

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

# List available drives
echo -e "\n${YELLOW}Available drives:${NC}"
lsblk -p

echo -e "\n${YELLOW}Please enter the device path (e.g., /dev/sda1):${NC}"
read -r DEVICE_PATH

if [ ! -b "$DEVICE_PATH" ]; then
    print_error "Device $DEVICE_PATH not found!"
    exit 1
fi

# Confirm the device
echo -e "\n${YELLOW}You selected: $DEVICE_PATH${NC}"
echo -e "${RED}WARNING: This will set up the device for your home server.${NC}"
echo -e "${RED}Make sure this is the correct device!${NC}"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Create mount point
print_status "Creating mount point at $MOUNT_POINT"
mkdir -p "$MOUNT_POINT"

# Mount the device
print_status "Mounting $DEVICE_PATH to $MOUNT_POINT"
mount "$DEVICE_PATH" "$MOUNT_POINT"

# Create directory structure
print_status "Creating directory structure"
mkdir -p "$MOUNT_POINT"/{plex/{config,transcode},media/{movies,tv,music}}

# Additional directories for future services
mkdir -p "$MOUNT_POINT"/{downloads/{complete,incomplete},backup,logs}
mkdir -p "$MOUNT_POINT"/cloudflared/config
mkdir -p "$MOUNT_POINT"/monitoring/{grafana/{data,config},loki/{data,config},promtail/config,prometheus/{data,config}}

# Set permissions
print_status "Setting permissions (UID: $USER_ID, GID: $GROUP_ID)"
chown -R "$USER_ID:$GROUP_ID" "$MOUNT_POINT"
chmod -R 755 "$MOUNT_POINT"

# Add to fstab for permanent mounting
print_status "Adding to /etc/fstab for permanent mounting"
if ! grep -q "$DEVICE_PATH" /etc/fstab; then
    # Get filesystem type
    FS_TYPE=$(blkid -o value -s TYPE "$DEVICE_PATH")
    echo "$DEVICE_PATH $MOUNT_POINT $FS_TYPE defaults 0 2" >> /etc/fstab
    print_status "Added to fstab"
else
    print_warning "Entry already exists in fstab"
fi

# Display directory structure
echo -e "\n${GREEN}Directory structure created:${NC}"
tree "$MOUNT_POINT" 2>/dev/null || find "$MOUNT_POINT" -type d | sort

echo -e "\n${GREEN}🎉 External HDD setup complete!${NC}"
echo -e "\nNext steps:"
echo -e "1. Copy your media files to the appropriate directories"
echo -e "2. Run: ${YELLOW}docker-compose up -d${NC}"
echo -e "3. Access Plex at: ${YELLOW}http://$(hostname -I | awk '{print $1}'):32400/web${NC}"

# Display disk usage
echo -e "\n${YELLOW}Disk usage:${NC}"
df -h "$MOUNT_POINT"