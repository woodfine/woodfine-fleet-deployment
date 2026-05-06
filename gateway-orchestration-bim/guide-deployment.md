# Deployment Guide — gateway-orchestration-bim

Covers the operation of the BIM workflow gateway serving `bim.woodfinegroup.com`. The active deployment instance is `gateway-orchestration-bim-1`.

## Stack composition

- `app-orchestration-bim` binary (compiled from `pointsav-monorepo/app-orchestration-bim/`)
- BIM data sources (per-property archive content)
- nginx vhost terminating TLS via Let's Encrypt
- systemd unit serving on the allocated 909x port (see deployment instance MANIFEST)

## Bring-up sequence

1. Install binary at `/usr/local/bin/app-orchestration-bim` (Master scope; operator-presence sudo).
2. Create `local-orchestration-bim.service` systemd unit pointing at `~/Foundry/deployments/gateway-orchestration-bim-1/`.
3. Configure nginx vhost for `bim.woodfinegroup.com` reverse-proxying to the allocated local port.
4. Issue Let's Encrypt cert via certbot.
5. Smoke test: `curl https://bim.woodfinegroup.com/healthz`.

This catalog is leg-pending (status: scaffold-coded). Master will ship the systemd unit + nginx vhost when project-bim Task signals v0.0.1 ready.

## Per-property archive integration

The BIM gateway reads from per-property archives in `cluster-totebox-property-1/`. Cross-references between BIM data and property data flow through the service-content graph (see `conventions/datagraph-access-discipline.md`).

## When this cluster scales beyond the shared host

Per `conventions/publishing-tier-architecture.md` per-site VM graduation: provision a dedicated VM, rsync the deployment instance folder, swap DNS. Path on the new VM stays `~/deployments/gateway-orchestration-bim-1/` for clean lift.

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
