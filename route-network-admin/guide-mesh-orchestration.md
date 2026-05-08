---
schema: foundry-doc-v1
title: "Mesh Network Orchestration"
slug: guide-mesh-orchestration
type: guide
status: active
audience: operators
bcsc_class: forward-looking
last_edited: 2026-05-08
editor: pointsav-engineering
---

# Mesh Network Orchestration Guide

Covers generating WireGuard key pairs and subnet routing tables for the Woodfine private network. The network admin node (`route-network-admin`) holds the master cryptographic keys and authoritative subnet assignments.

This guide is in development. The steps below reflect the design intent; exact IP ranges and peer list will be documented when the route-network-admin cluster moves to Active state.

## Network topology

The Woodfine private network uses a hub-and-spoke topology with a GCP cloud relay as the hub:

| Node | Role | WireGuard endpoint |
|---|---|---|
| `fleet-infrastructure-cloud` | Hub (static public IP) | `<cloud-ip>:51820` |
| `fleet-infrastructure-onprem` | Spoke (on-premises iMac) | dials cloud relay |
| `fleet-infrastructure-leased` | Spoke (laptop endpoints) | dials cloud relay |

## Key generation

WireGuard uses Curve25519 key pairs. Generate a pair per node:

```bash
wg genkey | tee privatekey | wg pubkey > publickey
```

Store private keys securely on each respective node. Collect public keys centrally on the network admin node to build the peer configuration.

## Subnet assignment

The mesh uses the `10.x.x.x/24` range. Assign one IP per node. Document the assignment in `INVENTORY.yaml` at the repository root.

## Steps

Full configuration files (`wg0.conf` per node) to be documented when exact IP ranges and all peer public keys are ratified.

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
