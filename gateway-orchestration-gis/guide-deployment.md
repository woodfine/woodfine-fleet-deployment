---
schema: foundry-doc-v1
title: "Deployment — gateway-orchestration-gis"
slug: guide-deployment
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-08
editor: pointsav-engineering
---

# Deployment Guide — gateway-orchestration-gis

Covers the operation of the GIS workflow gateway serving `gis.woodfinegroup.com`. The active deployment instance is `gateway-orchestration-gis-1` on the workspace VM (or eventually the publishing VM per `conventions/publishing-tier-architecture.md`).

## Stack composition

- `app-orchestration-gis` binary (compiled from `pointsav-monorepo/app-orchestration-gis/`)
- `service-places` upstream pipeline (cluster-pipeline output: layer1/layer2/layer3 PMTiles)
- nginx vhost terminating TLS via Let's Encrypt
- systemd unit serving on `127.0.0.1:9094` (or current allocated port — see deployment instance MANIFEST)

## Bring-up sequence

1. Install binary at `/usr/local/bin/app-orchestration-gis` (Master scope; operator-presence sudo).
2. Create `local-orchestration-gis.service` systemd unit pointing at `~/Foundry/deployments/gateway-orchestration-gis-1/`.
3. Configure nginx vhost for `gis.woodfinegroup.com` reverse-proxying to `127.0.0.1:9094`.
4. Issue Let's Encrypt cert via certbot.
5. Smoke test: `curl https://gis.woodfinegroup.com/healthz`.

Per-instance config (data paths, port, module_id) lives in the deployment instance MANIFEST at `~/Foundry/deployments/gateway-orchestration-gis-1/MANIFEST.md`.

## Operational notes

- service-places pipeline rebuilds layer tiles via `build-tiles.py`. Output sizes: layer2 ~23 MB, layer3 ~98 MB.
- Boundary download requires `gdal-bin` (`ogr2ogr`) for US Census SHP processing. EU NUTS-3 + fallback can be direct GeoJSON.
- Monitoring: nginx access log + service-orchestration-gis stdout journal.

## When this cluster scales beyond the shared host

Per `conventions/publishing-tier-architecture.md` per-site VM graduation: provision a dedicated VM, rsync the deployment instance folder, swap DNS. Path on the new VM stays `~/deployments/gateway-orchestration-gis-1/` for clean lift.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
