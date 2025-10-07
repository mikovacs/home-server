#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}📥 Setting up qBittorrent${NC}"
echo "=============================="

QBITTORRENT_DIR="/mnt/external-hdd/qbittorrent"
DOWNLOADS_DIR="/mnt/external-hdd/downloads"

# Create directories
echo -e "${YELLOW}Creating qBittorrent directories...${NC}"
sudo mkdir -p "$QBITTORRENT_DIR/config"
sudo mkdir -p "$DOWNLOADS_DIR"/{complete,incomplete,watch}

# Set permissions
sudo chown -R 1000:1000 "$QBITTORRENT_DIR"
sudo chown -R 1000:1000 "$DOWNLOADS_DIR"
sudo chmod -R 755 "$QBITTORRENT_DIR"
sudo chmod -R 755 "$DOWNLOADS_DIR"

# Create qBittorrent configuration
echo -e "${YELLOW}Creating qBittorrent configuration...${NC}"
cat > "$QBITTORRENT_DIR/config/qBittorrent.conf" << 'EOF'
[Application]
FileLogger\Enabled=true
FileLogger\Path=/config/logs
FileLogger\Backup=true
FileLogger\DeleteOld=true
FileLogger\MaxSizeBytes=66560
FileLogger\Age=1
FileLogger\AgeType=1

[BitTorrent]
Session\DefaultSavePath=/downloads
Session\TempPath=/downloads/incomplete
Session\TempPathEnabled=true
Session\Port=6881
Session\Interface=
Session\InterfaceName=
Session\InterfaceAddress=
Session\Encryption=0
Session\MaxConnections=200
Session\MaxConnectionsPerTorrent=100
Session\MaxUploads=4
Session\MaxUploadsPerTorrent=4
Session\GlobalMaxSeedingMinutes=0
Session\GlobalMaxRatio=-1
Session\DHT=true
Session\DHTPort=6881
Session\PeX=true
Session\LSD=true
Session\uTP_rate_limited=true
Session\IncludeOverheadInLimits=false
Session\AnnounceToAllTrackers=false
Session\AnnounceToAllTiers=true
Session\AsyncIOThreadsCount=10

[Preferences]
WebUI\Enabled=true
WebUI\Port=8081
WebUI\Address=*
WebUI\Username=admin
WebUI\Password_PBKDF2="@ByteArray(ARQ77eY1NUZaQsuDHbIMCA==:0WMRkYTUWVT9wVvdDtHAjU9b3b7uB8NR1Gur2hmQCvCDpm39Q+PsJRJPaCU51dEiz+dTzh8qbPsL8WkFljQYFQ==)"
WebUI\LocalHostAuth=false
WebUI\UseUPnP=false
WebUI\CSRFProtection=true
WebUI\ClickjackingProtection=true
WebUI\SecureCookie=true
WebUI\MaxAuthenticationFailCount=5
WebUI\BanDuration=3600
WebUI\SessionTimeout=3600
WebUI\AlternativeUIEnabled=false
WebUI\RootFolder=
WebUI\HTTPS\Enabled=false
WebUI\ServerDomains=*
WebUI\CustomHTTPHeaders=
WebUI\CustomHTTPHeadersEnabled=false

Downloads\SavePath=/downloads
Downloads\TempPath=/downloads/incomplete
Downloads\UseIncompleteExtension=true
Downloads\FinishedTorrentExportDir=/downloads/torrents
Downloads\ScanDirs=/downloads/watch
Downloads\ScanDirsV2=@Variant(\0\0\0\x1c\0\0\0\x1\0\0\0\x16\0/\0\x64\0o\0w\0n\0l\0o\0\x61\0\x64\0s\0/\0w\0\x61\0t\0\x63\0h\0\0\0\x2\0\0\0\0)
Downloads\TorrentExportDir=/downloads/torrents
Downloads\PreAllocation=false

General\Locale=en
General\UseRandomPort=false
General\CloseToTray=true
General\StartMinimized=false
General\SystrayEnabled=true
General\CloseToTrayNotified=true
General\MinimizeToTray=false
General\MinimizeToTrayNotified=true
General\NoSplashScreen=true
General\HideZeroValues=false
General\HideZeroComboValues=0
General\RefreshInterval=1500
General\AlternatingRowColors=true
General\MinimizeToTray=false
General\StartMinimized=false
General\ConfirmDeletion=true
General\ExitConfirm=true
General\MinimizeToTrayNotified=true
General\AutoUpdateTrackers=false
General\BrandingEnabled=true
General\PowerManagement=true
General\ShutdownWhenDownloadsComplete=false
General\ShutdownqBTWhenDownloadsComplete=false
General\PowerOffComputer=false
General\SuspendComputer=false
General\HibernateComputer=false
General\ShutdownComputer=false
General\InhibitSystemSleep=false
General\CreateTorrentSubfolder=true
General\UpdateCheck=true
General\ConfirmTorrentDeletion=true
General\ConfirmTorrentRecheck=true
General\ConfirmRemoveAllTags=true
General\TrayIconStyle=0
EOF

# Create watch directory for automatic torrent adding
mkdir -p "$DOWNLOADS_DIR"/{torrents,watch}

echo -e "${GREEN}✓ qBittorrent configuration complete${NC}"
echo -e "\nNext steps:"
echo -e "1. Run: ${YELLOW}docker compose up -d qbittorrent${NC}"
echo -e "2. Access qBittorrent WebUI at: ${YELLOW}http://your-pi-ip:8081${NC}"
echo -e "3. Default login: ${YELLOW}admin / adminadmin${NC}"
echo -e "4. Change the password immediately after first login!"
echo -e "5. Configure your download categories and paths"
echo -e "\n${YELLOW}Directory Structure Created:${NC}"
echo -e "- Config: $QBITTORRENT_DIR/config"
echo -e "- Downloads: $DOWNLOADS_DIR/complete"
echo -e "- Incomplete: $DOWNLOADS_DIR/incomplete"
echo -e "- Watch folder: $DOWNLOADS_DIR/watch"
echo -e "- Torrents: $DOWNLOADS_DIR/torrents"