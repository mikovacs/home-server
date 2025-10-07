# 🏠 Home Server Setup

A Docker-based home server setup for Raspberry Pi with Plex media server, external HDD management, secure remote access via Cloudflare Tunnel, and comprehensive monitoring with Grafana.

![CI/CD Status](https://github.com/yourusername/home-server/workflows/Home%20Server%20CI%2FCD/badge.svg)

## 📋 Prerequisites

- Raspberry Pi (4 recommended) with Raspberry Pi OS
- External HDD/SSD for media storage
- Docker and Docker Compose installed
- Cloudflare account with a domain (for tunnel access)

## 🚀 Quick Start

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

#### Cloudflare Tunnel Configuration

1. Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Navigate to Access > Tunnels
3. Find your tunnel and add public hostnames:
   - `plex.yourdomain.com` → `http://plex:32400`
   - `grafana.yourdomain.com` → `http://grafana:3000`
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

**Remote Access (via Cloudflare Tunnel):**

- Plex: `https://plex.yourdomain.com`
- Grafana: `https://grafana.yourdomain.com`

## 📁 Directory Structure

After setup, your external HDD will have this structure:

```
/mnt/external-hdd/
├── plex/
│   ├── config/          # Plex configuration
│   └── transcode/       # Transcoding temp files
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
│   └── incomplete/      # In-progress downloads
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
- 🎯 **Custom Dashboards**: Create dashboards for your services
- 🔍 **Log Search**: Search and filter logs across all services
- 📊 **Real-time Monitoring**: Live metrics and log streaming

### Default Dashboards

After setup, you'll have access to:

- System overview dashboard
- Container metrics and logs
- Plex performance monitoring
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

### Tunnel Status

```bash
make tunnel-status     # Cloudflare tunnel status
```

This shows:

- Mount status and disk usage
- Directory structure
- Running Docker services
- Monitoring stack health
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

- Use strong passwords for all services (especially Grafana)
- Enable Plex authentication
- Consider Cloudflare Access policies for additional security
- Monitor access logs in Grafana
- Regularly update services with `make update`
- Use Grafana alerting for security events

## 🔄 Adding More Services

Popular services to add:

### Media Management

- **Sonarr** - TV show automation
- **Radarr** - Movie automation
- **Prowlarr** - Indexer management

### Download Clients

- **qBittorrent** - Torrent client
- **SABnzbd** - Usenet client

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
    driver: loki
    options:
      loki-url: "http://localhost:3100/loki/api/v1/push"
      loki-batch-size: "100"
```

## 📝 Configuration Files

- `docker-compose.yaml` - Service definitions
- `.env` - Environment variables (passwords, tokens, etc.)
- `Makefile` - Management commands
- `scripts/` - Setup and management scripts
- `monitoring/` - Grafana, Loki, and Prometheus configurations

## 💡 Tips

- Use `make help` to see all available commands
- Check logs with service-specific commands for easier debugging
- Use Grafana to monitor system health and performance
- Set up alerts in Grafana for critical system events
- The tunnel provides secure access without exposing your home IP
- All data persists on external HDD for easy backup/migration
- Services restart automatically unless manually stopped
- Use Grafana's explore feature to search logs effectively

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review logs: `make logs` or `make <service>-logs`
3. Check Grafana dashboards for system health
4. Ensure external HDD is properly mounted: `make status`
5. Verify monitoring stack: `make monitoring-logs`
6. Verify Cloudflare tunnel configuration: `make tunnel-status`
7. Check Docker service status: `docker ps`

## 🔗 Useful Links

- [Plex Documentation](https://support.plex.tv/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/)

## 🎯 What's Next?

After your basic setup is running:

1. **Explore Grafana Dashboards** - Create custom dashboards for your needs
2. **Set Up Alerting** - Get notified when something goes wrong
3. **Add Media Automation** - Install Sonarr/Radarr for automated downloads
4. **Expand Storage** - Add more services as your needs grow
5. **Backup Strategy** - Set up automated backups of your configurations
