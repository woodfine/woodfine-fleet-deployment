---
schema: foundry-doc-v1
title: "macOS Endpoint Configuration"
slug: guide-macos-endpoints
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-08
editor: pointsav-engineering
---

# OPERATIONAL MANIFEST: macOS SOVEREIGN ENDPOINT CONFIGURATION

**ASSET CLASS:** Client Endpoint Provisioning
**TARGET HARDWARE:** Apple macOS (MacBook Air / MacPro)
**PROCUREMENT VENDOR:** PointSav Digital Systems
**EXECUTING ENTITY:** Woodfine Management Corp.

## 1. STRATEGIC OBJECTIVE
This manifest governs the procedure for integrating Woodfine macOS hardware into the sovereign corporate overlay network (the Hub). Upon completion, 100% of the endpoint's digital traffic will be cryptographically tunneled through the primary Woodfine physical egress router, bypassing third-party surveillance and local network restrictions.

## 2. PREREQUISITES
1. The endpoint operator must obtain their unique cryptographic configuration file (`.conf`) from the Woodfine Asset Ledger (e.g., `peter-mexico.conf` or `jennifer-macpro.conf`). **Do not share these files; they are mathematically tied to individual hardware.**
2. The endpoint must have macOS Administrator privileges to authorize the network extension.

## 3. OPERATIONAL EXECUTION

**Step 1: Acquire the Vendor Vessel**
* Open the **App Store** on the macOS endpoint.
* Search for and install the official **WireGuard** application. (This is the secure vessel that will read the PointSav payload).

**Step 2: Inject the Cryptographic Payload**
* Launch the WireGuard application. 
* A WireGuard icon will appear in the top macOS Menu Bar.
* Click the Menu Bar icon and select **"Manage Tunnels"**.
* Click the **"+"** icon (or "Import Tunnel(s) from File") in the bottom left corner.
* Select the provided `.conf` file (e.g., `peter-mexico.conf`).
* macOS will prompt for permission to add a VPN configuration. Click **"Allow"** and enter your Mac password or use TouchID.

**Step 3: Network Activation & Verification**
* In the WireGuard window, click the **"Activate"** button next to your new tunnel.
* **Visual Confirmation:** The WireGuard icon in the top Menu Bar will change to a solid, bold state (or display a green status dot in the tunnel manager), indicating the cryptographic handshake with the Woodfine Hub is active.
* To disconnect, simply click the Menu Bar icon and click the active tunnel name to toggle it off.

## 4. SUPPORT PROTOCOL
If the handshake fails (no internet connectivity when activated), verify the physical internet connection. If the physical connection is stable, contact internal Woodfine support (Jennifer) to verify the Hub's public IP address has not rotated.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
