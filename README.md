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

## Security Notes

### Environment Variables

- **`PLEX_CLAIM`**: Only needed for initial Plex setup. After first successful start, you can remove it from `.env`
- **`CLOUDFLARE_TUNNEL_TOKEN`**: Required for cloudflared to run. Keep this secure and never commit to git

### Best Practices

1. ✅ **`.env` protection**: Already in `.gitignore` - never commits to git
2. ✅ **File permissions**: `start.sh` automatically sets `chmod 600` on `.env`
3. 🔄 **Remove temporary secrets**: Delete `PLEX_CLAIM` from `.env` after Plex setup completes
4. 🔐 **Token storage**: Consider using a password manager to backup `CLOUDFLARE_TUNNEL_TOKEN`
5. 💾 **Encrypted backups**: Ensure your backup solution encrypts `.env` contents

## Services

- **Plex**: <http://localhost:32400/web>
- **qBittorrent**: <http://localhost:8081>

## Available Commands

Run `make help` to see all available commands.
