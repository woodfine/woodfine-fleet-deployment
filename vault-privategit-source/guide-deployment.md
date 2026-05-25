---
schema: foundry-doc-v1
title: "Deployment — vault-privategit-source"
slug: guide-deployment
type: guide
status: scaffold
audience: operators
bcsc_class: customer-internal
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Deployment Guide — vault-privategit-source

Covers initial deployment of the source code vault node, providing private Git hosting for Woodfine-specific source code and configuration.

This cluster is in the scaffold phase. Full deployment procedures will be documented when the cluster moves to active state. For current node configuration and service inventory, refer to `README.md` in this directory.

When this cluster is deployed, this guide will cover: binary installation, systemd unit configuration, environment file setup, and post-deploy smoke verification.

## Prerequisites

- Node provisioned per `guide-provision-node.md`.
- SSH access to the target node.
- Network access from fleet nodes that will push or pull from this vault.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
