---
schema: foundry-doc-v1
title: "Provision Node — gateway-orchestration-bim"
slug: guide-provision-node
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-08
editor: pointsav-engineering
---

# Provision Node Guide — gateway-orchestration-bim

VM-level prerequisites for hosting the BIM workflow gateway.

## VM specification

- e2-small or larger (1 vCPU, 2 GB RAM minimum)
- 30 GB pd-balanced disk (BIM data + binary + working data)
- us-west1-a (current foundry-workspace zone) or operator-chosen region
- nginx + certbot installed at provision time

## System dependencies

To be filled in when project-bim Task signals v0.0.1 ready and binary build dependencies are firmed up.

## Pre-flight checks

- DNS A record `bim.woodfinegroup.com` resolves to the VM's public IP
- Firewall allows inbound 80/443 from operator-permitted CIDRs
- Per-property archive data is mounted/available

## Bring-up smoke test

After bring-up per `guide-deployment.md`:

```bash
curl -fsS https://bim.woodfinegroup.com/healthz
```

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
