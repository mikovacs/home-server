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
  echo "cloudflared CLI is required. Install it, then run: cloudflared tunnel login"
  exit 1
fi

mkdir -p config/cloudflared

cloudflared tunnel create --credentials-file config/cloudflared/credentials.json "${CLOUDFLARE_TUNNEL_NAME}"

TUNNEL_ID="$(cloudflared tunnel list --name "${CLOUDFLARE_TUNNEL_NAME}" --output json | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -n 1)"

if [[ -n "${TUNNEL_ID}" ]]; then
  echo "Tunnel created: ${TUNNEL_ID}"
  echo "Update CLOUDFLARE_TUNNEL_ID in .env with this value."
else
  echo "Tunnel created. Run 'cloudflared tunnel list' and update CLOUDFLARE_TUNNEL_ID in .env."
fi
