---
schema: foundry-doc-v1
title: "Provisioning the Network Ledger (LXC)"
slug: guide-lxc-network-admin
type: guide
section: network-and-infrastructure
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Network Admin Interface (LXC Container)

This guide covers deploying the `os-network-admin` interface inside an LXC container on the on-premises hardware node. The container runs isolated on the host's WireGuard interface (`wg0`), serves the network admin UI via nginx, and keeps the interface portable across hardware changes.

## Prerequisites

- LXC installed on the on-premises host (Laptop A).
- The WireGuard `wg0` interface active and connected to the private network mesh.
- `app-network-*` UI assets and chassis available from the monorepo source directory.
- `sudo` access on the host to create containers and configure networking.

## Deployment sequence

The deployment script runs four phases:

1. **Container setup:** Initializes an Ubuntu/Debian LXC container named `pointsav-network-ledger`.
2. **Network bridge:** Bridges the container to the host `wg0` interface, giving it access to the `10.50.0.x` mesh.
3. **Asset mount:** Mounts the `app-network-*` UI assets and chassis into the container's `/var/www/html/` directory.
4. **Web server:** Installs and configures nginx to serve the interface on an internal port, ready for the HTTPS reverse proxy.

## Ongoing maintenance

The `mesh-state.json` file is initially seeded as a static ledger. A cron-based script within the container surveys the mesh and updates the radar JSON on a schedule.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
