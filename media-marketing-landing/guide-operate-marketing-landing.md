---
schema: foundry-doc-v1
title: "Operating the Marketing Landing Service"
slug: guide-operate-marketing-landing
type: guide
status: active
bcsc_class: customer-internal
last_edited: 2026-05-07
editor: pointsav-engineering
---

## Prerequisites

- `sudo` access on the foundry-workspace VM.
- `app-mediakit-marketing` binary deployed at `/opt/foundry/bin/app-mediakit-marketing`.
- systemd units `local-marketing-woodfine.service` and `local-marketing-pointsav.service`
  installed.
- nginx configured with vhosts for `home.woodfinegroup.com` and `home.pointsav.com`.

## Purpose

This guide covers day-to-day operation of the `app-mediakit-marketing` service for both
the Woodfine tenant (`media-marketing-landing-1`) and the PointSav tenant
(`media-marketing-landing-2`). Both tenants share the same binary and operational
procedures; commands below apply to both unless one tenant is specified.

**Service summary:**

| Item | Woodfine | PointSav |
|---|---|---|
| systemd unit | `local-marketing-woodfine.service` | `local-marketing-pointsav.service` |
| Bind address | `127.0.0.1:9102` | `127.0.0.1:9101` |
| Domain | `home.woodfinegroup.com` | `home.pointsav.com` |
| Health endpoint | `http://127.0.0.1:9102/healthz` | `http://127.0.0.1:9101/healthz` |

## Procedure

### Health check

```bash
curl http://127.0.0.1:9102/healthz   # Woodfine
curl http://127.0.0.1:9101/healthz   # PointSav
```

Both return `{"status":"ok"}` when running. Run the workspace health script to check all
foundry services at once:

```bash
/srv/foundry/bin/foundry-health.sh
```

### Start, stop, restart

```bash
# Start both tenants
sudo systemctl start local-marketing-woodfine.service
sudo systemctl start local-marketing-pointsav.service

# Stop both tenants
sudo systemctl stop local-marketing-woodfine.service
sudo systemctl stop local-marketing-pointsav.service

# Restart a single tenant
sudo systemctl restart local-marketing-woodfine.service

# Check status
sudo systemctl status local-marketing-woodfine.service
sudo systemctl status local-marketing-pointsav.service
```

### Enable at boot

```bash
sudo systemctl enable local-marketing-woodfine.service
sudo systemctl enable local-marketing-pointsav.service
```

### Inspect environment variables

Both services share the same variable names, set to tenant-specific values in their
respective systemd units:

| Variable | Purpose |
|---|---|
| `SERVICE_MARKETING_BIND` | TCP bind address (`127.0.0.1:9102` or `127.0.0.1:9101`) |
| `SERVICE_MARKETING_CONTENT_DIR` | Flat-file content directory path |
| `SERVICE_MARKETING_TENANT_ID` | Tenant identifier (`woodfine` or `pointsav`) |
| `SERVICE_MARKETING_LOG_LEVEL` | Log verbosity (`info`, `debug`) |

```bash
systemctl show local-marketing-woodfine.service | grep Environment
systemctl show local-marketing-pointsav.service | grep Environment
```

### Log inspection

```bash
# Live logs
sudo journalctl -u local-marketing-woodfine.service -f
sudo journalctl -u local-marketing-pointsav.service -f

# Recent errors
sudo journalctl -u local-marketing-woodfine.service --since "1 hour ago" | grep -i error
```

### nginx

nginx vhosts proxy HTTPS traffic to the local service ports:

- `home.woodfinegroup.com` → `127.0.0.1:9102`
- `home.pointsav.com` → `127.0.0.1:9101`

```bash
sudo nginx -t && sudo systemctl reload nginx
```

### DNS and TLS

Both domains require a DNS A record pointing to the VM's public IP and a TLS certificate:

```bash
sudo certbot --nginx -d home.woodfinegroup.com -d home.pointsav.com \
    --non-interactive --agree-tos -m open.source@pointsav.com --redirect
```

DNS A records are a pending operator action; do not run certbot until DNS resolves to
the VM IP.

### Bootstrap (fresh install)

The bootstrap script installs the binary, writes systemd units, configures nginx vhosts,
and starts both services. It is idempotent — safe to re-run on an already-configured
system:

```bash
sudo /srv/foundry/infrastructure/local-marketing/bootstrap.sh
```

### Updating the binary

After a new release binary is built:

```bash
# Build from source (from monorepo working directory)
cargo build --release -p app-mediakit-marketing

# Install and restart via bootstrap (idempotent)
sudo /srv/foundry/infrastructure/local-marketing/bootstrap.sh
```

## Expected Outcome

Both services respond `{"status":"ok"}` at their health endpoints. nginx forwards
external HTTPS traffic to each tenant on the correct port. The `foundry-health.sh`
script reports both marketing tenants as healthy.

## Verification

```bash
# Health endpoints
curl -s http://127.0.0.1:9102/healthz | grep ok
curl -s http://127.0.0.1:9101/healthz | grep ok

# Public endpoints (after DNS + TLS)
curl -s https://home.woodfinegroup.com/ -o /dev/null -w "%{http_code}"
curl -s https://home.pointsav.com/ -o /dev/null -w "%{http_code}"
# Expected: 200 for both
```

## Rollback

```bash
sudo systemctl stop local-marketing-woodfine.service
sudo systemctl stop local-marketing-pointsav.service
sudo systemctl disable local-marketing-woodfine.service
sudo systemctl disable local-marketing-pointsav.service
```

To remove the nginx vhosts, delete `/etc/nginx/sites-enabled/home.woodfinegroup.com`
and `/etc/nginx/sites-enabled/home.pointsav.com`, then reload nginx.
