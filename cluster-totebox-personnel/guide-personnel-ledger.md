---
schema: foundry-doc-v1
title: "Personnel Ledger Operations"
slug: guide-personnel-ledger
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-08
editor: pointsav-engineering
---

# GUIDE: Personnel Ledger Operations

**Operational Tier:** 3 (Fleet Deployment)
**Target Node:** cluster-totebox-personnel-1

## 1. Overview

The personnel ledger is the canonical JSON flat-file record of every contact known to the cluster. It is populated by `service-extraction` from inbound email and authored append-only by the `service-slm` daemon. The ledger is the cluster's authoritative answer to the question "who has the cluster heard from, in what role, and when?" — a question every downstream service that enriches content with contact context relies on.

Cross-reference [[service-people]] for the substrate-level service that defines the personnel record schema.

## 2. Data structure

The ledger lives at `/var/lib/cluster-totebox-personnel/personnel-ledger.json` on the cluster node. It is a flat JSON file rather than a database — portable across infrastructure changes, auditable with standard filesystem tools, and natively compatible with local-model training pipelines.

Each record carries the following fields:

| Field | Type | Notes |
|---|---|---|
| `contact_id` | ULID | Stable identifier; never reused |
| `display_name` | string | Best-known display name; derived from From-header parsing |
| `email_addresses` | list of strings | All addresses observed for this contact |
| `domain_match` | enum | One of `corporate`, `projects`, `documentation`, or `unmatched` |
| `archetype` | string | SLM-extracted archetype label (see guide-totebox-orchestration §II) |
| `last_seen` | ISO 8601 timestamp | UTC; updated on every observation |
| `provenance` | list | Append-only log of source `.eml` IDs that contributed to this record |

The ledger is **append-only**. A correction never overwrites a prior record; instead, a new record is appended with a `supersedes` field pointing at the prior `contact_id`. This invariant is enforced by `service-slm` write logic and the underlying filesystem WORM discipline. Per-tenant partition is by `module_id` (`woodfine` for this cluster).

## 3. Lineage

How records arrive in the ledger:

1. **Ingress:** the harvester drops `.eml` files into `service-email/maildir/new/` (see [[guide-ingress-operations]] for the upstream pipeline).
2. **Sender parsing:** `service-extraction` parses each `.eml` payload and extracts sender identity (From, Reply-To, X-Original-From headers).
3. **Domain match:** the sender record is evaluated against the cluster's domain glossaries (corporate / projects / documentation / unmatched).
4. **Archetype extraction:** `service-slm` Tier A inference assigns an archetype label based on signature, role hints, and prior interaction patterns.
5. **Append:** the personnel record is appended to `personnel-ledger.json`. Existing contacts have their `email_addresses`, `provenance`, and `last_seen` fields extended; new contacts get a fresh `contact_id`.

A background cron job runs `tool-dedupe-personnel.sh` nightly to merge records that the SLM identifies as the same contact across multiple email aliases. Merges are themselves append-only entries; the prior records are flagged `superseded`, never deleted.


## 4. Personnel Data Export

Operators can export the entire personnel ledger to a flat CSV at any time.

1. Open a terminal in the cluster-totebox-personnel working directory.
2. Run `./tool-extract-people.sh`.
3. The script extracts `personnel_export.csv` from the cluster node via SSH.
4. Review output in `./Sovereign-Exports/People/`.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
