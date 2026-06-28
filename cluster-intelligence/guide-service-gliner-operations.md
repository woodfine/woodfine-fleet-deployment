---
artifact: guide
schema: foundry-draft-v1
title: "Operating service-gliner"
slug: guide-service-gliner-operations
status: refined
language: en
bilingual_pair_required: false
bcsc_class: internal
forbidden_terms_cleared: true
route_to: command
deployment_target: cluster-totebox-jennifer
refined_by: project-editorial
refined_on: 2026-06-28
source_draft: clones/project-totebox/.agent/drafts-outbound/GUIDE-service-gliner-operations.draft.md
created: 2026-06-28
updated: 2026-06-28
research_trail:
  sources_cited: true
  claims_verified: true
  sme_review: pending
  external_review: not-required
  last_checked: 2026-06-28
---

# Operating service-gliner

`service-gliner` is the GLiNER named entity recognition microservice. It serves the Tier 0 extraction path for `service-content` on port 9085 and is required for efficient document throughput. Without it, extraction falls back to OLMo 7B on CPU (Tier A), which is 200–600× slower.

## Service identity

| Property | Value |
|---|---|
| Systemd unit | `local-gliner.service` |
| System user | `local-gliner` |
| Port | 9085 (localhost only) |
| Venv | `/var/lib/local-gliner/venv/` |
| Weights | `/var/lib/local-gliner/weights/` |
| Source | `/srv/foundry/clones/project-totebox/service-gliner/main.py` |
| Model | `urchade/gliner_medium-v2.1` |
| Memory | 900 MB high / 1200 MB max |

## Starting, stopping, and restarting

```bash
sudo systemctl start local-gliner.service
sudo systemctl stop local-gliner.service
sudo systemctl restart local-gliner.service
```

First startup after a VM reboot takes 8–12 seconds while the model loads from disk. Subsequent restarts take 3–5 seconds from the OS cache.

`local-gliner.service` declares `Before=local-content.service`, so systemd starts it before `service-content` when both are enabled.

## Health check

```bash
curl http://127.0.0.1:9085/healthz
```

Returns `{"status":"ok","model":"urchade/gliner_medium-v2.1"}` when ready. If the service returns HTTP 502 or connection refused, it is still loading or has crashed — check `journalctl` (see below).

## Verifying extraction

```bash
curl -s http://127.0.0.1:9085/v1/extract \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Blackstone has been refurbishing Broadgate Quarter near Liverpool Street. James Rosenfeld, a managing director, oversees the project.",
    "domain_id": "projects"
  }' | python3 -m json.tool
```

Expected output (order may vary):
```json
[
  {"entity_name": "Blackstone",         "classification": "Company"},
  {"entity_name": "Broadgate Quarter",  "classification": "Project"},
  {"entity_name": "Liverpool Street",   "classification": "Location"},
  {"entity_name": "James Rosenfeld",    "classification": "Person"}
]
```

If the entity list is empty for prose that should contain entities, check:
1. Is the `domain_id` correct? Use `projects` for CRE content, `documentation` for code.
2. Is the text below 2,000 characters? Tier 0 in `service-content` truncates at 2,000 chars before dispatching. Shorter test inputs are more reliable.
3. Is the model loaded? Check `journalctl` for startup errors.

## Logs

```bash
# Live stream
sudo journalctl -u local-gliner.service -f

# Last 50 lines
sudo journalctl -u local-gliner.service -n 50 --no-pager

# Since last boot
sudo journalctl -u local-gliner.service -b --no-pager
```

A healthy startup log ends with:
```
INFO:     Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:9085
```

A model-load failure produces a Python traceback before the uvicorn startup line. The most common cause is a missing or incomplete weights directory.

## Updating the model

The weights are cached at `/var/lib/local-gliner/weights/` under the `local-gliner` system user. The model is loaded offline (`HF_HUB_OFFLINE=1`). To update the model:

1. Stop the service: `sudo systemctl stop local-gliner.service`
2. As the `local-gliner` user, download the new model to the weights directory.
3. Update `GLINER_MODEL` in the systemd unit if the model identifier changes.
4. Run `sudo systemctl daemon-reload` then `sudo systemctl start local-gliner.service`.

Changing `domain_id` label definitions requires editing `DOMAIN_LABELS` in `service-gliner/main.py` and restarting the service. No weights change is needed — GLiNER reads label descriptions at inference time, not at load time.

## Adding a new domain

To support a new `domain_id` beyond `projects`, `corporate`, and `documentation`, add an entry to `DOMAIN_LABELS` in `service-gliner/main.py`:

```python
"my-domain": {
    "Person":   "description of a person in this domain",
    "Company":  "description of a company in this domain",
    # add or remove classification keys as needed
},
```

Restart the service after editing. Label descriptions should be specific — GLiNER uses them as classification anchors and performs better with concrete examples than with abstract categories.

## Memory

The service enforces a 900 MB soft limit (`MemoryHigh`) and a 1,200 MB hard limit (`MemoryMax`) via systemd. Exceeding `MemoryMax` causes the OOM killer to terminate the process; systemd will restart it after 10 seconds. If the VM is under sustained memory pressure, raising `MemoryMax` in the unit file and running `sudo systemctl daemon-reload && sudo systemctl restart local-gliner.service` may resolve crash loops.

## Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| Connection refused on :9085 | Service not started or crashed | `sudo systemctl start local-gliner.service`; check logs |
| `{"entities": []}` for prose | Wrong `domain_id`; text too short; text is structured data (CSV, JSON) | Check domain; test with longer prose |
| Startup traceback: `OSError: model files not found` | Weights not downloaded to `/var/lib/local-gliner/weights/` | Re-download weights as `local-gliner` user |
| Startup traceback: `ImportError: cannot import name 'GLiNER'` | Venv not set up or packages not installed | Run `sudo -u local-gliner /var/lib/local-gliner/venv/bin/pip install gliner>=0.2.0` |
| OOM kill in `journalctl` | Model RSS exceeded `MemoryMax=1200M` | Raise limit in unit file; or reduce concurrent load |
| `service-content` logs `[TIER-0] GLiNER unreachable` | Service down or slow to start | Restart service; wait for model load before restarting `local-content.service` |
