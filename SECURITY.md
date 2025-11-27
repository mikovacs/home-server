# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please email [your-email] instead of using the issue tracker.

**Response Time**: We aim to respond within 48 hours and provide a fix within 7 days for critical vulnerabilities.

## Secure Configuration

### Environment Variables

This project uses sensitive credentials that must be protected:

1. **Never commit `.env`** - Already configured in `.gitignore`
2. **File permissions** - Automatically set to `600` by `start.sh`
3. **Token rotation** - Rotate `CLOUDFLARE_TUNNEL_TOKEN` periodically (recommended: every 90 days)
4. **Encrypted backups** - Use `make backup` which encrypts `.env` with AES-256

### What's Stored

| Variable | Required | Persistence | Security Level | Rotation Schedule |
|----------|----------|-------------|----------------|-------------------|
| `TZ` | No | Session | Low | N/A |
| `PUID`/`PGID` | No | Session | Low | N/A |
| `CLOUDFLARE_TUNNEL_TOKEN` | Yes | Permanent | **Critical** | Every 90 days |

### Best Practices

- ✅ Use `.env.example` as template
- ✅ Enable 2FA on Cloudflare account
- ✅ Backup `.env` encrypted (via `make backup` or password manager)
- ✅ Run `make audit-security` before each commit
- ✅ Use strong passwords for service web UIs (Plex, qBittorrent)
- ⚠️ Never share `.env` via email/chat/screenshots
- ⚠️ Audit `docker-compose logs` for leaked secrets
- ⚠️ Review exposed ports regularly

## Backup Security

### Encryption Requirements

All backups containing sensitive data **must** be encrypted:

1. **`.env` backups**: Automatically encrypted with AES-256-CBC by backup script
2. **Password protection**: You'll be prompted for encryption password
3. **Secure storage**: Store encrypted backups in multiple locations:
   - Local encrypted drive
   - Cloud storage (encrypted)
   - Password manager vault

### Backup Best Practices

```bash
# Create encrypted backup
make backup

# Verify backup integrity
openssl enc -aes-256-cbc -d -pbkdf2 -in ~/backups/home-server/env_TIMESTAMP.tar.gz.enc -out /dev/null

# Store backup password securely in password manager
```

### Restore Security

When restoring from backups:

1. Verify backup source is trusted
2. Scan restored files for tampering
3. Rotate all tokens after restore
4. Audit security configuration: `make audit-security`

## Network Security

### Exposed Ports

Review [`docker-compose.yml`](docker-compose.yml) for exposed ports:

| Service | Port | Protocol | Exposure | Risk Level |
|---------|------|----------|----------|------------|
| Plex | 32400 | HTTP | Local + Tunnel | Medium |
| Plex Discovery | 1900, 5353, 32410-32414 | UDP | Local | Low |
| qBittorrent WebUI | 8081 | HTTP | Local only | Medium |
| qBittorrent | 6881 | TCP/UDP | Internet | High |
| Cloudflared | None | N/A | Tunnel only | Low |

### Network Security Recommendations

1. **Firewall Configuration**:

   ```bash
   # macOS - Enable firewall
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
   
   # Linux - UFW example
   sudo ufw default deny incoming
   sudo ufw allow 32400/tcp  # Plex (local network only)
   sudo ufw allow 8081/tcp   # qBittorrent WebUI (local only)
   sudo ufw allow 6881       # qBittorrent torrents
   sudo ufw enable
   ```

2. **VPN for qBittorrent**: Consider routing qBittorrent through VPN for privacy

3. **Cloudflare Tunnel**: Use for secure external access instead of port forwarding

4. **Local Network Only**: Bind Plex and qBittorrent to `127.0.0.1` if not using remote access

5. **Network Isolation**: Use Docker networks to isolate services (already configured)

## Docker Security

### Container Security

- All services run as PUID/PGID 1000 (non-root inside container)
- Logging configured with size/rotation limits (prevents disk filling)
- `restart: unless-stopped` - services auto-recover but can be manually stopped
- Health checks monitor service availability
- Resource limits prevent resource exhaustion

### Security Hardening

1. **Read-only root filesystem** (optional):

   ```yaml
   services:
     plex:
       read_only: true
       tmpfs:
         - /tmp
         - /var/tmp
   ```

2. **Drop capabilities**:

   ```yaml
   services:
     plex:
       cap_drop:
         - ALL
       cap_add:
         - CHOWN
         - SETUID
         - SETGID
   ```

3. **Security scanning**:

   ```bash
   # Scan images for vulnerabilities
   docker scan lscr.io/linuxserver/plex:latest
   docker scan lscr.io/linuxserver/qbittorrent:latest
   docker scan cloudflare/cloudflared:latest
   ```

## Updates & Maintenance

### Regular Maintenance Schedule

