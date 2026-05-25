---
schema: foundry-doc-v1
title: "Bare-Metal Provisioning and Mesh Fusion"
slug: guide-provision-onprem
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Bare-Metal Provisioning and Mesh Binding

This guide covers installing the host operating system on the on-premises hardware node and binding it to the Woodfine private network via the GCP cloud relay. The expected outcome is a running Linux node connected to the `10.50.0.x` mesh with WireGuard active.

## Prerequisites

- Physical hardware (Laptop A) available with installation media.
- WireGuard peer configuration for this node generated from `route-network-admin/guide-mesh-orchestration.md`.
- GCP cloud relay running (see `fleet-infrastructure-cloud/guide-provision-relay.md`).

## Steps

Exact execution parameters are pending. The provisioning sequence will be:

1. Install the operating system from installation media.
2. Install WireGuard: `sudo apt-get install wireguard`.
3. Write the node's `wg0.conf` with the private key and peer entries from the mesh configuration.
4. Enable WireGuard: `sudo systemctl enable --now wg-quick@wg0`.
5. Verify connectivity to the mesh hub: `ping 10.50.0.1`.

Full configuration will be documented when exact IP ranges and peer keys are ratified.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
