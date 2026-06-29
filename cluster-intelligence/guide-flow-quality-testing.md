---
artifact: guide
schema: foundry-draft-v1
title: "Testing and Auditing the Knowledge Flow"
slug: guide-flow-quality-testing
status: refined
language: en
bilingual_pair_required: false
bcsc_class: internal
forbidden_terms_cleared: true
route_to: command
deployment_target: cluster-intelligence
refined_by: project-editorial
refined_on: 2026-06-28
source_draft: clones/project-totebox/.agent/drafts-outbound/GUIDE-flow-quality-testing.draft.md
created: 2026-06-20
updated: 2026-06-28
research_trail:
  sources_cited: true
  claims_verified: true
  sme_review: pending
  external_review: not-required
  last_checked: 2026-06-28
---

# Testing and Auditing the Knowledge Flow

This guide is the repeatable procedure for auditing the LoRA training loop
(`service-slm`) and the Ontological DataGraph (`service-content`). It stays inside
a **read-only boundary**: no graph mutations, no live training, no GPU spend.
Anything heavier is a sanctioned live run, flagged at the end.

## 1. Read-only boundary

Allowed: read/grep any source; `cargo test`/`clippy`; **GET-only** curl to
`:9080` and `:9081`; `--dry-run` on the training loaders; read on-disk
corpus/adapter/ledger JSON; read-only MCP (`doorman_health`, `get_service_status`,
`get_corpus_stats`, `query_datagraph`). Never: any POST/mutation, live
`run-*-training.py`, Tier-B GPU spend, file edits.

## 2. Live baseline (read-only)

```bash
# Doorman + tier state, queue depth
curl -s :9080/readyz | jq '{tier_a, tier_b, queue_pending, queue_poison}'
# Graph health + entity count
curl -s :9081/healthz
# Graph context per module — note which modules actually hold data
for m in woodfine jennifer foundry default ""; do
  echo "module=$m"; curl -s ":9081/v1/graph/context?q=Woodfine&module_id=$m&limit=10" | jq length
done
```

If the default/queried module returns empty while `woodfine`/`jennifer` return
matches, graph-context injection is a no-op for default callers — record it.

## 3. Training-loop checks

- **Target modules:** confirm `run-sft-training.py` and `run-dpo-training.py` use
  the base model's actual leaf names (HF OLMo-2/3 use `q_proj…down_proj`; the
  legacy `att_proj/ff_proj` names match nothing on an HF base). Both scripts must
  assert post-build that the trainable-parameter share is non-zero (0.01–1%).
- **Learning rate:** SFT-LoRA in `1e-4..3e-4`; `2e-5` is a full-fine-tune default
  and under-fits an adapter.
- **Eval gate:** `eval-adapter.sh` must run **inside** the cycle and gate
  promotion on a base-vs-adapter delta (≥20 probes; null delta = inactive = FAIL)
  plus apply-clean / `cargo check` / EM (diff) or strict IOB2 F1 (extraction)
  against a frozen, version-hashed gold set. Promote only on ≥+1.0 pt over the
  incumbent; promote the **best** checkpoint, not the last.
- **Serving:** confirm the served base matches the adapter's `base_model_name`,
  and that the adapter is loaded (`--lora-scaled` / `--enable-lora`).
- **Corpus:** `corpus-threshold.py --dry-run` should emit a composition scorecard
  (per-task histogram, near-dup rate, clean-pair count) — not a raw tuple count —
  and gate on a clean, diverse-pair floor, not 50.

## 4. DataGraph checks

