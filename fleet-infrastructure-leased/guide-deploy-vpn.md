---
schema: foundry-doc-v1
title: "Deploy VPN — Sovereign Overlay Network"
slug: guide-deploy-vpn
type: guide
section: network-and-infrastructure
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Deploy WireGuard VPN Hub (Leased Node)

This guide covers deploying `service-vpn` to a leased laptop node to establish the WireGuard routing hub for the Woodfine private network. The hub node receives a static private IP and acts as the anchor for all fleet spokes. The expected outcome is a running WireGuard hub that outputs a public key for spoke registration.

## Prerequisites

- SSH access to the leased laptop node (Laptop-B) with `sudo` privileges.
- The `provision_wireguard_hub.sh` script from the `pointsav-monorepo/service-vpn/` source directory.
- Local network connectivity to the target node.

## Procedure

### Step 1 — Transfer the provisioning script

Copy the script to the target node:

```bash
scp pointsav-monorepo/service-vpn/provision_wireguard_hub.sh user@<LOCAL_IP_OF_LAPTOP_B>:/tmp/
```

### Step 2 — Execute the provisioning script

Run the script with elevated privileges on the target node:

```bash
ssh user@<LOCAL_IP_OF_LAPTOP_B> "sudo /tmp/provision_wireguard_hub.sh"
```

### Step 3 — Record the hub public key

The script outputs a WireGuard **Hub Public Key** on completion. Record this key in `INVENTORY.yaml` at the repository root. It is the anchor identity for all subsequent spoke authorizations (MacBook, iMac, etc.).

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
