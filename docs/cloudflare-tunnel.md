# Cloudflare Tunnel

This project uses a locally managed Cloudflare Tunnel credentials JSON file.

The credentials file is expected at:

```text
config/cloudflared/credentials.json
```

That file is ignored by Git because it is a secret.

## One-time setup

1. Copy `.env.EXAMPLE` to `.env`.
2. Edit `DOMAIN`, hostnames, `PUID`, `PGID`, and paths.
3. Authenticate Cloudflare CLI:

```bash
cloudflared tunnel login
```

4. Create the tunnel and credentials JSON:

```bash
./scripts/cloudflare-tunnel-create.sh
```

5. Create Cloudflare DNS routes:

```bash
./scripts/cloudflare-dns-route.sh
```

The tunnel ingress forwards all HTTP traffic to Traefik. Traefik then routes by hostname to the correct container.
