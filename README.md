# Home Server

A Docker-based home server setup with Plex, qBittorrent, and Cloudflare Tunnel.

## Quick Start

1. **Setup external HDD**:

   ```bash
   make setup-hdd
   ```

2. **Configure environment**:

   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

   Or use the interactive setup:

   ```bash
   make start
   ```

   The script will automatically:
   - Prompt for required environment variables
   - Create `.env` with secure permissions (600)
   - Validate and save your configuration

3. **Start services** (if not started by the setup script):

   ```bash
   docker-compose up -d
   ```

## Services

- **Plex**: <http://localhost:32400/web>
- **qBittorrent**: <http://localhost:8081>

## Available Commands

Run `make help` to see all available commands:

- `make start` - Configure environment and start all services
- `make stop` - Stop all running services
- `make restart` - Restart all services
- `make status` - Show service and HDD status
- `make logs` - Show logs from all services
- `make backup` - Backup configurations and .env (encrypted)
- `make update` - Update Docker images and restart services
- `make audit-security` - Check .env security configuration

## System Requirements

### Hardware Requirements

- **CPU**: Dual-core processor (quad-core recommended for Plex transcoding)
- **RAM**:
  - Minimum: 4GB
  - Recommended: 8GB or more
  - Plex: 2-4GB
  - qBittorrent: 512MB-1GB
  - Cloudflared: 128-256MB
- **Storage**:
  - System: 20GB minimum for Docker images and logs
  - External HDD: Depends on media library size
    - Config files: ~2GB
    - Transcode cache: 10-50GB (temporary files)

### Software Requirements

- Docker Engine 20.10 or later
- Docker Compose 2.0 or later
- macOS 11+ or Linux (Ubuntu 20.04+, Debian 11+)

### Network Requirements

- Stable internet connection for Cloudflare Tunnel
- Local network access for Plex and qBittorrent
- Port availability: 32400, 8081, 6881

## Backup & Restore

### Creating Backups

Run the backup script to create encrypted backups of your configuration:

```bash
make backup
```

This will:

- Backup `.env` file (encrypted with AES-256)
- Backup service configurations (Plex, qBittorrent, Cloudflared)
- Store backups in `~/backups/home-server/` by default

Set custom backup location:

```bash
BACKUP_DIR=/path/to/backups make backup
```

### Restoring from Backup

1. **Restore .env file**:

   ```bash
   openssl enc -aes-256-gcm -d -pbkdf2 -iter 100000 -in ~/backups/home-server/env_TIMESTAMP.tar.gz.enc | tar xz
   ```

2. **Restore service configurations**:

   ```bash
   # Stop services first
   make stop
   
   # Extract configuration backup
   tar xzf ~/backups/home-server/plex_config_TIMESTAMP.tar.gz -C /mnt/external-hdd
   tar xzf ~/backups/home-server/qbittorrent_config_TIMESTAMP.tar.gz -C /mnt/external-hdd
   tar xzf ~/backups/home-server/cloudflared_TIMESTAMP.tar.gz -C /mnt/external-hdd
   
   # Start services
   make start
   ```

### Backup Schedule

Recommended backup frequency:

- **Daily**: `.env` file (automated with cron)
- **Weekly**: Service configurations
- **Before updates**: Full backup

Set up automated daily backups:

```bash
# Add to crontab (crontab -e)
0 2 * * * cd /path/to/home-server && make backup
```

## Updates

### Updating Services

Update Docker images to the latest versions:

```bash
make update
```

Or manually:

```bash
# Pull latest images
docker-compose pull

# Recreate containers with new images
docker-compose up -d --force-recreate

# Clean up old images
docker image prune -f
```

### Update Schedule

- **Security updates**: Check weekly
- **Feature updates**: Check monthly
- **Major version updates**: Review changelog before updating

### Pre-Update Checklist

Before updating, always:

1. Create a full backup: `make backup`
2. Check service health: `make status`
3. Review changelog for breaking changes
4. Plan for brief service downtime

## Troubleshooting

### Services Won't Start

**Problem**: Docker containers fail to start

**Solutions**:

1. Check Docker is running:

   ```bash
   docker info
   ```

