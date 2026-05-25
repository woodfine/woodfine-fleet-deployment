---
schema: foundry-doc-v1
title: "Deployment — route-network-admin"
slug: guide-deployment
type: guide
section: network-and-infrastructure
status: scaffold
audience: operators
bcsc_class: customer-internal
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Deployment Guide — route-network-admin

Covers initial deployment of the network routing administration node, which manages the WireGuard mesh topology, cryptographic keys, and subnet routing for the Woodfine private network.

This cluster is in the scaffold phase. Full deployment procedures will be documented when the cluster moves to active state. For current node configuration and service inventory, refer to `README.md` in this directory.

When this cluster is deployed, this guide will cover: WireGuard hub configuration (see `guide-mesh-orchestration.md`), node registration, and post-deploy smoke verification.

## Prerequisites

- Node provisioned per `guide-provision-node.md`.
- WireGuard installed on the target node.
- SSH access to the target node.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
