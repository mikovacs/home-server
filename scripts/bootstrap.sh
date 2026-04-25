#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  cp .env.EXAMPLE .env
  echo "Created .env from .env.EXAMPLE. Edit .env before starting the stack."
fi

set -a
source .env
set +a

mkdir -p \
  "${APPDATA_PATH}/downloads" \
  "${APPDATA_PATH}/filebrowser" \
  "${APPDATA_PATH}/portainer" \
  "${APPDATA_PATH}/plex" \
  "${APPDATA_PATH}/qbittorrent" \
  "${APPDATA_PATH}/sonarr" \
  "${APPDATA_PATH}/radarr" \
  "${PLEX_MEDIA_PATH}/movies" \
  "${PLEX_MEDIA_PATH}/series"

if [[ ! -f config/cloudflared/credentials.json ]]; then
  echo "Missing config/cloudflared/credentials.json."
  echo "Run ./scripts/cloudflare-tunnel-create.sh after cloudflared tunnel login."
fi

docker compose config >/dev/null
echo "Bootstrap complete."
