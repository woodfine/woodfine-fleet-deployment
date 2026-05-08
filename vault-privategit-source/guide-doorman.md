---
schema: foundry-doc-v1
title: "Operating the service-slm Doorman on vault-privategit-source-1"
slug: guide-doorman
type: guide
status: active
audience: workspace-master + operator
bcsc_class: current-fact
component: local-doorman.service (slm-doorman-server)
deployment: vault-privategit-source-1 (foundry-workspace VM)
last_edited: 2026-05-08
editor: pointsav-engineering
cites:
  - ni-51-102
---

# guide-doorman — operating the service-slm Doorman on `vault-privategit-source-1`

This is the operational runbook for the service-slm Doorman as it
runs on the Foundry workspace VM. It covers deploy, configure,
monitor, troubleshoot, routine operations, and rollback. It does not
re-state architecture — for what the Doorman is and why it exists,
read the conventions cross-referenced in §8.

The Doorman runs as `local-doorman.service` (systemd) on the
workspace VM. The same binary ships to Customer Toteboxes as Tier 1
substrate per `conventions/four-tier-slm-substrate.md`; this guide
is the workspace (vendor) instance of that pattern.

---

## 1. What the Doorman is

The Doorman (`/usr/local/bin/slm-doorman-server`, axum HTTP server
bound to `127.0.0.1:9080`) is the boundary service for service-slm.
It implements the three-tier inference router (Tier A local OLMo /
Tier B Yo-Yo cloud burst / Tier C external API allowlist), holds
all external LLM provider keys at a single chokepoint, writes the
per-tenant audit ledger, and exposes the apprenticeship-substrate
endpoints (`/v1/brief`, `/v1/verdict`, `/v1/shadow`).

Architecture and design rationale live in:
- `conventions/four-tier-slm-substrate.md` — the four customer-deployment tiers
- `conventions/api-key-boundary-discipline.md` — keys live ONLY at the Doorman
- `conventions/apprenticeship-substrate.md` — brief / verdict / shadow endpoints
- `infrastructure/local-doorman/README.md` — substrate state and endpoint surface

This GUIDE assumes those documents have been read. It is a runbook,
not a design doc.

---

## 2. Deploy

### 2.1 Source and build

Source code: `pointsav-monorepo/service-slm/crates/slm-doorman-server/`
(public: `github.com/pointsav/pointsav-monorepo`; on the Foundry workspace VM at `clones/project-slm/pointsav-monorepo/`)

The cluster Task ships changes via promotion (Stage-6 to canonical
`pointsav/pointsav-monorepo`); Master builds from canonical clone HEAD,
not directly from the cluster clone, when sudo-deploying. The split is
by §11 layer scope: Task authors, Master deploys.

Build command (from any clone of `pointsav-monorepo`, run by whichever
session is rebuilding — typically Master from canonical, occasionally
Task during cluster smoke-test):

```bash
cd <pointsav-monorepo-clone>/service-slm
cargo build --release -p slm-doorman-server
```

Output: `target/release/slm-doorman-server` (~50 MB stripped).

### 2.2 Sudo install

Master scope. Per §8 of the workspace CLAUDE.md (admin-tier), Master
operates with sudo on workspace VM infrastructure:

```bash
# Snapshot the live binary as rollback fallback
sudo install -o root -g root -m 0755 \
    /usr/local/bin/slm-doorman-server \
    /usr/local/bin/slm-doorman-server.bak

# Install the new build
sudo install -o root -g root -m 0755 \
    <pointsav-monorepo-clone>/service-slm/target/release/slm-doorman-server \
    /usr/local/bin/slm-doorman-server
```

The `.bak` snapshot is the rollback artifact (§7). `bin/post-impl-brief-queue.sh`
implements this snapshot pattern programmatically.

### 2.3 systemd unit + drop-in pattern

The unit at `/etc/systemd/system/local-doorman.service` is canonical
(content lives in `infrastructure/local-doorman/local-doorman.service`
in the workspace repo and is installed by `bootstrap.sh`). The unit
should NOT be edited in-place under `/etc/systemd/system/`; use a
drop-in instead:

```bash
sudo mkdir -p /etc/systemd/system/local-doorman.service.d/
sudo $EDITOR /etc/systemd/system/local-doorman.service.d/<concern>.conf
sudo systemctl daemon-reload
sudo systemctl restart local-doorman.service
```

