#!/bin/bash
# One-time server bootstrap. Run this once on a fresh server.
set -e

echo "==> Creating shared Docker network..."
docker network create web 2>/dev/null || echo "Network 'web' already exists, skipping."

echo "==> Starting Traefik..."
docker compose -f "$(dirname "$0")/docker-compose.yml" up -d

echo "==> Done. Traefik is running."
echo "    Dashboard: http://<tailscale-ip>:8080"
