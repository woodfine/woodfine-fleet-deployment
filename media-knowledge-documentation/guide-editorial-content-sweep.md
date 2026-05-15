---
schema: foundry-doc-v1
title: "Monthly Editorial Content Sweep"
slug: guide-editorial-content-sweep
type: guide
status: active
audience: editorial-operators
bcsc_class: current-fact
last_edited: 2026-05-08
editor: pointsav-engineering
---

# Guide — Monthly Editorial Content Sweep

**Project:** `media-knowledge-documentation`
**Applies to:** All three Foundry wikis — corporate, projects, documentation

The monthly editorial content sweep updates all TOPIC and GUIDE articles against the current state of the DataGraph — the property graph database that accumulates knowledge about every entity in the platform. Each sweep takes articles one level higher in quality. The sweep runs in five sequential steps. Do not reorder them.

---

## Overview

The sweep has two distinct inputs and one output:

| Input | Source |
|---|---|
| **How to write** (register, vocabulary, structure) | RESEARCH corpus → language tokens at `pointsav-design-system/tokens/language/` |
| **What to say** (substance, relationships, context) | DataGraph — entity relationships, domain taxonomy, theme connections |

**Output:** updated TOPIC and GUIDE articles that express DataGraph knowledge in the correct register for each wiki's audience.

**Calibration:** the goal for each article is "draft 2 of 10" — good enough that the next automated inference pass produces a clearly better draft 3. Do not attempt final versions. The compounding improvement cycle handles quality over time.

---

## Step 1 — Read the RESEARCH corpus

Before writing or rewriting anything, read the positive language examples. These ground the language tokens in observed patterns, not invented rules.

**Read in this order:**

```text
deployments/vault-privategit-design-1/research/
├── brand-voice.md
├── design-philosophy.md
├── primitive-vocabulary-rationale.md
├── wikipedia-leapfrog-2030.md
└── (any other files in this directory)
```

Also read as positive examples:
```text
customer/content-wiki-corporate/     # all 5 articles — correct Bloomberg/FT register
customer/content-wiki-projects/topic-co-location-methodology.md
customer/content-wiki-projects/topic-zoning-acquisition-rules.md
```

**Extract and note:**
- Lead sentence patterns — how does the first sentence of a correct article begin?
- Sentence length — target range, hard maximum
- How is technical depth introduced for a non-technical reader?
- Which vocabulary choices recur in correct examples?
- What is absent from correct examples that appears in incorrect ones?

**Output:** a short annotated list — lead patterns, vocabulary, sentence structure — that Step 2 tokens will encode. Keep it in a session note, not a committed file.

---

## Step 2 — Author language tokens

With Step 1 findings in hand, author the language token files at:

```text
vendor/pointsav-design-system/tokens/language/
├── register-corporate.json
├── register-documentation.json
├── register-specialist.json
├── vocabulary-banned-corporate.json
├── vocabulary-banned-documentation.json
├── crossref-specialist-sites.json
├── template-topic-lead-corporate.json
└── template-topic-lead-documentation.json
```

**Register token scope** — each file encodes what Step 1 found:
- Sentence length constraints (min, target, max)
- Lead structure rules (consequence-first, active voice)
- Vocabulary rules (banned terms, required replacements)
- Code block rules (never in corporate/projects; real and runnable in documentation)
- Citation style (financial sources for corporate; technical documentation for documentation)

**Specialist-sites crossref token** — the canonical link patterns for the three specialist sites:
- `bim.woodfinegroup.com` — BIM token specifications, IFC mappings, climate zone parameters
- `gis.woodfinegroup.com` — co-location scoring methodology, zoning criteria
- `design.pointsav.com` — design token schemas, component specifications

**Scope limit:** enough for the inference system to score articles and generate register-correct first sentences. Not exhaustive style guides. Not grammar rules for every possible construction. Three to five lead sentence patterns per register is sufficient for the first sweep.

**Owner:** project-design Task — submit via outbox if working from project-editorial cluster.

---

## Step 3 — Read the DataGraph for content briefs

For each article targeted for rewrite, look up the corresponding entity in the DataGraph. Use these sources:

```text
clones/project-editorial/.agent/artifacts/datagraph-content-reconciliation-2026-05-07.md
vendor/pointsav-monorepo/service-content/ontology/topics/topics_documentation.csv
vendor/pointsav-monorepo/service-content/ontology/topics/topics_corporate.csv
vendor/pointsav-monorepo/service-content/ontology/topics/topics_projects.csv
deployments/vault-privategit-design-1/research/   # what the RESEARCH corpus says about this domain
```

**Extract for each entity:**
- What domain does it belong to? (documentation, corporate, projects)
- What other entities connect to it, and by what edge type? (operates, deploys, serves)
- What themes span it? (monthly improvement cycle, operator-controlled compute, co-location mandate)
- What does the RESEARCH corpus say about this domain?
- What is the consequence framing for the primary audience of its wiki?

