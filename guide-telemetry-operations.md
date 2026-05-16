---
schema: foundry-doc-v1
title: "Operational Telemetry Guide"
slug: guide-telemetry-operations
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-08
editor: pointsav-engineering
---

# Woodfine Management Corp. | Operational Telemetry Guide

## Overview
This guide details the operational execution for retrieving asset ledgers and telemetry reports from the cloud environment to local physical nodes. 

## Execution Sub-Routines
All execution scripts reside in `/media-marketing-landing/`.

1. **Synthesis Trigger (`tool-telemetry-synthesizer.sh`)**: Commands the cloud node to format raw data into human-readable Markdown reports.
2. **Strict Pull Diode (`tool-telemetry-pull.sh`)**: Secures a one-way transfer of generated reports and raw `.csv` ledger assets to the local machine, enforcing a localized 9-day retention cycle.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
