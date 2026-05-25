---
schema: foundry-doc-v1
title: "Ingress Operations and Self-Healing Loop"
slug: guide-ingress-operations
type: guide
section: personnel-and-identity
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Ingress Operations and Self-Healing Loop

This guide covers operating the automated email ingestion pipeline for the personnel cluster. The pipeline harvests inbound email from `info@woodfine.co`, processes it through the local SLM classification layer, and appends classified records to the personnel and content ledgers.

## Prerequisites

- The `spool-daemon` systemd service running on the cluster node.
- Microsoft Graph API credentials stored in `service-email/auth-credentials.env`.
- The target Outlook folders (`totebox-ingress`, `OpenStack`, `PostgresSQL`) present in the Outlook account.

## The pipeline stages

The pipeline runs continuously:

1. **Harvest:** The email harvester pulls a maximum of 9 emails across the 3 target folders and drops them into `service-email/maildir/new/`.
2. **Store:** The raw `.eml` file is moved to cold storage.
3. **Classify:** The local OLMo model evaluates the text against the domain glossaries (corporate, projects, documentation), extracting archetypes and themes.
4. **Append:** The JSON ledgers for personnel and content are updated with the classification result.

## Domain glossaries

The SLM classification maps inbound email against three domain glossaries:

| Glossary | Purpose |
|---|---|
| `content-wiki-corporate` | Institutional governance |
| `content-wiki-projects` | Real estate ledgers |
| `content-wiki-documentation` | Platform architecture |

## Troubleshooting a stalled pipeline

1. Verify the Graph API tokens are current: check `service-email/auth-credentials.env` for expiry.
2. Confirm the target Outlook folders exist in the connected account (`totebox-ingress`, `OpenStack`, `PostgresSQL`).
3. Check the `spool-daemon` service status: `sudo systemctl status spool-daemon`.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
