---
schema: foundry-doc-v1
title: "Operational Telemetry Guide"
slug: guide-telemetry-operations
type: guide
section: console-and-operations
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Fleet Telemetry Operations

This guide covers retrieving telemetry reports and raw data ledgers from the cloud node to local operator machines. Two scripts in `media-marketing-landing/` handle this: one that triggers report generation on the cloud node, and one that pulls the generated files down.

## Prerequisites

- SSH access to the cloud telemetry node.
- The telemetry scripts (`tool-telemetry-synthesizer.sh`, `tool-telemetry-pull.sh`) present in the `media-marketing-landing/` directory.

## Procedure

1. **Generate reports:** Run `tool-telemetry-synthesizer.sh` to format raw cloud data into Markdown reports on the cloud node.
2. **Pull to local:** Run `tool-telemetry-pull.sh` to transfer the reports and raw `.csv` ledger files to the local machine. The script enforces a 9-day local retention policy and removes older local backups automatically.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