Drop-in conventions:
- `/etc/systemd/system/local-doorman.service.d/yoyo-tier-b.conf` —
  Tier B (Yo-Yo) activation; sets `SLM_YOYO_ENDPOINT`, `SLM_YOYO_BEARER`,
  `SLM_YOYO_HOURLY_USD`, `SLM_YOYO_MODEL`. See `infrastructure/yoyo-manual/README.md`.
- `/etc/systemd/system/local-doorman.service.d/external.conf` —
  Tier C (external API) activation; sets per-provider bearers per the
  Tier C key wiring spec (see §3.3).

### 2.4 Env file

Loaded via `EnvironmentFile=` in the unit:
```
/etc/local-doorman/local-doorman.env
```

Owned `root:root`, mode `0640`, group-readable by `local-doorman`.
This file holds non-secret configuration AND any external LLM API
keys (per `api-key-boundary-discipline.md` §3). It is not in Git;
Master maintains it under workspace operator authority.

### 2.5 Initial directory bootstrap

Required directory tree (Master pre-creates with proper permissions
per workspace v0.1.83):

```bash
# Audit ledger root (per-tenant subdirs auto-created by Doorman)
sudo install -d -o local-doorman -g local-doorman -m 0750 \
    /var/lib/local-doorman/audit

# Apprenticeship corpus root (sgid for foundry group inheritance)
sudo install -d -o local-doorman -g foundry -m 2775 \
    /srv/foundry/data/training-corpus/apprenticeship

# Brief queue subdirs (workspace v0.1.83+, post §7C ship)
for sub in queue queue-in-flight queue-done queue-poison; do
    sudo install -d -o local-doorman -g foundry -m 2775 \
        "/srv/foundry/data/apprenticeship/${sub}"
done
```

The `2775` mode (sgid + group-writable) ensures both the Doorman
service user and capture-edit.py (running as workspace user `mathew`,
also in `foundry` group) can read+write. Any non-root user that needs
queue access must be added to the `foundry` group via
`sudo usermod -a -G foundry <user>`.

### 2.6 First-time start + verify

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now local-doorman.service

# Wait ~2 seconds for boot
curl -s http://127.0.0.1:9080/healthz
# Expected: 200 (any body)

curl -s http://127.0.0.1:9080/readyz | jq
# Expected (community-tier baseline):
# {
#   "ready": true,
#   "has_local": true,
#   "has_yoyo": false,
#   "has_external": false
# }

curl -s http://127.0.0.1:9080/v1/contract | jq
# Expected: doorman_version + yoyo_contract_version + ...
```

If `has_local=false`, the Doorman cannot reach `local-slm.service` at
`127.0.0.1:8080`. See §5.1.

---

## 3. Configure

### 3.1 Env file walkthrough

Every variable in `/etc/local-doorman/local-doorman.env`, what it
does, default, and when to change.

| Variable | Default | What it does | Change when |
|---|---|---|---|
| `SLM_BIND_ADDR` | `127.0.0.1:9080` | HTTP listen address | Customer Totebox may bind a different localhost port; vendor workspace stays at `:9080` |
| `SLM_LOCAL_ENDPOINT` | `http://127.0.0.1:8080` | Tier A upstream (llama.cpp / OLMo) | If `local-slm.service` moves ports |
| `SLM_LOCAL_MODEL` | `Olmo-3-1125-7B-Think-Q4_K_M.gguf` | Model label echoed in audit ledger | When OLMo model file changes |
| `SLM_YOYO_ENDPOINT` | (empty) | Tier B upstream URL | Set when Yo-Yo provisions; preferred via drop-in (§2.3) |
| `SLM_YOYO_BEARER` | (empty) | Tier B auth bearer | Set with `SLM_YOYO_ENDPOINT` |
| `SLM_YOYO_HOURLY_USD` | (empty) | Cost cap input for Tier B routing | Operator policy |
| `SLM_YOYO_MODEL` | (empty) | Model label for Tier B | Set with `SLM_YOYO_ENDPOINT` |
| `SLM_APPRENTICESHIP_ENABLED` | `true` | Enables `/v1/brief`, `/v1/verdict`, `/v1/shadow` | Disable only for emergency rollback |
| `SLM_AUDIT_DIR` | `/var/lib/local-doorman/audit` | Per-tenant audit ledger root | Avoid changing — backup paths assume this |
| `FOUNDRY_ROOT` | `/srv/foundry` | Workspace anchor for queue + corpus paths | Customer Totebox sets to `/var/lib/totebox` (deployment-shape) |
| `FOUNDRY_DOCTRINE_VERSION` | `0.0.14` | Echoed in audit ledger entries | Bump on doctrine MINOR/MAJOR |
| `RUST_LOG` | `info` | Log verbosity | `debug` for diagnosis; never leave at `trace` in steady state (audit volume) |
| `HOME` | `/var/lib/local-doorman` | systemd-set; service-user home | Do not change |

