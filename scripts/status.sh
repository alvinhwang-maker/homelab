#!/bin/bash
# Show what's running on the homelab.
set -e

REGISTRY="$(dirname "$0")/../registry.yaml"

echo "=== Homelab Status ==="
echo ""

echo "--- Registered Apps ---"
yq '.apps[] | "  " + .name + " (" + .status + ")  →  " + .route' "$REGISTRY"

echo ""
echo "--- Running Containers ---"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "--- Traefik Dashboard ---"
echo "  http://$(hostname -I | awk '{print $1}'):8080"
