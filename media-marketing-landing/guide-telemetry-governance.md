---
schema: foundry-doc-v1
title: "Telemetry Governance — media-marketing-landing"
slug: guide-telemetry-governance
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-08
editor: pointsav-engineering
---

# Telemetry Governance Guide — media-marketing-landing

Covers the data governance posture for the Woodfine Management Corp. marketing landing surface. All telemetry collected through this surface is processed locally under the Totebox Orchestration architecture — no data is routed to third-party analytics platforms.

## Architecture

Visitor interactions with the marketing landing are routed to the `os-totebox` local processing stack. The `os-mediakit` component handles ingestion and outputs structured records to the deployment's outbox directories for internal audit.

## Accessing telemetry

Telemetry extraction runs on the network admin node. The extraction procedure will be documented in this guide when the fleet reaches Active state. For current telemetry operations (service status, log inspection), see `guide-telemetry-operations.md`.

## Data sovereignty note

No visitor data is transmitted to external cloud services. The processing pipeline is physically isolated on Woodfine-owned hardware. This posture supports Woodfine Management Corp.'s customer-data privacy commitments.

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