After editing the env file:
```bash
sudo systemctl restart local-doorman.service
curl -s http://127.0.0.1:9080/readyz | jq
```

### 3.2 Tier B (Yo-Yo) wiring

Tier B is OFF by default at workspace baseline (`has_yoyo=false`)
per the cost-guardrail discipline. Activation requires:

1. Yo-Yo VM provisioned per `infrastructure/yoyo-manual/README.md`
   (operator-presence runbook; ~30-60 min wall time)
2. Bearer token issued from Yo-Yo gateway
3. Drop-in placed at `/etc/systemd/system/local-doorman.service.d/yoyo-tier-b.conf`:
   ```ini
   [Service]
   Environment="SLM_YOYO_ENDPOINT=https://<yoyo-public-ip>:8443"
   Environment="SLM_YOYO_BEARER=<token-from-yoyo>"
   Environment="SLM_YOYO_HOURLY_USD=2.00"
   Environment="SLM_YOYO_MODEL=Olmo-3-1125-32B-Think-Q4_K_M.gguf"
   ```
4. `sudo systemctl daemon-reload && sudo systemctl restart local-doorman.service`
5. Verify `/readyz` returns `has_yoyo: true`

When Yo-Yo idles down (per its idle-shutdown discipline), the
Doorman's brief queue (§7C amendment, post v0.1.83) buffers shadow
briefs durably until Yo-Yo wakes. No capture loss across cold/warm
transitions.

### 3.3 Tier C (external API) wiring

Tier C is OFF by default (`has_external=false`). Activation is
governed by a separate convention currently in flight (the "Tier C
key wiring spec" — see project-language Task brief queue at workspace
v0.1.83 for status).

The boundary discipline is fixed per `api-key-boundary-discipline.md`:
- All external provider keys live in env-file or drop-in (NEVER in
  inference engines, NEVER in cluster Task scope, NEVER in
  capture-edit.py)
- Per-purpose allowlist gates outbound calls (`AuditProxyPurposeAllowlist`)
- Every Tier C call writes to the audit ledger before the upstream
  call returns

When the Tier C key wiring spec ratifies, this section will
reference it directly.

### 3.4 Per-tenant routing

The Doorman accepts the four `X-Foundry-*` request headers per
`infrastructure/local-doorman/README.md` "Endpoint surface" table.
`X-Foundry-Module-ID` is the tenant moduleId — `foundry` for vendor
work, `woodfine` for Woodfine deployment work, future tenant labels
per the customer onboarding flow.

Per-tenant audit ledger paths:
```
/var/lib/local-doorman/audit/<tenant>/<YYYY-MM>.jsonl
```

Per-tenant apprenticeship corpus paths:
```
/srv/foundry/data/training-corpus/apprenticeship/<task-type>/<tenant>/
```

The Doorman creates per-tenant subdirs on first request from a new
moduleId; no manual provisioning required.

---

## 4. Monitor

### 4.1 `/readyz` endpoint

```bash
curl -s http://127.0.0.1:9080/readyz | jq
```

Field semantics:

| Field | Meaning | Healthy value |
|---|---|---|
| `ready` | Doorman is accepting requests | `true` |
| `has_local` | Tier A upstream reachable | `true` (workspace baseline) |
| `has_yoyo` | Tier B upstream configured + reachable | `true` after Yo-Yo provisioned; `false` at baseline |
| `has_external` | Tier C provider keys + allowlist configured | `false` until Tier C activation |

`ready=true && has_local=false` is a degraded state — Doorman accepts
requests but Tier A routing fails. Cluster Task work that targets
Tier A inference will block. See §5.1.

