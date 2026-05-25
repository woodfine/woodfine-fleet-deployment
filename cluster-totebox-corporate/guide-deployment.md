---
schema: foundry-doc-v1
title: "Deployment — cluster-totebox-corporate"
slug: guide-deployment
type: guide
status: scaffold
audience: operators
bcsc_class: customer-internal
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Deployment Guide — cluster-totebox-corporate

Covers initial deployment of the cluster for Woodfine Management Corp. corporate operations, including the corporate communications pipeline and ledger services.

This cluster is in the scaffold phase. Full deployment procedures will be documented when the cluster moves to active state. For current node configuration and service inventory, refer to `README.md` in this directory.

When this cluster is deployed, this guide will cover: binary installation, systemd unit configuration, environment file setup, and post-deploy smoke verification.

## Prerequisites

- Node provisioned per `guide-provision-node.md`.
- SSH access to the target node.
- Relevant service binaries built from source.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
