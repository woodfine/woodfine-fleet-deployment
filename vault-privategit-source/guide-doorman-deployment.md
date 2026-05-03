# GUIDE-doorman-deployment — service-slm Doorman installation and operations

**Deployment name:** `doorman` (or `slm-doorman` for specificity)  
**Catalog:** `vendor/pointsav-fleet-deployment/slm-doorman/`  
**Instance:** `~/Foundry/deployments/slm-doorman-1/` (workspace dogfood instance)

---

## What is the Doorman

The Doorman is the secure boundary between Totebox (the isolated local archive) and external language models. It is a three-tier router that:

1. **Tier A (Local):** Routes to OLMo 3 7B Q4 on the host via `local-slm.service`
2. **Tier B (Yo-Yo):** Bursts to GPU compute (GCP Cloud Run, RunPod, Modal) for scale
3. **Tier C (External API):** Routes to Anthropic Claude, Google Gemini, or OpenAI via allowlist

The Doorman:
- Sanitises outbound payloads before routing
- Enforces cost guardrails (Tier B/C disabled unless explicitly configured)
- Logs every call to an append-only JSONL audit ledger
- Serves `POST /v1/chat/completions` (OpenAI-compatible wire format)
- Implements Apprenticeship Substrate for model training feedback (v0.1.x+)

---

## Prerequisites

- **Tier A running:** `local-slm.service` operational on the same host, listening on port 8080
- **Network:** Access to GCP (if Tier B enabled), external APIs (if Tier C enabled)
- **User:** Running under the `slm-doorman` system user; does NOT require root privileges

---

## Installation

### 1. Build the release binary

From the cluster root:

```bash
cd /srv/foundry/clones/project-slm/service-slm
cargo build --release -p slm-doorman-server
```

Binary lands at `target/release/slm-doorman-server` (~15 MB, stripped).

### 2. Run the bootstrap installer

The installer is idempotent and safe to run multiple times:

```bash
sudo /srv/foundry/infrastructure/slm-doorman/bootstrap.sh
```

Or, if installing for the first time:

```bash
sudo /srv/foundry/clones/project-slm/service-slm/compute/systemd/bootstrap.sh
```

The script:
- Creates the `slm-doorman` system user and group
- Creates `/var/lib/slm-doorman` (working directory + audit ledger home)
- Installs the binary to `/usr/local/bin/slm-doorman-server`
- Installs the systemd unit to `/etc/systemd/system/slm-doorman.service`
- Enables the unit to start on boot

### 3. Start the service

```bash
sudo systemctl start slm-doorman
sudo systemctl enable slm-doorman  # already done by bootstrap; no-op if running again
```

### 4. Verify health

```bash
curl http://127.0.0.1:9080/healthz
# Expected output: HTTP 200 OK
```

If Tier A is ready:

```bash
curl http://127.0.0.1:9080/readyz
# Expected output: HTTP 200 OK
```

---

## Configuration

All configuration is environment variables in `/etc/systemd/system/slm-doorman.service`.

### Tier A (Local) — always enabled

Default configuration points to `local-slm.service`:

```
Environment="SLM_LOCAL_ENDPOINT=http://127.0.0.1:8080"
Environment="SLM_LOCAL_MODEL=Olmo-3-1125-7B-Think-Q4_K_M.gguf"
```

No setup needed. The Doorman is fully functional in community-tier mode with only Tier A.

### Tier B (Yo-Yo) — optional GPU burst

To enable bursting to external GPU compute, edit `/etc/systemd/system/slm-doorman.service` and uncomment:

```
Environment="SLM_YOYO_ENDPOINT=<GCP Cloud Run URL or RunPod endpoint>"
Environment="SLM_YOYO_BEARER=<static bearer token from provider>"
Environment="SLM_YOYO_HOURLY_USD=0.84"  # GCP L4 example
Environment="SLM_YOYO_MODEL=Olmo-3-1125-32B-Think"
```