### 4.2 Audit ledger growth

Path:
```
/var/lib/local-doorman/audit/<tenant>/<YYYY-MM>.jsonl
```

One JSONL line per request. Ten fields per line per
`infrastructure/local-doorman/README.md` "Audit ledger" section:
`timestamp_utc`, `request_id`, `module_id`, `tier`, `model`,
`inference_ms`, `cost_usd`, `sanitised_outbound`, `completion_status`,
`prompt_tokens`, `completion_tokens`.

Check current month size:
```bash
sudo ls -lh /var/lib/local-doorman/audit/foundry/$(date +%Y-%m).jsonl
```

Normal volume at workspace baseline:
- Light cluster Task work: 5-50 KB/day
- Active editorial-pipeline work (project-language sweeps): 100 KB - 1 MB/day
- Heavy shadow-routing on every commit (post §7C ship): 1-10 MB/day

A ledger month-file >100 MB warrants attention — likely either a
debug-log loop or an unrate-limited upstream caller. Inspect
`journalctl -u local-doorman.service -n 500` for the originating
moduleId.

### 4.3 Apprenticeship corpus growth

Path:
```
/srv/foundry/data/training-corpus/apprenticeship/<task-type>/<tenant>/
```

One JSONL file per captured tuple per
`conventions/apprenticeship-substrate.md` §8. File names
`<ulid>.jsonl` (or `shadow-<brief_id>.jsonl` post §7B amendment).

Check current count by task-type and tenant:
```bash
find /srv/foundry/data/training-corpus/apprenticeship -name '*.jsonl' \
    | awk -F/ '{print $(NF-2), $(NF-1)}' | sort | uniq -c
```

Normal cadence post §7B + §7C ship:
- `prose-edit` (editorial gateway): 70-100 tuples/week (workspace
  baseline; per `apprenticeship-substrate.md` §7A)
- `version-bump-manifest` (P1 production): 5-20 tuples/week
- All other code-shaped task-types via P2 shadow: 1 tuple per
  in-scope commit (varies by cluster activity)

### 4.4 Queue depth (post-§7C)

Path (workspace v0.1.83+):
```
/srv/foundry/data/apprenticeship/queue/
```

Depth = file count. Check:
```bash
ls /srv/foundry/data/apprenticeship/queue/ | wc -l
ls /srv/foundry/data/apprenticeship/queue-in-flight/ | wc -l
ls /srv/foundry/data/apprenticeship/queue-poison/ | wc -l
```

Healthy state:
- `queue/` <10 files at any moment (worker drains FIFO)
- `queue-in-flight/` <5 files (active leases; expire after 10× apprentice timeout)
- `queue-poison/` 0 files (any non-zero count is a structural defect)

If `queue/` is growing without draining: the worker is stuck. Check
`journalctl -u local-doorman.service` for worker-task panics.

If `queue-in-flight/` files are stale (timestamp >1 hour):
lease-expiry has not fired; restart Doorman to recover.

### 4.5 Log volume

```bash
# Recent activity
journalctl -u local-doorman.service -n 100

# Live tail
journalctl -u local-doorman.service -f

# Errors only
journalctl -u local-doorman.service -p err -n 50

# Time-bounded
journalctl -u local-doorman.service --since '1 hour ago'
```

Log volume scales with `RUST_LOG`:
- `info` (default): one line per request + lifecycle events
- `debug`: 5-10x volume; per-request internal state transitions
- `trace`: 50-100x volume; do not leave on in steady state

---

## 5. Troubleshoot

### 5.1 `/readyz` reports `has_local=false`

Tier A upstream (`local-slm.service` at `127.0.0.1:8080`) is not
reachable. Sequence to diagnose:

```bash
sudo systemctl status local-slm.service
curl -s http://127.0.0.1:8080/health  # llama.cpp /health endpoint
```

Common causes:
1. `local-slm.service` failed to start — check
   `journalctl -u local-slm.service -n 100`
2. OLMo model file missing or corrupted — see
   `infrastructure/local-slm/README.md` for model placement
3. Port `:8080` taken by another process — `sudo lsof -i :8080`

Recovery:
```bash
sudo systemctl restart local-slm.service
# Wait ~30 seconds for model load
sudo systemctl restart local-doorman.service
curl -s http://127.0.0.1:9080/readyz | jq
```

