# Provision Node Guide — gateway-orchestration-gis

VM-level prerequisites for hosting the GIS workflow gateway.

## VM specification

- e2-small or larger (1 vCPU, 2 GB RAM minimum)
- 30 GB pd-balanced disk (PMTiles layers + binary + working data)
- us-west1-a (current foundry-workspace zone) or operator-chosen region
- nginx + certbot installed at provision time

## System dependencies

- `gdal-bin` for `ogr2ogr` (boundary file processing)
- `python3` + project-pipeline scripts (ingest-osm-civic.py, ingest-overture.py, build-tiles.py)
- `nodejs` for any tile-build helpers

## Pre-flight checks

- DNS A record `gis.woodfinegroup.com` resolves to the VM's public IP
- Firewall allows inbound 80/443 from operator-permitted CIDRs
- service-places pipeline data dir is mounted/available

## Bring-up smoke test

After bring-up per `guide-deployment.md`:

```bash
curl -fsS https://gis.woodfinegroup.com/healthz
curl -fsS https://gis.woodfinegroup.com/  # should return the GIS HTML
```

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
