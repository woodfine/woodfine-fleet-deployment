---
schema: foundry-doc-v1
title: "Software Distribution Operations"
slug: guide-software-distribution-operations
short_description: "Operational guide for vault-privategit-source-1: service management, catalog updates, binary publishing, payment flow, and wallet configuration for software.pointsav.com."
category: vault-privategit-source
type: guide
status: active
bcsc_class: public-disclosure-safe
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Software Distribution Operations

Operational guide for `vault-privategit-source-1` — the deployment instance running `software.pointsav.com`. Covers day-to-day service management, catalog updates, binary publishing, wallet configuration, and recovery procedures.

---

## Prerequisites

- SSH access to the workspace VM as a member of the `foundry` group.
- `sudo` rights on the host for service control and systemd operations.
- Familiarity with `systemctl`, `journalctl`, and `curl`.
- Polygon PoS wallet seed provisioned at the path set in `WALLET_SEED_PATH` (operator-generated; never in git, never AI-visible).

---

## Deployment overview

```
software.pointsav.com  (TLS — certbot managed)
        │
        ├── /releases/*  ──→  local-software-source  (port 9201)
        ├── /git/*       ──→  local-software-source  (port 9201)
        └── /*           ──→  local-software-marketplace  (port 9202)

local-software-wallet  (no inbound port — Polygon RPC polling only)
```

| Unit | Binary | Port | Role |
|---|---|---|---|
| `local-software-marketplace` | `/usr/local/bin/app-privategit-marketplace` | 9202 | Storefront — catalog, payment verification, license issuance |
| `local-software-source` | `/usr/local/bin/app-privategit-source` | 9201 | Binary server — signed release downloads, MANIFEST endpoints |
| `local-software-wallet` | `/usr/local/bin/tool-wallet` | — | Polygon PoS USDC watcher — writes receipts on confirmed transfers |

System account: `local-software` (no login shell, no home directory).
State root: `/var/lib/local-software/`.

---

## Routine verification

Run after any change or at the start of a maintenance window.

```bash
# Service status
systemctl status local-software-marketplace local-software-source local-software-wallet

# Health endpoints (both should return {"status":"ok"})
curl -s https://software.pointsav.com/healthz
curl -s http://127.0.0.1:9201/healthz

# Catalog responds
curl -s https://software.pointsav.com/v1/products | python3 -m json.tool | head -20

# Payment address present
curl -s https://software.pointsav.com/v1/wallet/address
```

---

## Service management

```bash
# Restart a service
sudo systemctl restart local-software-marketplace
sudo systemctl restart local-software-source
sudo systemctl restart local-software-wallet

# Stop / start
sudo systemctl stop  local-software-wallet
sudo systemctl start local-software-wallet

# Tail live logs
journalctl -u local-software-marketplace -f
journalctl -u local-software-source -f
journalctl -u local-software-wallet -f

# Last 100 lines
journalctl -u local-software-marketplace -n 100 --no-pager
```

---

## Catalog management

The product catalog lives at `/var/lib/local-software/catalog/products.yaml`. The marketplace loads it on every request — no service restart is required after editing.

```bash
# Edit catalog
sudo -u local-software nano /var/lib/local-software/catalog/products.yaml

# Validate YAML syntax before saving
python3 -c "import yaml, sys; yaml.safe_load(open(sys.argv[1]))" \
    /var/lib/local-software/catalog/products.yaml && echo "OK"

# Verify the change is live
curl -s https://software.pointsav.com/v1/products | python3 -m json.tool | grep '"name"'
```

### Catalog structure

Two top-level keys: `installers` (free OS images) and `licenses` (paid software modules).

```yaml
installers:
  - id: <machine-readable-id>        # used in /releases/<id>/<version>/ path
    name: <display name>
    description: <one-line description>
    edition: "YYYY.MM.NNN"
    platform: "<platform string>"
    size_mb: <integer>
    path: <id>/<version>             # relative path under /var/lib/local-software/releases/

licenses:
  - id: <machine-readable-id>
    name: <display name>
    description: <one-line description>
    module_tag: <crate or service name>
    price_usdc: <integer USDC — NOT micro-units>
```

