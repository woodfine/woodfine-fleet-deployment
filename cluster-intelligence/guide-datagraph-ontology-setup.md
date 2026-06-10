---
schema: foundry-doc-v1
title: "Configure the DataGraph ontology for service-content"
slug: guide-datagraph-ontology-setup
type: guide
section: ai-and-intelligence
status: active
bcsc_class: no-disclosure-implication
last_edited: 2026-06-10
editor: pointsav-engineering
---

# Configure the DataGraph ontology for service-content

service-content maintains the organizational knowledge graph. The ontology
controls what entity types are recognized, how accounts are classified,
what domains are active, and what glossary terms are resolved. This guide
covers editing the ontology CSV files, live-reloading the ontology, and
verifying entity counts after a change.

## Ontology directory structure

```
service-content/
└── data/
    └── ontology/
        ├── archetypes.csv      # Entity archetypes and their classification rules
        ├── chart-of-accounts.csv  # Financial account categories
        ├── domains.csv         # Active domain vocabulary
        └── glossary.csv        # Term definitions and canonical names
```

All four files are hot-reloaded — no service restart required after an
edit. The reload endpoint triggers an in-memory parse; invalid CSV aborts
the reload and leaves the previous ontology in place.

## Editing archetypes.csv

Each row defines an entity archetype that the extraction pipeline
recognizes:

```
archetype,description,parent,active
person,Human individual,root,true
organization,Legal entity,root,true
project,Active work initiative,root,true
asset,Managed resource,root,true
```

Rules:
- `archetype` is the canonical name; must be unique and lowercase.
- `parent` must reference a defined archetype in the same file (`root`
  is the implicit top-level).
- Set `active: false` to stop recognizing that archetype in new
  extractions (existing graph nodes are not deleted).

## Editing chart-of-accounts.csv

Maps financial account names to their classification:

```
account_name,classification,active
Revenue,income,true
Operating Expenses,expense,true
Capital Assets,asset,true
```

Used by service-content's financial-entity extraction pass. Accounts not
listed here are extracted under classification `unclassified`.

## Editing domains.csv

Controls which semantic domains the extraction pipeline indexes:

```
domain,description,active
legal,Corporate and contract records,true
financial,Financial data and accounts,true
infrastructure,Technical infrastructure,true
personnel,Workforce and contacts,true
```

Inactive domains are excluded from new indexing runs; their existing
graph nodes remain queryable.

## Editing glossary.csv

Term definitions drive canonical-name resolution — when an extraction
encounter an alias, it resolves to the canonical term:

```
term,canonical,aliases,definition
service-slm,service-slm,"SLM service,local AI,local model",Local inference service
service-content,service-content,"knowledge graph,content service",Organizational knowledge graph service
```

`aliases` is a comma-separated list enclosed in double quotes when it
contains commas.

## Live reload

After editing any CSV file, trigger a reload without restarting the service:

```bash
curl -X POST http://127.0.0.1:9081/admin/ontology/reload
# Expect: {"status":"ok","loaded_at":"2026-06-10T..."
```

If the CSV contains an error, the response is:
```json
{"status":"error","message":"archetypes.csv line 7: unknown parent 'bad-parent'"}
```
Correct the file and retry. The previous ontology remains active until
a successful reload.

## Verify entity counts after reload

```bash
curl -s http://127.0.0.1:9081/v1/stats | python3 -m json.tool
```

Expected shape:
```json
{
  "entity_counts": {
    "person": 1024,
    "organization": 312,
    "project": 87,
    "asset": 204
  },
  "domains_active": ["legal","financial","infrastructure","personnel"],
  "ontology_loaded_at": "2026-06-10T10:41:00Z"
}
```

A count of 0 for an archetype that previously had entries indicates a
parse error — check the reload response and service logs.

## Adding a new classification

To add a new entity archetype (e.g., `vendor` as a child of `organization`):

1. Add a row to `archetypes.csv`:
   ```
   vendor,External supplier or service provider,organization,true
   ```
2. Reload: `curl -X POST http://127.0.0.1:9081/admin/ontology/reload`
3. Verify the new archetype appears in `/v1/stats`.
4. Run a targeted extraction pass to populate entities of the new type:
   ```bash
   curl -X POST http://127.0.0.1:9081/admin/extract/run \
     -H "Content-Type: application/json" \
     -d '{"archetype":"vendor"}'
   ```

## Troubleshooting

| Symptom | Check |
|---|---|
| Reload returns 500 | Check `journalctl -u local-content.service --since=-2m` for parse errors |
| Entity counts unchanged after reload | Extraction runs on a schedule; trigger manually with `/admin/extract/run` |
| Alias not resolving to canonical | Verify alias is in `glossary.csv` and reload was successful |
| Domain missing from `domains_active` | Check `active` column in `domains.csv` — must be `true` (case-sensitive) |