Then reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart slm-doorman
```

**Cost guardrail:** Tier B is disabled if `SLM_YOYO_ENDPOINT` is not set. No accidental bursts.

**Cost tracking:** The Doorman computes per-call cost as:
```
cost_usd = (hourly_rate / 3,600,000) × inference_time_ms
```

Example: 0.84 USD/hour at 1000ms inference = 0.00084 USD per call.

### Tier C (External API) — optional, requires allowlist

To enable calls to external APIs, edit the unit and uncomment for your provider(s):

**Anthropic Claude:**

```
Environment="SLM_TIER_C_ANTHROPIC_ENDPOINT=https://api.anthropic.com"
Environment="SLM_TIER_C_ANTHROPIC_API_KEY=sk-..."
Environment="SLM_TIER_C_ANTHROPIC_INPUT_PER_MTOK_USD=0.0003"
Environment="SLM_TIER_C_ANTHROPIC_OUTPUT_PER_MTOK_USD=0.0015"
```

**Google Gemini (same pattern):**

```
Environment="SLM_TIER_C_GEMINI_ENDPOINT=https://generativelanguage.googleapis.com"
Environment="SLM_TIER_C_GEMINI_API_KEY=..."
Environment="SLM_TIER_C_GEMINI_INPUT_PER_MTOK_USD=0.000075"
Environment="SLM_TIER_C_GEMINI_OUTPUT_PER_MTOK_USD=0.0003"
```

**OpenAI (same pattern):**

```
Environment="SLM_TIER_C_OPENAI_ENDPOINT=https://api.openai.com/v1"
Environment="SLM_TIER_C_OPENAI_API_KEY=sk-..."
Environment="SLM_TIER_C_OPENAI_INPUT_PER_MTOK_USD=0.0005"
Environment="SLM_TIER_C_OPENAI_OUTPUT_PER_MTOK_USD=0.0015"
```

Reload and restart after making changes.

**Allowlist enforcement:** Clients MUST include the `X-Foundry-Tier-C-Label` header with one of these labels:
- `citation-grounding` — resolve citations against external knowledge
- `initial-graph-build` — bootstrap semantic graph from corpus
- `entity-disambiguation` — clarify entity references

Requests without the header or with an unlisted label are denied **before any network call** — no API costs incurred.

**Cost guardrail:** Tier C is disabled if NO provider endpoint is set. No accidental API spend.

### Apprenticeship Substrate (v0.1.x+)

Once `bin/apprentice.sh` + `bin/capture-edit.py` land (AS-5), enable the training feedback pipeline:

```
Environment="SLM_APPRENTICESHIP_ENABLED=true"
Environment="FOUNDRY_ROOT=/srv/foundry"
Environment="FOUNDRY_ALLOWED_SIGNERS=/srv/foundry/identity/allowed_signers"
Environment="FOUNDRY_DOCTRINE_VERSION=0.0.7"
Environment="FOUNDRY_TENANT=pointsav"
```

This enables:
- `POST /v1/brief` — seek apprenticeship attempt
- `POST /v1/verdict` — submit signed senior verdict
- `POST /v1/shadow` — record shadow brief for corpus

See `service-slm/ARCHITECTURE.md` §11 for the full apprenticeship flow.

---

## Status and logs

### Unit status

```bash
systemctl status slm-doorman
```

### View logs

```bash
journalctl -u slm-doorman -f          # tail, live
journalctl -u slm-doorman --no-pager  # all history
journalctl -u slm-doorman -p err      # errors only
```

### Health checks

**Liveness (always 200):**

```bash
curl http://127.0.0.1:9080/healthz
```

**Readiness (200 if Tier A responds):**

```bash
curl http://127.0.0.1:9080/readyz
```

**Contract (wire format + tier list):**

```bash
curl http://127.0.0.1:9080/v1/contract | jq .
```

### Audit ledger

Append-only JSONL record of every inference call (organized by date):

```bash
tail -f /var/lib/slm-doorman/audit/$(date +%Y-%m-%d).jsonl
```

Sample entry:

```json
{
  "request_id": "b2e10115-c747-4fc8-b571-80484db7276e",
  "timestamp": "2026-04-26T19:44:32Z",
  "tier": "local",
  "model": "Olmo-3-1125-7B-Think-Q4_K_M.gguf",
  "module_id": "project-slm",
  "inference_ms": 43914,
  "tokens_in": 42,
  "tokens_out": 128,
  "cost_usd": 0.0,
  "completion_status": "ok"
}
```

---

## Integration with Totebox

The Doorman is the **only** outbound gateway from Totebox. All LLM calls route through `http://127.0.0.1:9080/v1/chat/completions`.

Clients within Totebox (service-extraction, service-content, etc.) send requests like:

```json
POST http://127.0.0.1:9080/v1/chat/completions
Content-Type: application/json
X-Foundry-Module-ID: service-extraction

{
  "model": "olmo-3-7b-instruct",
  "messages": [
    {"role": "system", "content": "Extract entities..."},
    {"role": "user", "content": "..."}
  ],
  "temperature": 0.2,
  "max_tokens": 1024
}
```

