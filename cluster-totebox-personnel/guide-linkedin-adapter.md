---
schema: foundry-doc-v1
title: "service-message-courier — LinkedIn Automation Adapter"
slug: guide-linkedin-adapter
type: guide
section: personnel-and-identity
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — LinkedIn Automation Adapter

This guide covers deploying the LinkedIn egress adapter for `service-message-courier` to the personnel cluster. The adapter automates outbound LinkedIn messaging via the cluster's private cloud node, subject to a built-in volume cap to prevent heuristic detection.

## Prerequisites

- Access to the `service-message-courier/private-adapters/` directory on the cluster node.
- `node_sync.sh` available for syncing the deployment to the GCP cluster.
- The `linkedin-egress.py` adapter script provided by the operator.

## Procedure

### Step 1 — Place the adapter script

Copy the adapter script to the isolated adapter directory before syncing the deployment:

**Target path:** `service-message-courier/private-adapters/linkedin-egress.py`

### Step 2 — Sync to the cluster

Run `node_sync.sh` to push the updated adapter to the GCP cluster node.

## Operational constraints

| Constraint | Value |
|---|---|
| Volume cap per execution cycle | 75–100 operations |
| Contact data storage | None on the cluster node; queries `service-people` at runtime only |

The volume cap is hard-coded in the adapter. Do not modify it without operator approval.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
