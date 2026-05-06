# Provision Node Guide — Marketing Landing Site (Woodfine tenant)

VM-level prerequisites for hosting the Woodfine marketing landing site.

## VM specification (Tier 0 compatible)

- e2-small or larger (1 vCPU, 1-2 GB RAM minimum)
- 30 GB pd-balanced disk (binary + content + media uploads)
- us-west1-a (current foundry-workspace zone) or operator-chosen region
- nginx + certbot installed at provision time

## System dependencies

- `nginx` for TLS termination + reverse proxy
- `certbot` for Let's Encrypt automation
- No database server required (flat-file content)
- No PHP, no Node.js, no Python runtime — Rust binary self-contained

## Pre-flight checks

- DNS A record `home.woodfinegroup.com` resolves to the VM's public IP
- Firewall allows inbound 80/443 from operator-permitted CIDRs
- service-content endpoint reachable (`http://127.0.0.1:9081` if same-host; or workspace-Doorman if cross-host)

## Bring-up smoke test

After bring-up per `guide-deployment-marketing-site.md`:

```bash
curl -fsS https://home.woodfinegroup.com/healthz
curl -fsS https://home.woodfinegroup.com/  # should return the marketing home page
curl -fsS https://home.woodfinegroup.com/wp-admin  # should return the dashboard
```

## Multi-tenant note

The same `app-mediakit-marketing` binary runs both `media-marketing-landing-1` (Woodfine; this catalog) and `media-marketing-landing-2` (PointSav; vendor catalog). Tenant is selected by `SERVICE_MARKETING_MODULE_ID` env var. Two systemd units on the same VM, two nginx vhosts, two content dirs.

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