The `price_usdc` field is in whole USDC (e.g., `180` = $180 USDC). The marketplace matches incoming payment amounts against this field to identify which product was purchased. Prices must be unique across all license entries; duplicate prices create ambiguous product identification.

---

## Binary publishing

Binaries are served by `local-software-source` from the releases directory tree.

```
/var/lib/local-software/releases/
└── <product-id>/
    └── <version>/
        ├── <binary-file>      (platform-specific; filename is arbitrary)
        └── MANIFEST.json      (required — served at /releases/<id>/<version>/MANIFEST)
```

### Adding a release

```bash
# Create the version directory
sudo -u local-software mkdir -p \
    /var/lib/local-software/releases/<product-id>/<version>

# Copy binary
sudo cp /path/to/binary /var/lib/local-software/releases/<product-id>/<version>/
sudo chown local-software:local-software \
    /var/lib/local-software/releases/<product-id>/<version>/<binary>

# Write MANIFEST.json
sudo -u local-software tee \
    /var/lib/local-software/releases/<product-id>/<version>/MANIFEST.json << 'EOF'
{
  "product": "<product-id>",
  "version": "<version>",
  "platform": "<linux-x86_64 | darwin-arm64 | windows-x86_64>",
  "built_at": "YYYY-MM-DD",
  "size_bytes": <integer>,
  "sha256": "<hex digest>"
}
EOF

# Verify the endpoint responds
curl -s https://software.pointsav.com/releases/<product-id>/<version>/MANIFEST
```

No service restart required. `local-software-source` reads the filesystem on each request.

---

## Payment and license flow

The purchase flow across the three services:

```
1. Customer visits software.pointsav.com/licensing
2. Marketplace serves payment address via GET /v1/wallet/address
3. Customer sends USDC on Polygon PoS to that address
4. tool-wallet (watch subcommand) polls eth_getLogs for Transfer events
5. On 1-block confirmation: tool-wallet writes receipt to
       /var/lib/local-software/receipts/<YYYY>/<MM>/<tx_hash>.json
   and attempts to POST to service-fs at RECEIPTS_DIR
6. Customer provides tx_hash to GET /v1/license/:tx_hash
7. Marketplace finds receipt → returns license_key (deterministic SHA-256 hash
   of product_id + tx_hash + customer_ref; reproducible on re-query)
```

### Verifying a specific transaction

```bash
# Check whether a tx_hash has a receipt on disk
ls /var/lib/local-software/receipts/$(date +%Y)/$(date +%m)/<tx_hash>.json

# Query the license endpoint directly
curl -s "https://software.pointsav.com/v1/license/<tx_hash>" | python3 -m json.tool

# Manually invoke tool-wallet check (diagnostic)
tool-wallet check <tx_hash> \
    --rpc-url https://polygon-rpc.com \
    --wallet-address <POLYGON_WALLET_ADDRESS>
```

Response codes from `/v1/license/:tx_hash`:

| HTTP | `status` field | Meaning |
|---|---|---|
| 200 | `confirmed` | Receipt on disk or tx confirmed on-chain; `license_key` present |
| 202 | `pending` | Tx found on-chain but not yet confirmed (retry in 30 s) |
| 404 | `not_found` | Tx hash unknown or not a USDC transfer to this address |

---

## Wallet configuration

`local-software-wallet` is installed and enabled but requires operator-provisioned secrets before it can be started.

```bash
# Edit the secrets drop-in
sudo nano /etc/systemd/system/local-software-wallet.service.d/wallet.conf
```

Populate the three required values:

```ini
[Service]
Environment="POLYGON_RPC_URL=https://polygon-rpc.com"
Environment="POLYGON_WALLET_ADDRESS=0x<your-address>"
Environment="WALLET_SEED_PATH=/etc/local-software/wallet.seed"
```

Store the seed file:

```bash
sudo install -o root -g local-software -m 640 \
    /path/to/wallet.seed /etc/local-software/wallet.seed
```

Then reload and start:

```bash
sudo systemctl daemon-reload
sudo systemctl start local-software-wallet
journalctl -u local-software-wallet -n 20 --no-pager
# Expect: "tool-wallet watching Polygon PoS for transfers to 0x..."
```