**Output:** a one-paragraph content brief per article: "what the DataGraph knows that this article does not currently say." This is the substance the rewrite will add. Keep briefs in a session note.

---

## Step 4 — Domain cleanup in service-content CSVs

Fix structural bugs in the DataGraph ontology CSV files before the rewrite so the DataGraph Yo-Yo inference passes have clean taxonomy to work with.

**Owner:** project-intelligence or project-data Task. If running from project-editorial, submit the work via outbox — do not run CSV commits and wiki article commits in the same session.

**Bugs to fix:**
```text
vendor/pointsav-monorepo/service-content/ontology/topics/topics_corporate.csv
→ wiki_repo: correct all entries from "content-wiki-documentation" to "content-wiki-corporate"
→ wiki_path: update all entries from "topics/topic-*.md" to "<category>/<slug>.md"

vendor/pointsav-monorepo/service-content/ontology/topics/topics_projects.csv
→ wiki_repo: correct all entries from "content-wiki-documentation" to "content-wiki-projects"
→ wiki_path: update all entries from "topics/topic-*.md" to "<category>/<slug>.md"

vendor/pointsav-monorepo/service-content/ontology/topics/topics_documentation.csv
→ wiki_path: update all entries from "topics/topic-*.md" to "<category>/<slug>.md"
→ doorman-protocol: mark active_state as "active" (article published at architecture/doorman-protocol.md)
```

**Register all existing content:**
- Add all ~251 unclassified wiki articles to the correct domain CSV with `active` state and `wiki_path`
- Create `guides_documentation.csv` — register all ~72 GUIDEs as DataGraph entities per `conventions/datagraph-guide-entity-class.md`
- Register RESEARCH corpus documents (`vault-privategit-design-1/research/`) as `research-document` entities

**Patch `domains.csv`:** add the `documentation` domain row as required by the GUIDE entity class convention.

---

## Step 5 — DataGraph-informed rewrite

With tokens from Step 2 and content briefs from Step 3, rewrite each article.

**Per article — in order:**

1. Read the current article
2. Read the content brief (Step 3) — what does the DataGraph know that this article doesn't say?
3. Fix the lead sentence: consequence-first, register-correct, 14–18 words (corporate/projects) or no jargon (documentation)
4. Add "why it matters" for the primary audience at the top of each major section — one sentence, legible to the secondary audience
5. Pull in DataGraph relationships and theme connections that the brief identified
6. Retire vocabulary per the token files (vocabulary-banned-*)
7. Add crossref to specialist site if the article references BIM, GIS, or design specification content
8. Update the Spanish `.es.md` pair

**Time cap:** 15–30 minutes per article. This is a light enrichment pass, not a full rewrite. If an article needs more than 30 minutes, flag it as needing a dedicated session and move on.

**Rewrite priority order:**

| Priority | Target | Reason |
|---|---|---|
| 1 | Corporate wiki (5 articles) | Shortest; highest external visibility; bankers read these first |
| 2 | Projects wiki (34 articles) | Same institutional audience on different subject |
| 3 | Architecture + governance articles | Worst register violations; highest external exposure; core value proposition |
| 4 | Services, applications, reference articles | Lower urgency |
| 5 | GUIDEs | Engineering audience; register violations less costly |

**Highest urgency for architecture:**
- `architecture/compounding-substrate.md` — core value proposition; written for engineers
- `governance/ontological-governance.md` — data governance; impenetrable jargon
- `architecture/doorman-protocol.md` — AI boundary; full of internal service names
- `architecture/leapfrog-2030-architecture.md` — platform vision; needs Bloomberg-register lead

---

## What NOT to do

- Do not delete wiki articles because they are not in a DataGraph CSV. The wiki is richer than the CSVs; the fix is to add to the CSVs, not subtract from the wiki.
- Do not run CSV updates (Step 4) and wiki rewrites (Step 5) in the same git session. One session per `.git/index`.
- Do not use RIBA / IFC specification language in the main wikis. That register belongs on the specialist sites.
- Do not write full rewrites or add new sections. This is a light enrichment pass. The monthly inference cycle handles quality improvement over time.
- Do not skip Step 1 and Step 2 before Step 5. Tokens built without reading the corpus are speculation. Rewrites done without tokens have no consistent scoring criteria.

---

## Reference files

| File | Purpose |
|---|---|
| `.agent/artifacts/datagraph-content-reconciliation-2026-05-07.md` | Full DataGraph ↔ wiki reconciliation — all entity counts, gap table, GUIDE coverage |
| `.agent/artifacts/editorial-reference-plan-2026-05-08.md` | Standing editorial reference plan — framework, sequencing, do list |
| `pointsav-design-system/tokens/language/` | Language token files (Step 2 output) |
| `vendor/pointsav-monorepo/service-content/ontology/topics/` | DataGraph TOPIC taxonomy CSVs |
| `deployments/vault-privategit-design-1/research/` | RESEARCH corpus — positive language examples |
| `conventions/datagraph-guide-entity-class.md` | GUIDE entity class ratification (2026-05-07) |
