---
schema: foundry-doc-v1
title: "Totebox Orchestration and Autonomous Synthesis"
slug: guide-totebox-orchestration
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Cluster Orchestration and Autonomous Synthesis

This guide describes the autonomous data synthesis pipeline running on the personnel cluster. The pipeline continuously reads cold-stored email files, classifies them via the local SLM, and outputs taxonomy derivative files — archetypes, domains, and themes — as flat `.csv` and `.md` files.

## Prerequisites

- `service-email`, `service-slm`, and `service-extraction` running on the cluster node.
- Domain glossaries seeded (corporate, projects, documentation) or starting from a zero-state.
- The deduplication cron job configured and active.

## Architecture

The cluster uses a Derivative Architecture. Storage and sense-making are separated:

- **Base Assets:** Raw `.eml` files stored in cold storage.
- **First Derivative:** Taxonomy files (archetypes, chart of accounts, domains, themes) written continuously by the SLM daemon.

## II. THE SYNTHESIS LOOP (THE MADISON AVENUE ENGINE)
The system operates a continuous, self-healing loop in the background:

1. **The Base Asset:** `service-email` pulls raw files from MSFT and locks them into cold storage as immutable `.eml` files.
2. **Autonomous Indexing:** The `service-slm` daemon reads the cold files and synthesizes the **First Derivative** (Archetypes, Chart of Accounts, Domains, Themes).
3. **The Gravity Well:** If seeded with Domains (e.g., Corporate, Projects), the SLM pulls new data toward those wells. If starting from a Zero-State, the SLM synthesizes the matrix entirely from scratch based on detected patterns.
4. **Self-Healing:** Background cron jobs actively deduplicate and merge redundant Topics.

## III. THE OUTPUT
The synthesized First Derivative is not hidden in a database. It is continuously written to physical `.CSV` and `.MD` files, allowing the business to instantly export its operational brain for marketing or digital advertising purposes at zero additional cost.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
