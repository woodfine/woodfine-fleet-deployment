---
schema: foundry-doc-v1
title: "PPN Mesh Execution (the F8 Terminal)"
slug: guide-mesh-execution
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Private Network Mesh Execution (F8 Terminal)

This guide covers using the F8 Terminal at `network.woodfinegroup.com` to issue commands to the Woodfine private network fleet. Every command follows a two-step verify-and-execute flow before being broadcast to nodes.

## Prerequisites

- Access to `network.woodfinegroup.com` from a connected fleet node.
- The network admin interface (`os-network-admin`) running in the LXC container (see `fleet-infrastructure-onprem/guide-lxc-network-admin.md`).

## Command execution flow

Every command issued to the network follows a proposal and authorization flow:

1. **Submit intent:** Type an instruction in plain language (e.g., `Lock down the laptop node`).
2. **Verify translation:** The terminal displays the machine-translated payload (e.g., `ACTION: ISOLATE, TARGET: NODE-LAPTOP-A`). Review it for accuracy before proceeding.
3. **Authorize execution:** Click `EXECUTE` to broadcast the verified command to the network.

## III. COMMAND EXAMPLES

### A. Infrastructure Telemetry (Fleet Health)
* **Intent:** `Check the health of the network.`
* **Verification Prompt:** `[PROPOSED] ACTION: PING, TARGET: ALL`
* **Result:** Broadcasts a UDP signal to port `8090`. All active nodes reply with their current CPU, RAM, and routing statuses.

### B. Fleet Node Isolation (Security)
* **Intent:** `Lock down the laptop node immediately.`
* **Verification Prompt:** `[PROPOSED] ACTION: ISOLATE, TARGET: NODE-LAPTOP-A`
* **Result:** The target node drops all routing tables except the master link to Node 3, freezing its ledgers in place.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