### 5.2 `/readyz` reports `has_yoyo=false`

Expected at workspace baseline. If Tier B was supposed to be active:
1. Verify drop-in exists at
   `/etc/systemd/system/local-doorman.service.d/yoyo-tier-b.conf`
2. Verify Yo-Yo VM is running (per `infrastructure/yoyo-manual/README.md`
   "Status check" section)
3. Verify Yo-Yo public IP is reachable from workspace VM:
   `curl -sk https://<yoyo-ip>:8443/healthz`
4. `sudo systemctl daemon-reload && sudo systemctl restart local-doorman.service`

If Yo-Yo VM is not provisioned, `has_yoyo=false` is correct — see
§3.2.

### 5.3 Audit-ledger writes failing

Symptom: requests return 200 but ledger month-file is not growing,
OR Doorman logs `audit-write-failed`.

Common cause: `local-doorman` user does not own
`/var/lib/local-doorman/audit/`. Fix:
```bash
sudo chown -R local-doorman:local-doorman /var/lib/local-doorman/audit/
sudo chmod 0750 /var/lib/local-doorman/audit/
sudo systemctl restart local-doorman.service
```

Per `feedback_never_chmod_canonical_identity_store.md`, this rule
applies ONLY to the audit-ledger directory, NOT to identity store
paths. Identity store at `/srv/foundry/identity/` is `0600`
mathew-only by deliberate workspace v0.1.36+ policy.

### 5.4 Queue dir not draining (post-§7C)

Symptom: `queue/` file count grows; `queue-in-flight/` empty.

Diagnose:
```bash
journalctl -u local-doorman.service --since '10 min ago' | grep -i queue
```

Common causes:
1. Worker tokio task panicked at startup — restart Doorman
2. `FOUNDRY_ROOT` env not set or wrong — verify in env-file
3. Permission boundary — `local-doorman` not in `foundry` group:
   ```bash
   id local-doorman
   # Expected: uid=N(local-doorman) gid=N(local-doorman) groups=N(local-doorman),N(foundry)
   ```
   Fix:
   ```bash
   sudo usermod -a -G foundry local-doorman
   sudo systemctl restart local-doorman.service
   ```

If `queue-in-flight/` has stuck leases (file timestamp > worker
timeout × 10), the lease reaper is not firing. Move the stuck leases
back to `queue/` manually:
```bash
sudo -u local-doorman bash -c '
  cd /srv/foundry/data/apprenticeship
  for f in queue-in-flight/*.lease.*; do
      [[ -e "$f" ]] || continue
      base=$(basename "$f" | cut -d. -f1)
      mv "$f" "queue/${base}.brief.jsonl"
  done
'
```

If `queue-poison/` accumulates: each entry is a brief that
consistently fails apprentice dispatch. Master sweeps manually;
inspect a sample brief to identify the malformed-content pattern,
add validation upstream (in capture-edit.py or queue.rs).

### 5.5 Service crashes / exits

```bash
sudo systemctl status local-doorman.service
journalctl -u local-doorman.service -n 200
```

`Restart=on-failure` + `RestartSec=5s` in the unit means systemd
auto-restarts on crash. If restart loop persists (more than 5
crashes in 5 minutes), systemd marks the service `failed` and stops.

Manual restart:
```bash
sudo systemctl reset-failed local-doorman.service
sudo systemctl restart local-doorman.service
```

If the binary itself is the problem (panic on startup), roll back
per §7.

### 5.6 Disk pressure (audit-ledger / corpus growth)

The audit ledger and apprenticeship corpus both grow monotonically.
At workspace VM baseline (workspace v0.1.83):

- `/var/lib/local-doorman/` is on the root filesystem
- `/srv/foundry/data/` is on the root filesystem
- VM disk: 50-200 GB depending on workspace generation

Check disk usage:
```bash
du -sh /var/lib/local-doorman/audit/
du -sh /srv/foundry/data/training-corpus/apprenticeship/
df -h /
```

When audit ledger month-files exceed 1 GB or accumulate >20 GB total,
rotate via gzip:
```bash
cd /var/lib/local-doorman/audit/<tenant>/
sudo -u local-doorman gzip 2024-*.jsonl 2025-*.jsonl
# Keep current + previous month uncompressed for active query
```

