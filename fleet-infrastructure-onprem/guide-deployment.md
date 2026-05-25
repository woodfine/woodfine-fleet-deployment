---
schema: foundry-doc-v1
title: "Deployment — fleet-infrastructure-onprem"
slug: guide-deployment
type: guide
status: scaffold
audience: operators
bcsc_class: customer-internal
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Deployment Guide — fleet-infrastructure-onprem

Covers initial deployment of on-premises infrastructure nodes at Woodfine corporate locations, forming the fleet network fabric on physical hardware.

This cluster is in the scaffold phase. Full deployment procedures will be documented when the cluster moves to active state. For current node configuration and service inventory, refer to `README.md` in this directory.

When this cluster is deployed, this guide will cover: OS installation, WireGuard mesh binding (see `guide-provision-onprem.md`), LXC container setup (see `guide-lxc-network-admin.md`), and post-deploy smoke verification.

## Prerequisites

- Physical hardware with supported OS installation media.
- Network access to the WireGuard hub (`fleet-infrastructure-cloud`).
- SSH access to the target node after OS installation.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