2. Check external HDD is mounted:

   ```bash
   ls -la /mnt/external-hdd
   ```

3. Verify `.env` file exists and has correct permissions:

   ```bash
   ls -la .env
   make audit-security
   ```

4. Check logs for specific errors:

   ```bash
   make logs
   ```

### Permission Denied Errors

**Problem**: Services can't write to external HDD

**Solutions**:

1. Check PUID/PGID match your user:

   ```bash
   id -u  # Should match PUID in .env
   id -g  # Should match PGID in .env
   ```

2. Fix ownership:

   ```bash
   sudo chown -R $(id -u):$(id -g) /mnt/external-hdd
   ```

3. Re-run HDD setup:

   ```bash
   make setup-hdd
   ```

### Plex Won't Stream

**Problem**: Plex transcoding fails or buffering issues

**Solutions**:

1. Check available disk space for transcoding:

   ```bash
   df -h /mnt/external-hdd/plex/transcode
   ```

2. Verify network connectivity:

   ```bash
   docker exec plex ping -c 3 google.com
   ```

3. Check Plex logs:

   ```bash
   docker logs plex --tail 100
   ```

4. Clear transcode cache:

   ```bash
   rm -rf /mnt/external-hdd/plex/transcode/*
   ```

### qBittorrent Connection Issues

**Problem**: qBittorrent can't connect to peers

**Solutions**:

1. Verify ports are accessible:

   ```bash
   docker ps | grep qbittorrent
   ```

2. Check port forwarding in router (port 6881)

3. Restart qBittorrent:

   ```bash
   docker restart qbittorrent
   ```

### Cloudflare Tunnel Disconnected

**Problem**: Tunnel shows as disconnected

**Solutions**:

1. Verify tunnel token is correct:

   ```bash
   make audit-security
   ```

2. Check Cloudflared logs:

   ```bash
   docker logs cloudflared --tail 50
   ```

3. Verify Cloudflare dashboard shows tunnel as healthy

4. Restart tunnel:

   ```bash
   docker restart cloudflared
   ```

### External HDD Not Mounting

**Problem**: `/mnt/external-hdd` not accessible

**Solutions**:

1. Check if drive is connected:

   ```bash
   # macOS
   diskutil list
   
   # Linux
   lsblk
   ```

2. Re-run HDD setup:

   ```bash
   make setup-hdd
   ```

3. Check drive for errors:

   ```bash
   # macOS
   diskutil verifyVolume /dev/diskX
   
   # Linux
   sudo fsck /dev/sdX
   ```

### High Resource Usage

**Problem**: Services consuming too much CPU/RAM

**Solutions**:

1. Check container resource usage:

   ```bash
   docker stats
   ```

2. Review logs for errors:

   ```bash
   make logs
   ```

3. Limit Plex transcoding:
   - In Plex settings: Settings > Transcoder > Transcoder quality

4. Adjust resource limits in [`docker-compose.yml`](docker-compose.yml)

### Getting Help

If issues persist:

1. Check service status: `make status`
2. Run security audit: `make audit-security`
3. Review logs: `make logs`
4. Check [`SECURITY.md`](SECURITY.md) for security issues
5. Search GitHub issues or create a new one

## Security Notes

### Environment Variables

- **`CLOUDFLARE_TUNNEL_TOKEN`**: Required for cloudflared to run. Keep this secure and never commit to git
- **`PUID`/`PGID`**: Should match your user ID for proper file permissions

### Best Practices

1. ✅ **`.env` protection**: Already in `.gitignore` - never commits to git
2. ✅ **File permissions**: `start.sh` automatically sets `chmod 600` on `.env`
3. 🔐 **Token storage**: Use a password manager to backup `CLOUDFLARE_TUNNEL_TOKEN`
4. 💾 **Encrypted backups**: Backup script encrypts `.env` with AES-256
5. 🔄 **Regular updates**: Keep Docker images updated weekly

For detailed security information, see [`SECURITY.md`](SECURITY.md).

## Contributing

Please read [`SECURITY.md`](SECURITY.md) before contributing, especially regarding handling of sensitive information.

## License

This project is provided as-is for personal use.