Apprenticeship corpus is training input; do NOT compress until
training has consumed it (per `conventions/trajectory-substrate.md`
hygiene cadence). When corpus exceeds 100 GB total, evaluate
moving to dedicated disk per `MEMO-2026-03-30-Development-Overview-V8.md`
§4 storage tier guidance.

---

## 6. Routine operations

### 6.1 Restart for env-file changes

```bash
sudo $EDITOR /etc/local-doorman/local-doorman.env
sudo systemctl restart local-doorman.service
curl -s http://127.0.0.1:9080/readyz | jq
```

`systemctl restart` does NOT need `daemon-reload` for env-file
changes (the file is read at process start, not at unit-load time).
`daemon-reload` IS required for unit-file or drop-in changes.

### 6.2 Drop-in for Tier B activation

See §3.2.

### 6.3 Audit-ledger backup

The audit ledger is plain-text JSONL and is included in the
workspace rsync backup pattern by default. No special procedure
needed; ledger inherits whatever backup discipline the workspace
runs.

When per-tenant export is needed (e.g., customer-disclosure ask):
```bash
sudo cp -r /var/lib/local-doorman/audit/<tenant>/ /tmp/<tenant>-audit-$(date +%F)/
sudo chown -R mathew:foundry /tmp/<tenant>-audit-$(date +%F)/
```

Tenant data MUST NOT cross tenant boundaries — only export the
specific tenant's subdir, not the parent.

### 6.4 Upgrade procedure

The full sequence from cluster ship through live-deploy is
implemented as `bin/post-impl-brief-queue.sh` (idempotent; named for
the §7C ship but the sequence pattern generalizes). Manual form:

```bash
# 1. Stage-6 promote cluster → canonical (Master scope)
bin/promote.sh --cluster project-slm --target pointsav-monorepo  # on the Foundry workspace VM

# 2. Rebuild from canonical clone HEAD
cd <pointsav-monorepo-clone>/service-slm
cargo build --release -p slm-doorman-server

# 3. Snapshot + install
sudo install -o root -g root -m 0755 \
    /usr/local/bin/slm-doorman-server \
    /usr/local/bin/slm-doorman-server.bak
sudo install -o root -g root -m 0755 \
    target/release/slm-doorman-server \
    /usr/local/bin/slm-doorman-server

# 4. Restart
sudo systemctl restart local-doorman.service

# 5. Verify
sleep 3
curl -s http://127.0.0.1:9080/readyz | jq
curl -s http://127.0.0.1:9080/v1/contract | jq
```

Acceptance criteria:
- `/readyz` returns `ready=true` within 5 seconds of restart
- `has_local`, `has_yoyo`, `has_external` flags match prior state
- `/v1/contract` `doorman_version` reflects new build
- `journalctl -u local-doorman.service -n 50` shows no startup errors
- Smoke commit produces audit-ledger entry within 10 seconds

If any criterion fails, roll back per §7.

---

## 7. Rollback

### 7.1 Binary rollback

`/usr/local/bin/slm-doorman-server.bak` is created by the install
sequence (§6.4 step 3) and by `bin/post-impl-brief-queue.sh` step 4.
Restore:

```bash
sudo install -o root -g root -m 0755 \
    /usr/local/bin/slm-doorman-server.bak \
    /usr/local/bin/slm-doorman-server
sudo systemctl restart local-doorman.service
sleep 3
curl -s http://127.0.0.1:9080/readyz | jq
```

The `.bak` is overwritten by each new install. If a multi-step
rollback is needed, recover the older binary from canonical
`pointsav/pointsav-monorepo` git history:

```bash
cd <pointsav-monorepo-clone>/service-slm
git checkout <previous-good-sha> -- crates/slm-doorman-server/
cargo build --release -p slm-doorman-server
# Then install per §6.4 step 3
```

### 7.2 Env-file rollback

The env file is not in Git (holds secrets). Master keeps timestamped
snapshots in `/etc/local-doorman/`:

```bash
sudo cp /etc/local-doorman/local-doorman.env \
    /etc/local-doorman/local-doorman.env.$(date +%F-%H%M)
```

Snapshot before any non-trivial edit. Restore:
```bash
sudo cp /etc/local-doorman/local-doorman.env.<timestamp> \
    /etc/local-doorman/local-doorman.env
sudo systemctl restart local-doorman.service
```

