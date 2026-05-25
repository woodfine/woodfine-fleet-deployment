---
schema: foundry-doc-v1
title: "MacBook Air Endpoint (Mexico)"
slug: guide-endpoint-macbook
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — MacBook Air Endpoint (Mexico)

This guide covers installing and activating the WireGuard VPN tunnel on a MacBook Air operating remotely. Upon completion, the endpoint's traffic routes through the Woodfine private network hub.

## Prerequisites

- Your unique WireGuard configuration file: `endpoint-mexico.conf`. This file is tied to your specific device; do not install it on another device.
- macOS administrator privileges to authorize the VPN network extension.

## 3. OPERATIONAL EXECUTION

**Step 1: Acquire the Secure Vessel**
* Open the **App Store** on your MacBook Air.
* Search for and install the official **WireGuard** application.

**Step 2: Inject the Cryptographic Payload**
* Launch the WireGuard application. 
* A WireGuard icon will appear in the top macOS Menu Bar.
* Click the Menu Bar icon and select **"Manage Tunnels"**.
* Click the **"+"** icon (or "Import Tunnel(s) from File") in the bottom left corner.
* Select your `endpoint-mexico.conf` file.
* macOS will prompt for permission to add a VPN configuration. Click **"Allow"** and enter your Mac password or use TouchID.

**Step 3: Network Activation & Visual Confirmation**
* In the WireGuard window, click the **"Activate"** button next to your new tunnel.
* **Visual Confirmation:** The WireGuard icon in the top Menu Bar will change to a solid state (and display a green status dot in the tunnel manager). This confirms your cryptographic handshake with the Woodfine Hub is active.
* To disconnect, click the Menu Bar icon and click the active tunnel name to toggle it off.

## 4. SUPPORT PROTOCOL
If you experience connectivity drops, verify your local internet connection in Mexico first. If the local connection is stable but the tunnel fails, contact the PointSav support desk to verify the Woodfine Hub's routing status.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