| Task | Frequency | Command | Priority |
|------|-----------|---------|----------|
| Check for updates | Weekly | `docker-compose pull` | High |
| Apply updates | Weekly | `make update` | High |
| Security audit | Weekly | `make audit-security` | Critical |
| Backup configuration | Daily | `make backup` | Critical |
| Rotate tunnel token | Every 90 days | Cloudflare dashboard | High |
| Review logs | Weekly | `make logs` | Medium |
| Check disk space | Weekly | `make status` | High |
| Test restore | Monthly | Restore from backup | Medium |

### Update Process

1. **Pre-update**:

   ```bash
   # Create backup
   make backup
   
   # Check current status
   make status
   
   # Review changelog
   docker inspect --format='{{.Config.Labels}}' plex
   ```

2. **Update**:

   ```bash
   make update
   ```

3. **Post-update**:

   ```bash
   # Verify services started
   make status
   
   # Check logs for errors
   make logs
   
   # Run security audit
   make audit-security
   ```

### Keeping Docker Images Updated

```bash
# Weekly update check
docker-compose pull

# Apply updates with recreation
docker-compose up -d --force-recreate

# Clean up old images
docker image prune -f
```

## Incident Response

### Security Incident Procedure

If you suspect a security breach:

1. **Immediate Actions**:

   ```bash
   # Stop all services
   make stop
   
   # Capture logs
   docker-compose logs > incident-logs-$(date +%Y%m%d-%H%M%S).txt
   
   # Disconnect from network (if needed)
   docker network disconnect homeserver plex
   ```

2. **Investigation**:
   - Review logs for suspicious activity
   - Check file modifications: `find /mnt/external-hdd -type f -mtime -1`
   - Verify `.env` integrity
   - Check for unauthorized containers: `docker ps -a`

3. **Recovery**:

   ```bash
   # Rotate all credentials
   # 1. Generate new Cloudflare tunnel token
   # 2. Update .env with new token
   
   # Restore from clean backup
   openssl enc -aes-256-cbc -d -in ~/backups/home-server/env_TIMESTAMP.tar.gz.enc | tar xz
   
   # Rebuild containers
   docker-compose down
   docker-compose up -d --force-recreate
   
   # Run security audit
   make audit-security
   ```

4. **Post-Incident**:
   - Document incident details
   - Update security procedures
   - Implement additional monitoring
   - Consider security hardening measures

### Common Security Issues

| Issue | Detection | Response |
|-------|-----------|----------|
| `.env` leaked | Git history, logs | Rotate all tokens, audit commits |
| Unauthorized access | Unusual logs, unknown sessions | Change passwords, check firewall |
| Compromised token | Cloudflare alerts | Rotate token immediately |
| Malware on HDD | Antivirus scan | Quarantine files, restore from backup |
| Resource exhaustion | High CPU/disk usage | Check for crypto miners, review logs |

### Security Monitoring

Enable monitoring for security events:

```bash
# Check for failed authentication attempts (qBittorrent)
docker logs qbittorrent | grep -i "failed\|unauthorized"

# Monitor resource usage
docker stats --no-stream

# Check for suspicious network connections
docker exec plex netstat -tunlp
```

## External HDD Security

### Physical Security

- Store external HDD in secure location
- Use cable locks if in shared environment
- Consider tamper-evident seals

### Data-at-Rest Encryption

**macOS FileVault**:

```bash
# Enable FileVault on external disk
diskutil apfs enableFileVault /dev/diskX -user disk
```

**Linux LUKS**:

```bash
# Create encrypted volume (WARNING: destroys data)
sudo cryptsetup luksFormat /dev/sdX
sudo cryptsetup open /dev/sdX external-hdd-encrypted
sudo mkfs.ext4 /dev/mapper/external-hdd-encrypted
```

### Access Control

- Mount HDD only when services are running
- Use restrictive permissions: `chmod 700 /mnt/external-hdd`
- Audit file access regularly:

  ```bash
  find /mnt/external-hdd -type f -mtime -7 -ls
  ```

## Compliance & Auditing

### Security Audit Checklist

Run before each deployment:

- [ ] `.env` permissions are 600
- [ ] `.env` not tracked by git
- [ ] All required variables present
- [ ] PUID/PGID match current user
- [ ] Cloudflare tunnel token valid
- [ ] Docker images updated
- [ ] Backups created and encrypted
- [ ] Firewall rules configured
- [ ] Logs reviewed for anomalies
- [ ] Disk space sufficient

### Automated Audit

```bash
# Run security audit
make audit-security

# Add to pre-commit hook
echo '#!/bin/bash' > .git/hooks/pre-commit
echo 'make audit-security' >> .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Additional Security Resources

- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Cloudflare Tunnel Security](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/security/)
- [Plex Security](https://support.plex.tv/articles/200430283-network-security/)
- [OWASP Docker Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

## Security Contact

For security-related questions or concerns, please contact: [your-email]

**PGP Key**: [Optional - add your PGP key fingerprint]
