# Ubuntu Server Setup

## Mount layout

Recommended host paths:

| Purpose | Path |
| --- | --- |
| App data, downloads, container state | `/mnt/appdata` |
| Plex media | `/mnt/plex-media` |
| Movies | `/mnt/plex-media/movies` |
| Series | `/mnt/plex-media/series` |
| Downloads | `/mnt/appdata/downloads` |

Create directories:

```bash
sudo mkdir -p /mnt/appdata/{downloads,filebrowser,portainer,plex,qbittorrent,sonarr,radarr}
sudo mkdir -p /mnt/plex-media/{movies,series}
sudo chown -R "$USER:$USER" /mnt/appdata /mnt/plex-media
```

Use `/etc/fstab` with stable disk UUIDs, not `/dev/sdX` names. Get UUIDs with:

```bash
lsblk -f
```

Example:

```fstab
UUID=<internal-hdd-uuid> /mnt/appdata ext4 defaults,nofail 0 2
UUID=<external-hdd-uuid> /mnt/plex-media ext4 defaults,nofail 0 2
```

## Docker

Install Docker Engine using the official Docker documentation for Ubuntu, then verify:

```bash
docker version
docker compose version
```

Add your user to the `docker` group if desired:

```bash
sudo usermod -aG docker "$USER"
```

Log out and back in after changing group membership.
