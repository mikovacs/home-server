# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please email [your-email] instead of using the issue tracker.

## Secure Configuration

### Environment Variables

This project uses sensitive credentials that must be protected:

1. **Never commit `.env`** - Already configured in `.gitignore`
2. **File permissions** - Automatically set to `600` by `start.sh`
3. **Token rotation** - Rotate `CLOUDFLARE_TUNNEL_TOKEN` periodically

### What's Stored

| Variable | Required | Persistence | Security Level |
|----------|----------|-------------|----------------|
| `TZ` | No | Session | Low |
| `PLEX_CLAIM` | First run only | Temporary (remove after setup) | Medium |
| `CLOUDFLARE_TUNNEL_TOKEN` | Yes | Permanent | **High** |

### Best Practices

- ✅ Use `.env.example` as template
- ✅ Enable 2FA on Cloudflare account
- ✅ Backup `.env` encrypted (e.g., 1Password, Bitwarden)
- ✅ Remove `PLEX_CLAIM` after first successful Plex setup
- ⚠️ Never share `.env` via email/chat
- ⚠️ Audit `docker-compose logs` for leaked secrets

## Network Security

### Exposed Ports

Review [`docker-compose.yml`](docker-compose.yml) for exposed ports:

- **Plex**: 32400 (HTTP), various discovery ports
- **qBittorrent**: 8081 (WebUI), 6881 (torrent)
- **Cloudflared**: No direct exposure (tunnel only)

### Recommendations

1. **Firewall**: Only expose Plex/qBittorrent to local network
2. **VPN**: Consider VPN for qBittorrent traffic
3. **Cloudflare Tunnel**: Use for secure external access instead of port forwarding

## Docker Security

- All services run as PUID/PGID 1000 (non-root inside container)
- Logging configured with size/rotation limits
- `restart: unless-stopped` - services auto-recover but can be manually stopped

## Updates

Keep Docker images updated:

```bash
docker-compose pull
docker-compose up -d
```

## External HDD Security

- Data stored unencrypted on `/mnt/external-hdd`
- Consider disk encryption (FileVault on macOS, LUKS on Linux)
- Ensure physical security of the external drive
