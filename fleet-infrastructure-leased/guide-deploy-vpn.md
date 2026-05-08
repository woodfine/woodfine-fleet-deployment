---
schema: foundry-doc-v1
title: "Deploy VPN — Sovereign Overlay Network"
slug: guide-deploy-vpn
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-08
editor: pointsav-engineering
---

# OPERATIONAL MANIFEST: SOVEREIGN OVERLAY NETWORK

**ASSET CLASS:** Cyberphysical Infrastructure
**TARGET LEDGER:** `fleet-infrastructure-leased` (Laptop-B)
**PROCUREMENT VENDOR:** PointSav Digital Systems
**EXECUTING ENTITY:** Woodfine Management Corp.

## 1. STRATEGIC OBJECTIVE
Deployment of `service-vpn` to establish a sovereign, vendor-agnostic routing hub. This capability ensures that internal Woodfine Management Corp. digital traffic is cryptographically isolated from public internet architecture and third-party control planes.

## 2. VENDOR PAYLOAD ACQUISITION
The provisioning asset is supplied by PointSav Digital Systems. 

**Secure Transit Protocol:**
Initiate a secure local transfer of the Vendor payload to the leased hardware asset.

`scp /home/mathew/Foundry/pointsav-monorepo/service-vpn/provision_wireguard_hub.sh user@<LOCAL_IP_OF_LAPTOP_B>:/tmp/`

## 3. OPERATIONAL EXECUTION
Execute the Vendor payload on the target asset with elevated system privileges to align the kernel network stack and generate the root cryptographic identity.

`ssh user@<LOCAL_IP_OF_LAPTOP_B> "sudo /tmp/provision_wireguard_hub.sh"`

## 4. ASSET LEDGER REGISTRATION
Upon successful execution, the physical egress point will output a **Hub Public Key**. 

This cryptographic signature must be recorded in the Woodfine secure ledgers. It acts as the anchor identity for all subsequent node authorizations (e.g., authorizing the MacPro or iMac to enter the sovereign network).

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
