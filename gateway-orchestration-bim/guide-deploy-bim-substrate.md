---
schema: foundry-doc-v1
title: "Deploying the BIM Token Substrate"
slug: guide-deploy-bim-substrate
type: guide
status: active
bcsc_class: customer-internal
last_edited: 2026-05-07
editor: pointsav-engineering
---

## Prerequisites

- GitHub account with write access to the `woodfine` org (`mcorp-administrator` identity).
- Git configured with the `mcorp-administrator` SSH key.
- Deployment host with `sudo` access, `systemd`, `nginx`, and `certbot` installed.
- Rust toolchain and compiled `app-orchestration-bim` binary at `/opt/foundry/bin/`.
- DNS management access for `woodfinegroup.com`.

## Purpose

This guide covers provisioning the `woodfine-design-bim` sovereign token vault and
deploying `app-orchestration-bim` to serve it publicly at `bim.woodfinegroup.com`.

All paths that reference the GitHub repository root use
`pointsav-monorepo/infrastructure/` conventions. Deployment-host paths are absolute.

## Procedure

### Part 1 — Provision the Token Vault

The BIM token vault is a GitHub repository in the `woodfine` org. It holds all DTCG
token files, regulatory overlays, and climate zone data for the deployment.

1. Create the repository on GitHub (one-time, Master action via `mcorp-administrator`):
   - Repository: `woodfine/woodfine-design-bim`
   - Visibility: Private
   - License: EUPL-1.2

2. Clone to the deployment host:
   ```bash
   git clone git@github.com-mcorp:woodfine/woodfine-design-bim.git \
       /opt/foundry/vaults/woodfine-design-bim
   ```

3. Verify the token directory is populated:
   ```bash
   ls /opt/foundry/vaults/woodfine-design-bim/tokens/bim/
   # Expected: spatial.dtcg.json  elements.dtcg.json  systems.dtcg.json
   #           materials.dtcg.json  assemblies.dtcg.json  performance.dtcg.json
   #           identity-codes.dtcg.json  relationships.dtcg.json  climate-zones.dtcg.json
   ```

### Part 2 — Configure app-orchestration-bim

`app-orchestration-bim` reads its token vault path from an environment variable at
startup.

The systemd unit file is at:
```text
pointsav-monorepo/infrastructure/app-orchestration-bim.service
```

Set the environment variable in the unit's `[Service]` section:

```ini
[Service]
Environment=BIM_DESIGN_SYSTEM_DIR=/opt/foundry/vaults/woodfine-design-bim
Environment=PORT=9096
ExecStart=/opt/foundry/bin/app-orchestration-bim
User=foundry
Restart=on-failure
```

Deploy and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable app-orchestration-bim
sudo systemctl start app-orchestration-bim
```

Verify the service is running:

```bash
systemctl status app-orchestration-bim
curl http://127.0.0.1:9096/readyz
# Expected: {"status":"ok"}
```

### Part 3 — nginx Vhost

`app-orchestration-bim` listens on `127.0.0.1:9096`. nginx proxies public traffic
to it.

Create `/etc/nginx/sites-available/bim.woodfinegroup.com`:

```nginx
server {
    listen 80;
    server_name bim.woodfinegroup.com;

    location / {
        proxy_pass http://127.0.0.1:9096;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/bim.woodfinegroup.com \
           /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Part 4 — TLS via Certbot

```bash
sudo certbot --nginx -d bim.woodfinegroup.com \
    --non-interactive --agree-tos \
    --email open.source@pointsav.com
sudo nginx -t && sudo systemctl reload nginx
```

Certbot auto-renewal is configured by the certbot systemd timer. Verify:

```bash
systemctl status certbot.timer
```

### Part 5 — DNS

The `bim.woodfinegroup.com` DNS A record must point to the deployment host's public IP.
This is a Master-scope operation using the DNS management console for `woodfinegroup.com`.

```bash
dig +short bim.woodfinegroup.com
# Expected: <public-IP-of-deployment-host>
```

## Expected Outcome

`bim.woodfinegroup.com` returns HTTP 200 with TLS active. The token catalog loads. The
machine surface endpoint returns valid JSON. After all smoke tests pass, update
`woodfine-fleet-deployment/gateway-orchestration-bim/MANIFEST.md`:

```yaml
deployments:
  - id: gateway-orchestration-bim-1
    status: active
    url: https://bim.woodfinegroup.com
    smoke_check: pass
    smoke_check_date: <YYYY-MM-DD>
```

## Verification

Run all four smoke tests after DNS resolves and TLS is active:

```bash
# 1. Health check
curl -s https://bim.woodfinegroup.com/readyz
# Expected: {"status":"ok"}

# 2. Token catalog loads
curl -s https://bim.woodfinegroup.com/tokens | grep -c "bim-token-card"
# Expected: 8 (one per token category)

# 3. Machine surface
curl -s https://bim.woodfinegroup.com/tokens.json | jq '.["elements.IfcWall"] | .ifc_class'
# Expected: "IfcWall"

# 4. API endpoint
curl -s https://bim.woodfinegroup.com/api/climate-zones | jq 'keys | length'
# Expected: number of registered climate zone tokens
```

## Rollback

To stop the service and remove the public endpoint:

```bash
sudo systemctl stop app-orchestration-bim
sudo systemctl disable app-orchestration-bim
sudo rm /etc/nginx/sites-enabled/bim.woodfinegroup.com
sudo systemctl reload nginx
```

DNS record removal is a Master-scope operation via the DNS management console.

Note: Verify the `app-orchestration-bim` binary path (`/opt/foundry/bin/`) against the
actual deployment host layout before first deploy. Update the systemd unit file if the
path differs.
