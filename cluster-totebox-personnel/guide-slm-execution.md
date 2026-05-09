---
schema: foundry-doc-v1
title: "service-slm Execution Pipeline"
slug: guide-slm-execution
type: guide
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-08
editor: pointsav-engineering
---

# GUIDE: service-slm Execution Pipeline

**Operational Tier:** 3 (Fleet Deployment)
**Target Node:** cluster-totebox-personnel-1

## 1. Overview

The cluster runs a local `service-slm` Tier A inference engine that evaluates every ingested asset against the three domain glossaries (corporate, projects, documentation), extracts archetypes and themes, and writes the result to the content graph. This cluster operates **Tier A only** — no Tier B GPU burst or Tier C external API calls originate here. The local-only posture keeps every inference call on the cluster node and avoids any per-call cost.

Cross-reference [[doorman-protocol]] for the access-control gateway pattern that the cluster's SLM operations route through.

## 2. Execution stages

Each ingested asset moves through four pipeline stages:

1. **Harvester drop:** the email harvester (see [[guide-ingress-operations]]) lands a `.eml` file into `service-email/maildir/new/`.
2. **Extraction:** `service-extraction` parses the payload, strips MIME formatting, and constructs a structured Entity Bundle with a transaction identifier.
3. **SLM classification:** the local OLMo-2-0425-1B-Instruct model receives the bundle, evaluates it against the three domain glossaries, and emits archetype + theme labels with a confidence score.
4. **Content-graph append:** the classified result is appended to the cluster's content graph (`/var/lib/cluster-totebox-personnel/content-graph/<domain>/<ulid>.md`) and the matching personnel record is updated.

Every inference call transits the Doorman boundary and writes an audit-ledger entry to `/var/lib/local-doorman/audit/woodfine/<YYYY-MM>.jsonl` before the upstream model returns. Per-asset latency target on Tier A is under two seconds, dominated by the local model's tokenisation pass.

## 3. Daily operations

**Monitoring:**

- `journalctl -u local-slm.service -n 100` — recent inference-engine logs.
- `du -sh /var/lib/local-doorman/audit/woodfine/` — audit-ledger growth (light cluster activity should produce 5–50 KB/day).
- `find /var/lib/cluster-totebox-personnel/content-graph -name '*.md' -mtime -1 | wc -l` — content-graph delta count over the last 24 hours.

**Drift signals:**

The apprenticeship substrate (see [[apprenticeship-substrate]]) tracks per-task-type accept-rate. A declining accept-rate over a rolling 50-verdict window signals model drift; the cluster's Stage-2 corpus is then rebuilt from the senior-verdict deltas and the local LoRA adapter is re-trained on the next Yo-Yo cycle.

**Troubleshooting a stalled pipeline:**

1. Verify the Tier A model file is intact: `sha256sum /var/lib/local-slm/OLMo-2-0425-1B-Instruct-Q4_K_M.gguf`.
2. Check the env-file Tier A endpoint: `grep SLM_LOCAL_ENDPOINT /etc/local-doorman/local-doorman.env`.
3. Confirm the domain glossaries are loaded: `ls -la /var/lib/cluster-totebox-personnel/glossaries/{corporate,projects,documentation}.json`.
4. If all three are healthy and the pipeline is still stalled, restart the SLM service: `sudo systemctl restart local-slm.service` and re-check `journalctl`.


## 4. Content Export

Operators can synchronise the SLM-processed content graph to a local copy at any time.

1. Open a terminal in the cluster-totebox-personnel working directory.
2. Run `./tool-extract-content.sh`.
3. The script synchronises `knowledge-graph/` (drafts) and `verified-ledger/` (finalized records) to the local machine without modifying the cluster state.
4. Review Markdown output in `./Sovereign-Exports/Content/`.

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
