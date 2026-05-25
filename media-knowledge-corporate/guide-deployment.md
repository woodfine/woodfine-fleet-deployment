---
schema: foundry-doc-v1
title: "Deployment — media-knowledge-corporate"
slug: guide-deployment
type: guide
section: content-and-media
status: scaffold
audience: operators
bcsc_class: customer-internal
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Deployment Guide — media-knowledge-corporate

Covers initial deployment of the corporate knowledge wiki instance (`app-mediakit-knowledge`), serving internal Woodfine Management Corp. documentation.

This cluster is in the scaffold phase. Full deployment procedures will be documented when the cluster moves to active state. For current node configuration and service inventory, refer to `README.md` in this directory.

When this cluster is deployed, this guide will cover: binary installation, systemd unit configuration, environment file setup, and post-deploy smoke verification.

## Prerequisites

- Node provisioned per `guide-provision-node.md`.
- nginx and certbot installed on the target VM.
- DNS A record for the corporate wiki domain resolving to the VM's public IP.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
