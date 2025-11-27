#!/usr/bin/env bash

# Simple status script: shows docker service status and external HDD status (sizes, usage, device info)

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${GREEN}Home Server — Status Report${NC}"
echo "Generated: $(date)"
echo

### Docker / Services status
echo -e "${YELLOW}Docker & Services:${NC}"

# Check docker daemon
if ! command -v docker >/dev/null 2>&1; then
	echo -e "${RED}Docker not found in PATH. Install Docker or ensure it's available.${NC}"
else
	if ! docker info >/dev/null 2>&1; then
		echo -e "${RED}Docker daemon not running or not accessible by this user.${NC}"
		echo "Try: open Docker.app or run the docker daemon, then re-run this script."
	else
		echo -e "${GREEN}Docker daemon: available${NC}"
		echo ""

		echo "Running containers (docker ps):"
		docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' || true
		echo ""

		# Prefer `docker compose` plugin, fallback to `docker-compose`
		COMPOSE_CMD=""
		if docker compose version >/dev/null 2>&1; then
			COMPOSE_CMD=(docker compose)
		elif command -v docker-compose >/dev/null 2>&1; then
			COMPOSE_CMD=(docker-compose)
		fi

		if [ -n "${COMPOSE_CMD[*]:-}" ]; then
			if [ -f "$REPO_ROOT/docker-compose.yml" ]; then
				echo "docker-compose services (from $REPO_ROOT/docker-compose.yml):"
				"${COMPOSE_CMD[@]}" -f "$REPO_ROOT/docker-compose.yml" ps || true
			else
				echo "No docker-compose.yml found at $REPO_ROOT/docker-compose.yml"
			fi
		else
			echo -e "${YELLOW}No docker-compose command available (tried 'docker compose' and 'docker-compose').${NC}"
		fi
	fi
fi

echo
### HDD status (mounted volumes and external disks)
echo -e "${YELLOW}HDD / Volume Status:${NC}"

# Show root disk usage
echo "Root filesystem usage:"
df -h / || true
echo ""

# macOS: detect external mounts by parsing 'mount' and asking diskutil about the device
external_mounts=()

if command -v diskutil >/dev/null 2>&1; then
	while IFS= read -r line; do
		# mount output: DEVICE on MOUNTPOINT (opts)
		device=$(awk '{print $1}' <<< "$line")
		mpoint=$(awk '{print $3}' <<< "$line")
		# Only consider /Volumes/ mounts (typical for external drives on macOS)
		if [[ "$mpoint" == /Volumes/* ]]; then
			info=$(diskutil info "$device" 2>/dev/null || true)
			# Check for 'Internal: No' or 'Device Location: External'
			if echo "$info" | grep -Eq "Internal:\s*No|Device Location:\s*External"; then
				external_mounts+=("$mpoint")
			fi
		fi
	done < <(mount)
fi

# Unique mount points
if [ ${#external_mounts[@]} -eq 0 ]; then
	echo "No external volumes detected (via /Volumes mounts)."
else
	# remove duplicates
	mapfile -t unique_mounts < <(printf '%s\n' "${external_mounts[@]}" | awk '!seen[$0]++')
	echo "Detected external volume(s):"
	for m in "${unique_mounts[@]}"; do
		echo "- $m"
	done
	echo ""

	for m in "${unique_mounts[@]}"; do
		echo -e "${GREEN}Volume: $m${NC}"
		echo "Disk usage (df -h):"
		df -h "$m" || true
		echo ""
		echo "Device info (diskutil info):"
		# Try device first (find device for mount via df)
		devnode=$(df "$m" | awk 'NR==2{print $1}') || devnode=""
		if [ -n "$devnode" ]; then
			diskutil info "$devnode" 2>/dev/null || diskutil info "$m" 2>/dev/null || true
		else
			diskutil info "$m" 2>/dev/null || true
		fi
		echo ""
	done
fi

echo
echo -e "${YELLOW}Service Health:${NC}"
if [ -n "${COMPOSE_CMD[*]:-}" ]; then
    # Show container health status
    docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -E 'plex|qbittorrent|cloudflared'
fi

echo
echo -e "${YELLOW}Recent Logs (last 10 lines per service):${NC}"
for service in plex qbittorrent cloudflared; do
    echo ""
    echo -e "${GREEN}=== $service ===${NC}"
    docker logs --tail 10 "$service" 2>&1 || echo "Container not running"
done

echo
echo -e "${GREEN}Status report complete.${NC}"

exit 0

