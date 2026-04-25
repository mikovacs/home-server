#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "Missing .env. Copy .env.EXAMPLE to .env first."
  exit 1
fi

set -a
source .env
set +a

if ! command -v cloudflared >/dev/null 2>&1; then
  echo "cloudflared CLI is required."
  exit 1
fi

hosts=(
  "$TRAEFIK_HOST"
  "$FILEBROWSER_HOST"
  "$PORTAINER_HOST"
  "$QBITTORRENT_HOST"
  "$PLEX_HOST"
  "$SONARR_HOST"
  "$RADARR_HOST"
  "$WHOAMI_HOST"
)

for host in "${hosts[@]}"; do
  cloudflared tunnel route dns "${CLOUDFLARE_TUNNEL_NAME}" "${host}"
done