Do not commit the seed file or wallet address to git. Do not log or print the seed.

---

## TLS certificate

TLS is managed by certbot. The certificate auto-renews via the system certbot timer.

```bash
# Check renewal timer
systemctl status certbot.timer

# Test renewal without applying
sudo certbot renew --dry-run

# Manual renewal (if timer is disabled)
sudo certbot renew

# Verify certificate expiry
echo | openssl s_client -connect software.pointsav.com:443 2>/dev/null \
    | openssl x509 -noout -dates
```

After renewal, nginx reloads automatically via the certbot deploy hook.

---

## Environment variables reference

### local-software-marketplace

| Variable | Default | Description |
|---|---|---|
| `MARKETPLACE_BIND` | `127.0.0.1:9202` | Listen address |
| `POLYGON_WALLET_ADDRESS` | _(empty)_ | PointSav receiving wallet; injected by wallet.conf drop-in |
| `POLYGON_RPC_URL` | `https://polygon-rpc.com` | Polygon JSON-RPC for on-chain checks |
| `CATALOG_PATH` | `/var/lib/local-software/catalog/products.yaml` | Product catalog |
| `RECEIPTS_DIR` | `/var/lib/local-software/receipts` | Receipt storage root |
| `CLAIMS_DIR` | `/var/lib/local-software/claims` | Claim token storage |
| `SOURCE_BASE_URL` | `https://software.pointsav.com/releases` | Base URL for download links in catalog API |
| `FS_ENDPOINT` | `http://127.0.0.1:8020` | service-fs endpoint (receipt forwarding; non-critical fallback) |
| `RUST_LOG` | `info` | Log level (`debug`, `info`, `warn`, `error`) |

### local-software-source

| Variable | Default | Description |
|---|---|---|
| `SOURCE_BIND` | `127.0.0.1:9201` | Listen address |
| `RELEASES_DIR` | `/var/lib/local-software/releases` | Binary release tree root |
| `RUST_LOG` | `info` | Log level |

### local-software-wallet (tool-wallet)

| Variable | Required | Description |
|---|---|---|
| `POLYGON_RPC_URL` | Yes | Polygon JSON-RPC URL |
| `POLYGON_WALLET_ADDRESS` | Yes | Receiving wallet address |
| `WALLET_SEED_PATH` | Yes | Path to BIP-39 seed file (operator-provisioned, 0640) |
| `FS_ENDPOINT` | No | service-fs endpoint for receipt posting |
| `RUST_LOG` | No | Log level |

---

## Bootstrap (reprovisioning)

If the deployment instance must be rebuilt from scratch:

```bash
# 1. Build binaries (run from the app-privategit-marketplace subdirectory)
cargo build --release -p app-privategit-marketplace -p app-privategit-source -p tool-wallet

# 2. Run bootstrap
sudo /srv/foundry/infrastructure/local-software/bootstrap.sh

# 3. Provision wallet secrets (see Wallet configuration above)

# 4. Start services
sudo systemctl start local-software-marketplace local-software-source
sudo systemctl start local-software-wallet   # only after wallet.conf is populated

# 5. Verify
curl -s http://127.0.0.1:9202/healthz
curl -s http://127.0.0.1:9201/healthz

# 6. DNS must resolve software.pointsav.com → 34.53.65.203 before certbot
sudo certbot --nginx -d software.pointsav.com
```

---

## State directory layout

```
/var/lib/local-software/
├── catalog/
│   └── products.yaml          ← product catalog (editable; loaded per-request)
├── releases/
│   └── <product-id>/
│       └── <version>/
│           ├── <binary>       ← compiled binary (platform-specific)
│           └── MANIFEST.json  ← required metadata
├── receipts/
│   └── <YYYY>/
│       └── <MM>/
│           └── <tx_hash>.json ← LicenseReceipt written by tool-wallet on confirmation
├── claims/
│   └── <wallet-address>/
│       └── <binary_sha256_prefix>.json  ← claim tokens (on-chain mint is planned for a future release)
└── state/                     ← reserved; not currently written
```

---

*Copyright © 2026 PointSav Digital Systems. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
