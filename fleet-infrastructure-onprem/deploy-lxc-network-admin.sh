#!/usr/bin/env bash
set -euo pipefail

echo "========================================================"
echo " 🚀 IGNITING LXC DEPLOYMENT: SOVEREIGN NETWORK LEDGER"
echo "========================================================"

CONTAINER_NAME="pointsav-network-ledger"
MONOREPO_ROOT="/home/mathew/Foundry/factory-pointsav/pointsav-monorepo"

# 1. Verify UI Artifacts Exist
if [ ! -d "$MONOREPO_ROOT/os-network-admin/public" ]; then
    echo "[FATAL] Network Ledger UI payloads not found in Monorepo. Run the UI forge script first."
    exit 1
fi

echo "[SYSTEM] 1. Initializing LXC Container ($CONTAINER_NAME) on Laptop A..."
# Check if container exists, if not, launch it
if ! lxc info "$CONTAINER_NAME" >/dev/null 2>&1; then
    lxc launch ubuntu:22.04 "$CONTAINER_NAME"
    echo "[SYSTEM] Allowing container OS to boot..."
    sleep 10
else
    echo "[SKIP] Container $CONTAINER_NAME already exists."
fi

echo "[SYSTEM] 2. Provisioning Container Substrate (NGINX)..."
lxc exec "$CONTAINER_NAME" -- apt-get update -yqq
lxc exec "$CONTAINER_NAME" -- apt-get install -yqq nginx

echo "[SYSTEM] 3. Injecting Cryptographic & UI Payloads..."
# Clear default NGINX files
lxc exec "$CONTAINER_NAME" -- rm -rf /var/www/html/*

# Push Chassis
lxc file push -r "$MONOREPO_ROOT/os-network-admin/public/"* "$CONTAINER_NAME/var/www/html/"

# Push F-Key Cartridges
lxc file push -r "$MONOREPO_ROOT/app-network-keys" "$CONTAINER_NAME/var/www/"
lxc file push -r "$MONOREPO_ROOT/app-network-help" "$CONTAINER_NAME/var/www/"
lxc file push -r "$MONOREPO_ROOT/app-network-infrastructure" "$CONTAINER_NAME/var/www/"
lxc file push -r "$MONOREPO_ROOT/app-network-cluster" "$CONTAINER_NAME/var/www/"
lxc file push -r "$MONOREPO_ROOT/app-network-gateway" "$CONTAINER_NAME/var/www/"
lxc file push -r "$MONOREPO_ROOT/app-network-media" "$CONTAINER_NAME/var/www/"
lxc file push -r "$MONOREPO_ROOT/app-network-vault" "$CONTAINER_NAME/var/www/"
lxc file push -r "$MONOREPO_ROOT/app-network-radar" "$CONTAINER_NAME/var/www/"

echo "[SYSTEM] 4. Aligning Container Permissions..."
lxc exec "$CONTAINER_NAME" -- chown -R www-data:www-data /var/www/

echo "[SYSTEM] 5. Reigniting Web Engine..."
lxc exec "$CONTAINER_NAME" -- systemctl restart nginx

# Retrieve the assigned local IP for the proxy
LXC_IP=$(lxc list "$CONTAINER_NAME" -c 4 --format csv | awk '{print $1}')

echo "========================================================"
echo "[SUCCESS] Network Ledger LXC is LIVE at http://$LXC_IP"
echo "[DIRECTIVE] Ensure the GCP reverse proxy points network.woodfinegroup.com to Laptop A (10.50.0.2) port 80/443."
echo "========================================================"
