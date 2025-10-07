# 🏠 Home Server Setup

![CI/CD Status](https://github.com/mikovacs/home-server/actions/workflows/test.yml/badge.svg)
![Docker](https://img.shields.io/badge/Docker-Compose-blue)
![Grafana](https://img.shields.io/badge/Monitoring-Grafana-orange)
![Cloudflare](https://img.shields.io/badge/Tunnel-Cloudflare-orange)

A comprehensive Docker-based home server setup for Raspberry Pi with Plex media server, qBittorrent download client, external HDD management, secure remote access via Cloudflare Tunnel, and comprehensive monitoring with Grafana, Loki, and Prometheus.

## ✅ Automated Testing

Every push and pull request is automatically tested with:

- 🔍 **Configuration Validation** - Docker Compose, Makefile, and script syntax
- 📊 **Monitoring Stack** - Grafana, Loki, and Prometheus startup and health checks
- 📥 **Download Client** - qBittorrent WebUI accessibility and configuration
- 🧪 **Script Testing** - All shell scripts functionality and syntax
- 🔒 **Security Scanning** - Vulnerability detection and secrets checking  
- 🔗 **Integration Testing** - Full stack with volume mounts and networking

## 🚀 Quick Start

```bash
# Clone and setup
git clone https://github.com/yourusername/home-server.git
cd home-server

# Run tests locally (optional)
make test-all

# Initial setup
make setup
make create-env

# Edit .env with your values
nano .env

# Setup external HDD
sudo make mount

# Setup monitoring, downloads, and tunnel
make monitoring-setup
make qbittorrent-setup
make tunnel-setup

# Start everything
make start
```

## 🧪 Testing

```bash
# Run all tests
make test-all

# Individual test components
make validate-config    # Test configuration files
make test-scripts      # Test script functionality  
make test-monitoring   # Test monitoring stack (requires Docker)
```

### 1. Clone and Setup

```bash
git clone <your-repo>
cd home-server

# Initial setup (makes scripts executable and installs Docker if needed)
make setup
```

### 2. Setup External HDD

```bash
# Run the HDD setup script
make mount
```

This will:

- Help you identify and mount your external drive
- Create the required directory structure
- Set proper permissions
- Add permanent mount to `/etc/fstab`

### 3. Setup Monitoring Stack (Optional but Recommended)

```bash
# Setup centralized logging and monitoring
make monitoring-setup

# Add Grafana password to environment file
echo "GRAFANA_PASSWORD=your-secure-password" >> .env
```

### 4. Setup Cloudflare Tunnel (Optional but Recommended)

```bash
# Setup secure remote access
make tunnel-setup
```

Follow the prompts to:

- Install cloudflared
- Create tunnel token from Cloudflare Dashboard
- Configure secure remote access

### 5. Configure Services

#### Plex Configuration

1. Get a Plex claim token from <https://plex.tv/claim>
2. Edit `docker-compose.yaml` and add your claim token to `PLEX_CLAIM`
3. Update the timezone in `TZ` if needed

#### qBittorrent Configuration

1. Access qBittorrent WebUI at `http://your-pi-ip:8080`
2. Default login: `admin` / `adminadmin`
3. **Change the password immediately!**
4. Configure download paths and categories as needed
5. Set up any VPN or proxy settings if desired

#### Cloudflare Tunnel Configuration

1. Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Navigate to Access > Tunnels
3. Find your tunnel and add public hostnames:
   - `plex.yourdomain.com` → `http://plex:32400`
   - `grafana.yourdomain.com` → `http://grafana:3000`
   - `qbittorrent.yourdomain.com` → `http://qbittorrent:8080` (⚠️ **Security Warning:** Only expose if you trust your network and have strong authentication)
   - Add more services as you expand

### 6. Start Services

```bash
make start
```

### 7. Access Your Services

**Local Access:**

- Plex: `http://your-pi-ip:32400/web`
- Grafana: `http://your-pi-ip:3000` (admin / your-grafana-password)
- Prometheus: `http://your-pi-ip:9090`
- qBittorrent: `http://your-pi-ip:8080` (admin / adminadmin - **change this!**)

**Remote Access (via Cloudflare Tunnel):**

- Plex: `https://plex.yourdomain.com`
- Grafana: `https://grafana.yourdomain.com`
- qBittorrent: `https://qbittorrent.yourdomain.com` (if configured)

## 📁 Directory Structure

After setup, your external HDD will have this structure:

```
/mnt/external-hdd/
├── plex/
│   ├── config/          # Plex configuration
│   └── transcode/       # Transcoding temp files
├── qbittorrent/
│   └── config/          # qBittorrent configuration
├── cloudflared/
│   └── config/          # Cloudflare tunnel configuration
├── monitoring/          # Monitoring stack data
│   ├── grafana/
│   │   ├── data/        # Grafana database
│   │   └── config/      # Grafana configuration
│   ├── loki/
│   │   ├── data/        # Log storage
│   │   └── config/      # Loki configuration
│   ├── prometheus/
│   │   ├── data/        # Metrics storage
│   │   └── config/      # Prometheus configuration
│   └── promtail/
│       └── config/      # Log collection config
├── media/
│   ├── movies/          # Movie files
│   ├── tv/              # TV show files
│   └── music/           # Music files
├── downloads/
│   ├── complete/        # Completed downloads
│   ├── incomplete/      # In-progress downloads
│   ├── watch/           # Auto-import torrent files
│   └── torrents/        # Torrent file storage
├── backup/              # Backup storage
└── logs/                # Service logs
```

## 🛠️ Management Commands

### General Commands

```bash
make help              # Show all available commands
make status            # Check system status
make start             # Start all services
make stop              # Stop all services
make logs              # Show all logs
make update            # Update all services
```

### Monitoring Commands

```bash
make monitoring-setup  # Setup monitoring stack
make start-monitoring  # Start monitoring services only
make stop-monitoring   # Stop monitoring services
make monitoring-logs   # Show all monitoring logs
make grafana-logs      # Show Grafana logs only
```

### Download Management Commands

```bash
make qbittorrent-setup    # Setup qBittorrent
make qbittorrent-logs     # Show qBittorrent logs
make restart-qbittorrent  # Restart qBittorrent service
```

### Cloudflare Tunnel Commands

```bash
make tunnel-status     # Check tunnel status
make tunnel-logs       # Show tunnel logs
make tunnel-restart    # Restart tunnel
```

### Service-specific Commands

```bash
make plex-logs         # Show Plex logs
make restart-plex      # Restart Plex service
make prometheus-logs   # Show Prometheus logs
make loki-logs         # Show Loki logs
```

## 📊 Monitoring & Logging

### Centralized Logging Stack

The monitoring stack includes:

- **Grafana** - Dashboards and visualization
- **Loki** - Log aggregation and storage
- **Promtail** - Log collection from containers and system
- **Prometheus** - Metrics collection and storage
- **Node Exporter** - System metrics collection

### Features

- 📈 **System Metrics**: CPU, memory, disk usage, network
- 📋 **Container Logs**: All Docker service logs in one place
- 📥 **Download Monitoring**: Track qBittorrent download stats and logs  
- 🎯 **Custom Dashboards**: Create dashboards for your services
- 🔍 **Log Search**: Search and filter logs across all services
- 📊 **Real-time Monitoring**: Live metrics and log streaming

### Default Dashboards

After setup, you'll have access to:

- System overview dashboard
- Container metrics and logs
- Plex performance monitoring
- qBittorrent download statistics
- Tunnel connectivity status

## 🔧 Troubleshooting

### External HDD Not Mounting

1. Check if the drive is detected: `lsblk`
2. Check mount status: `mountpoint /mnt/external-hdd`
3. Manual mount: `sudo mount /dev/sdX1 /mnt/external-hdd`

### Plex Not Accessible

1. Check if container is running: `docker ps`
2. Check logs: `make plex-logs`
3. Verify port is not blocked: `sudo netstat -tlnp | grep 32400`

### qBittorrent Issues

1. Check if container is running: `docker ps`
2. Check logs: `make qbittorrent-logs`
3. Verify WebUI access: `http://your-pi-ip:8080`
4. Check default credentials: `admin` / `adminadmin`
5. Verify download directories have proper permissions:

   ```bash
   sudo chown -R 1000:1000 /mnt/external-hdd/downloads
   sudo chmod -R 755 /mnt/external-hdd/downloads
   ```

### Monitoring Issues

1. Check monitoring services: `make monitoring-logs`
2. Verify Grafana access: `http://your-pi-ip:3000`
3. Check Loki connectivity in Grafana datasources
4. Restart monitoring stack: `make stop-monitoring && make start-monitoring`

### Cloudflare Tunnel Issues

1. Check tunnel status: `make tunnel-status`
2. View tunnel logs: `make tunnel-logs`
3. Verify tunnel token in `.env` file
4. Check Cloudflare Dashboard configuration

### Permission Issues

```bash
# Fix permissions
sudo chown -R 1000:1000 /mnt/external-hdd
sudo chmod -R 755 /mnt/external-hdd
```

## 📊 Monitoring

### System Status

```bash
make status            # Overall system status
```

### Monitoring Stack Status

```bash
make monitoring-logs   # All monitoring services
make grafana-logs      # Grafana specific logs
```

### Download Client Status

```bash
make qbittorrent-logs  # qBittorrent logs and status
```

### Tunnel Status

```bash
make tunnel-status     # Cloudflare tunnel status
```

This shows:

- Mount status and disk usage
- Directory structure
- Running Docker services
- Monitoring stack health
- Download client status
- Tunnel connectivity status

## 🌐 Remote Access & Security

### Cloudflare Tunnel Benefits

- ✅ No port forwarding required
- ✅ No dynamic DNS needed
- ✅ Built-in DDoS protection
- ✅ SSL/TLS encryption
- ✅ Access control options
- ✅ Works behind NAT/firewall

### Security Best Practices

- Use strong passwords for all services (especially Grafana and qBittorrent)
- **Change qBittorrent default password immediately**
- Enable Plex authentication
- **Be cautious about exposing qBittorrent via tunnel** - consider VPN instead
- Consider Cloudflare Access policies for additional security
- Monitor access logs in Grafana
- Regularly update services with `make update`
- Use Grafana alerting for security events
- Use VPN or proxy for qBittorrent if downloading copyrighted content

## 🔄 Adding More Services

Popular services to add:

### Media Management

- **Sonarr** - TV show automation (works great with qBittorrent)
- **Radarr** - Movie automation (works great with qBittorrent)
- **Prowlarr** - Indexer management
- **Jackett** - Torrent tracker API support

### Download Clients

- **SABnzbd** - Usenet client
- **Transmission** - Alternative torrent client

### Additional Monitoring

- **Portainer** - Docker UI management
- **Nginx Proxy Manager** - Reverse proxy with UI
- **Uptime Kuma** - Service uptime monitoring

To add services:

1. Add service definition to `docker-compose.yaml`
2. Configure logging driver to send logs to Loki
3. Create required directories in setup scripts
4. Update volume mappings as needed
5. Add Cloudflare tunnel routes for remote access
6. Create Grafana dashboards for new services

### Example Service with Logging

```yaml
new-service:
  image: example/service:latest
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"
```

## 📝 Configuration Files

- `docker-compose.yaml` - Service definitions
- `.env` - Environment variables (passwords, tokens, etc.)
- `Makefile` - Management commands
- `scripts/` - Setup and management
