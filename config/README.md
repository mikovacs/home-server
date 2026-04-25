# Config Directory

This directory contains versioned, static configuration used by the stack.

Runtime application state is stored under `/mnt/appdata` by default:

| App | Runtime path |
| --- | --- |
| Portainer | `/mnt/appdata/portainer` |
| File Browser database | `/mnt/appdata/filebrowser` |
| qBittorrent | `/mnt/appdata/qbittorrent` |
| Plex | `/mnt/appdata/plex` |
| Sonarr | `/mnt/appdata/sonarr` |
| Radarr | `/mnt/appdata/radarr` |

The Cloudflare Tunnel credentials JSON is also placed under this directory at `config/cloudflared/credentials.json`, but it is ignored by Git because it is a secret.