The Doorman:
1. Logs the call (module_id = `service-extraction`)
2. Routes to appropriate tier (default Tier A)
3. Sanitises the response
4. Returns OpenAI-compatible format

---

## Cost management

### Cost guardrails (operator enforcement)

- **Tier B disabled by default:** Set `SLM_YOYO_ENDPOINT` only when ready to incur GPU costs
- **Tier C disabled by default:** Set provider endpoints only when ready to incur API costs
- **Tier C allowlist:** Only narrow labels (`citation-grounding`, etc.) route to external APIs
- **No silent fallback:** If Tier A is down, the Doorman returns HTTP 502, not a silent fallback to Tier B/C

### Cost tracking

The audit ledger records `cost_usd` for every call, computed deterministically:

- **Tier A:** Always 0.0 (local compute)
- **Tier B:** `(hourly_usd / 3,600,000) × inference_ms`
- **Tier C:** `(input_tokens / 1,000,000) × input_per_mtok_usd + (output_tokens / 1,000,000) × output_per_mtok_usd`

Export the ledger for billing or analytics:

```bash
cat /var/lib/slm-doorman/audit/*.jsonl | \
  jq -s 'map({date: .timestamp[:10], tier, cost_usd}) | group_by(.date) | map({date: .[0].date, total: (map(.cost_usd) | add)})' | jq .
```

---

## Troubleshooting

### Doorman starts but returns 502 Bad Gateway

**Cause:** Tier A (`local-slm.service`) is not responding on port 8080.

**Fix:**

```bash
systemctl status local-slm
curl http://127.0.0.1:8080/healthz  # should return 200
systemctl restart local-slm
```

### Requests to Tier B return 401 Unauthorized

**Cause:** Bearer token expired or invalid.

**Fix:**

Edit `/etc/systemd/system/slm-doorman.service`, refresh the token, and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart slm-doorman
```

### Requests to Tier C return 403 Forbidden (allowlist)

**Cause:** Request missing `X-Foundry-Tier-C-Label` header or label not in allowlist.

**Fix:**

Verify the client sends the header:

```bash
curl -X POST http://127.0.0.1:9080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "X-Foundry-Tier-C-Label: citation-grounding" \
  -d '{...}'
```

Valid labels: `citation-grounding`, `initial-graph-build`, `entity-disambiguation`.

### Audit ledger fills disk

**Cause:** Long-running Doorman with high query volume.

**Fix:**

The ledger is append-only and organized by date. Implement a retention policy:

```bash
# Keep last 90 days
find /var/lib/slm-doorman/audit -type f -mtime +90 -delete
```

Add to a cron job or systemd timer if needed.

### Service fails to restart after config change

**Cause:** Syntax error in `/etc/systemd/system/slm-doorman.service`.

**Fix:**

Check the syntax:

```bash
sudo systemd-analyze verify slm-doorman.service
```

View the unit file:

```bash
systemctl cat slm-doorman
```

If editing manually, reload first:

```bash
sudo systemctl daemon-reload
sudo systemctl status slm-doorman  # will show parse errors
```

---

## Operations checklist

### Daily

- [ ] Monitor logs for errors: `journalctl -u slm-doorman -p err`
- [ ] Verify readiness: `curl http://127.0.0.1:9080/readyz`

### Weekly

- [ ] Audit total Tier B/C cost: `tail -100 /var/lib/slm-doorman/audit/$(date +%Y-%m-%d).jsonl | jq '.[] | select(.tier != "local") | .cost_usd' | paste -sd+ | bc`
- [ ] Check for restart storms: `journalctl -u slm-doorman -p warning`

### Monthly

- [ ] Review audit ledger for anomalies (unusual module_ids, error spikes)
- [ ] Rotate old ledger files if disk usage is high
- [ ] Refresh Tier B/C credentials (bearer tokens, API keys)

---

## References

- `service-slm/ARCHITECTURE.md` — Full technical architecture
- `service-slm/DEVELOPMENT.md` — Build and release process
- `service-slm/compute/systemd/` — Unit file and bootstrap templates
- `infrastructure/local-slm/README.md` — Tier A setup
- `infrastructure/slm-yoyo/` — Tier B (Yo-Yo) infrastructure (if deployed)
- `DOCTRINE.md` §III — Doorman as the foundational security boundary


---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
