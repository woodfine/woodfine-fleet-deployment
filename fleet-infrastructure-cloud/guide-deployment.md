---
schema: foundry-doc-v1
title: "Deployment — fleet-infrastructure-cloud"
slug: guide-deployment
type: guide
status: scaffold
audience: operators
bcsc_class: customer-internal
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Deployment Guide — fleet-infrastructure-cloud

Covers initial deployment of the GCP cloud infrastructure nodes that serve as the static, public-facing WireGuard hub for the Woodfine private network.

This cluster is in the scaffold phase. Full deployment procedures will be documented when the cluster moves to active state. For current node configuration and service inventory, refer to `README.md` in this directory. For WireGuard hub configuration, see `guide-provision-relay.md`.

When this cluster is deployed, this guide will cover: binary installation, systemd unit configuration, environment file setup, and post-deploy smoke verification.

## Prerequisites

- GCP compute instance provisioned with a static external IP (see `guide-provision-relay.md`).
- SSH access to the target node.
- WireGuard installed on the target node.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