- **Entity resolution:** read `graph.rs` `normalize_entity_key`/`upsert_entities`.
  Exact-key normalisation alone is not ER; look for an alias table and a
  similarity/clustering stage. Probe known hard pairs ("Peter" vs "Peter M.
  Woodfine"; trademark/legal-suffix variants).
- **Edges:** confirm `RelatedTo` is populated, not declared-and-empty, and that a
  relation-extraction pass exists.
- **Provenance:** each entity should carry source document, extractor tier, run
  id, confidence and an un-overwritten timestamp; MERGE must not blind-overwrite.
- **Schema↔prompt drift:** the extraction prompt, the graph schema, and the
  validator must agree on fields; track per-field fill-rate (identity-tier NULL =
  defect).

## 5. Adversarial verification

Every FAIL finding is re-checked by two independent passes that try to **disprove**
it via a *different* evidence channel than the original (a different file, a GET
endpoint, a re-grep). Admit a finding only if both refutations fail; otherwise
downgrade it to a hypothesis needing a sanctioned live run.

## 6. Sanctioned live runs (operator-gated)

These need explicit go-ahead and the trainer VM (yoyo-batch; subject to L4
capacity): prove the target-module mismatch on the real base; `--dry-run`
clean-pair count and token p50/p95; a capped train + base-vs-adapter delta-probe;
and a per-class entity histogram + `RelatedTo` row count via a sanctioned
read-only DB query.

## 7. Building toward the target system

This guide is the *audit* procedure; the *build* sequence toward a sophisticated
ontological DataGraph and an always-on training loop is tracked in the flow
build-plan brief. The foundation phase (the reversible fixes — correct target
modules, pin one base model, wire the eval gate and adapter serving, split the
interactive and batch runtimes so training never starves serving) is the
prerequisite: the always-on loop cannot run until a trained adapter is servable on
the served base and an inference slot is free. Once the foundation is green, the
same gate discipline in this guide governs every promotion — an adapter promotes
only on a measured eval win, and a graph extraction batch promotes only when its
SHACL shapes validate after reasoning.

## 8. Verification results — 2026-06-28

The following tests were run against the live stack on 2026-06-28 after deploying EQ fixes
(EQ1+EQ2 grammar/temperature/max_tokens, EQ4 preprocessing, EQ5 chunking, GlinerOutcome enum).

**T1 — GLiNER Tier 0 live extraction**

```bash
curl -s http://127.0.0.1:9085/v1/extract \
  -H "Content-Type: application/json" \
  -d '{"text":"Blackstone has been refurbishing Broadgate Quarter near Liverpool Street...","domain_id":"projects"}'
```

Result: 4 entities returned (Blackstone/Company, Broadgate Quarter/Project, Liverpool Street/Location,
James Rosenfeld/Person). Latency: 208 ms. PASS.

**T2 — Doorman Tier A grammar constraint**

Confirmed via live drain log:
```
[entity_filter] module=jennifer kept=7/7 drop=field_missing:0 empty:0 noise:0 word_count:0 coerce:0 oov:0
```
`drop=field_missing:0` across 82 jennifer-module extractions today (pre-fix: field_missing was non-zero
on ~50% of completions). Grammar constraint eliminating all schema-violation outputs. PASS.

**T3 — End-to-end write→read round-trip**

```bash
# Write via mutate endpoint
curl -s http://127.0.0.1:9081/v1/graph/mutate \
  -d '{"module_id":"jennifer","entities":[{"entity_name":"Hamid Moghadam",...}]}'
# Read back via context endpoint
curl -s "http://127.0.0.1:9081/v1/graph/context?q=Hamid+Moghadam&module_id=jennifer&limit=5"
```

Entity written and read back immediately (no restart required) — CHECKPOINT in drain thread
making OS-thread writes visible to HTTP tokio reads. PASS.

**T4 — GlinerOutcome::Empty drain throughput**

Confirmed via live service logs: 3,440+ files drained via Empty path at ~1/sec
(vs. ~1/30s via Tier A fallback path). CSV, JSON, and code files all marked done
in a single pass without calling OLMo. PASS.

**Quality scorecard**

| Metric | Before EQ fixes | After EQ fixes (2026-06-28) |
|---|---|---|
| Entities per CRE article | ~3 (with hallucinations) | 5–9+ (no hallucinations) |
| `field_missing` drops | Non-zero (~50% of extractions) | 0 across 82 extractions |
| Long articles (>2,000 chars) | First 2,000 chars only | All chunks (EQ5 chunking) |
| CSV/structured-data files | Deferred indefinitely (backpressure loop) | Marked done in ~1 sec |
| Empty-path drain throughput | ~1/30s (Tier A fallback) | ~1/sec (GlinerOutcome::Empty) |
| Entity count growth (today) | Slow | +106 entities (11,982 → 12,088) |

**What the flow contains as of 2026-06-28:** The CORPUS ledger (84,450 files) consists primarily
of engineering session transcripts. Only 2 jennifer-domain CRE files are present. The extraction
infrastructure (GLiNER → DataGraph → training) is confirmed working; feeding it actual CRE research
content requires wiring `service-input` to jennifer CRE article sources, which is a separate
provisioning task.