### 7.3 systemd unit rollback

The unit file lives in the workspace repo at
`infrastructure/local-doorman/local-doorman.service`. To roll back a
unit change:

```bash
# On the Foundry workspace VM (vault-privategit-source-1/):
git log -- infrastructure/local-doorman/local-doorman.service
git checkout <previous-good-sha> -- \
    infrastructure/local-doorman/local-doorman.service
sudo install -o root -g root -m 0644 \
    infrastructure/local-doorman/local-doorman.service \
    /etc/systemd/system/local-doorman.service
sudo systemctl daemon-reload
sudo systemctl restart local-doorman.service
```

### 7.4 Drop-in rollback

Drop-ins are not in Git (may carry secrets like Yo-Yo bearer).
Snapshot + restore pattern same as env-file:
```bash
sudo cp /etc/systemd/system/local-doorman.service.d/yoyo-tier-b.conf \
    /etc/systemd/system/local-doorman.service.d/yoyo-tier-b.conf.$(date +%F-%H%M)
```

To disable a Tier without deleting the drop-in, rename it out of
the `.d/` directory:
```bash
sudo mv /etc/systemd/system/local-doorman.service.d/yoyo-tier-b.conf \
    /etc/systemd/system/local-doorman.service.d/yoyo-tier-b.conf.disabled
sudo systemctl daemon-reload
sudo systemctl restart local-doorman.service
# /readyz now reports has_yoyo=false
```

systemd only loads `*.conf` files from drop-in directories.

---

## 8. Reference / cross-links

Conventions (architecture and design rationale):
- `[[four-tier-slm-substrate]]` — Tier 0/1/2/3 ladder
- `[[api-key-boundary-discipline]]` — keys at the gateway only
- `[[apprenticeship-substrate]]` — brief / verdict / shadow
- `[[three-ring-architecture]]` — Ring 1/2/3 boundaries
- `[[adapter-composition]]` — request-time adapter algebra

Infrastructure (substrate and operational state):
- on the Foundry workspace VM: `vault-privategit-source-1/infrastructure/local-doorman/README.md` — endpoint surface, on-disk layout, status
- on the Foundry workspace VM: `vault-privategit-source-1/infrastructure/local-doorman/local-doorman.service` — canonical systemd unit
- on the Foundry workspace VM: `vault-privategit-source-1/infrastructure/local-doorman/bootstrap.sh` — install procedure
- on the Foundry workspace VM: `vault-privategit-source-1/infrastructure/local-slm/` — Tier A backend (OLMo 7B Q4)
- on the Foundry workspace VM: `vault-privategit-source-1/infrastructure/yoyo-manual/README.md` — Tier B operator-presence runbook
- on the Foundry workspace VM: `vault-privategit-source-1/infrastructure/slm-yoyo/CONTRACT.md` — Tier B wire contract

Tools (Master operates):
- on the Foundry workspace VM: `bin/post-impl-brief-queue.sh` — §7C ship sequence (Stage-6 + build + install + restart + smoke + diff-preview)
- on the Foundry workspace VM: `bin/promote.sh` — Stage-6 staging-tier → canonical promotion
- on the Foundry workspace VM: `bin/capture-edit.py` — post-commit shadow brief emitter

Source (cluster Task scope):
- `pointsav-monorepo/service-slm/crates/slm-doorman-server/` — Doorman crate source
- `pointsav-monorepo/service-slm/ARCHITECTURE.md` — per-project architecture

Doctrine anchors:
- `DOCTRINE.md` claim #16 — Optional Intelligence (Rings 1+2 functional without Ring 3)
- `DOCTRINE.md` claim #17 — Transparent multi-tier compute routing
- `DOCTRINE.md` claim #22 — Adapter Composition Algebra
- `DOCTRINE.md` claim #32 — Apprenticeship Substrate
- `DOCTRINE.md` claim #40 — Four-Tier SLM Substrate Ladder

---

## References

Per the Foundry workspace citations registry (`vault-privategit-source-1/citations.yaml` on the workspace VM):
- [ni-51-102] — BCSC continuous-disclosure obligations (audit ledger
  is the operational artefact backing per-tenant disclosure events)

---

*Authored 2026-04-29 in workspace v0.1.83 cycle. Updated when the
Doorman gains new endpoints, env vars, or operational paths.*

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
