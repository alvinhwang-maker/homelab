#!/bin/bash
# Usage: ./deploy.sh <app-name>
set -e

APP=$1
APPS_DIR=/srv/apps
REGISTRY="$(dirname "$0")/registry.yaml"

if [ -z "$APP" ]; then
  echo "Usage: $0 <app-name>"
  exit 1
fi

# Check app exists in registry
REPO=$(yq ".apps[] | select(.name == \"$APP\") | .repo" "$REGISTRY")
if [ -z "$REPO" ]; then
  echo "Error: '$APP' not found in registry.yaml"
  exit 1
fi

# Clone on first deploy, pull on update
if [ -d "$APPS_DIR/$APP" ]; then
  echo "==> Pulling latest for $APP..."
  git -C "$APPS_DIR/$APP" pull
else
  echo "==> Cloning $APP..."
  git clone "$REPO" "$APPS_DIR/$APP"
fi

# Build and start (Traefik picks it up automatically)
echo "==> Building and starting $APP..."
docker compose -f "$APPS_DIR/$APP/docker-compose.yml" up -d --build

# Stamp registry with deploy time
yq -i "(.apps[] | select(.name == \"$APP\") | .deployed_at) = \"$(date -I)\"" "$REGISTRY"
yq -i "(.apps[] | select(.name == \"$APP\") | .status) = \"active\"" "$REGISTRY"

echo "✓ $APP deployed"
