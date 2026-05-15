---
schema: foundry-doc-v1
title: "Guide: Adding a New Chain to the GIS Pipeline"
slug: guide-gis-adding-a-chain
deployment: gateway-orchestration-gis-1
type: guide
last_edited: 2026-05-07
editor: pointsav-engineering
bcsc_class: internal
---

This guide covers the end-to-end process for adding a new retail chain to the co-location intelligence platform. All commands run from the `pointsav-monorepo/app-orchestration-gis/` directory on the workspace VM.

---

## Step 1 — Create or verify the chain YAML

Each chain requires a YAML file at:

```text
/srv/foundry/deployments/cluster-totebox-personnel-1/service-fs/service-business/<chain-id>.yaml
```

**Critical YAML rules:**

- `country_code` must be a quoted string: `country_code: "NO"` — not `country_code: NO`. PyYAML parses unquoted two-letter codes that match boolean keywords (`NO`, `YES`, `ON`, `OFF`) as booleans. This causes `iso_country_code: false` in every ingested record, silently breaking cluster formation.
- `wikidata_id` is the Wikidata QID for the chain (e.g. `Q13556979` for IKEA). It drives the `brand:wikidata` Overpass query — the most reliable OSM filter for international chains. Set to `~` only when OSM tag coverage is genuinely sparse; a missing QID forces a slower, less precise name-match fallback. The `wikidata_id` value is also written as a flat `brand_wikidata` field in every ingested record, enabling reliable chain deduplication and future parent-child detection.
- `osm_overpass_tag` can be `~` (null) if the chain has sparse brand tag coverage in OSM.
- If the chain uses location-suffixed names in OSM (e.g. "Brand CityName" rather than "Brand"), set both `name_query` and `name_query_partial: true`. The partial flag triggers a prefix-regex Overpass query (`^Brand`) that captures all suffix variants.

**Example — chain with sparse wikidata tags:**

```yaml
chain_id: obs-bygg-no
country_code: "NO"          # quoted — prevents PyYAML boolean parse
wikidata_id: ~
osm_overpass_tag: ~
name_query: "Obs Bygg"
name_query_partial: true    # OSM names are "Obs Bygg Slitu", "Obs Bygg Tiller", etc.
locations_status: active
```

---

## Step 2 — Ingest from OSM

```bash
python3 ingest-osm.py --chain <chain-id>
```

The script tries `brand:wikidata=<id>` first; if that returns 0 elements, falls back to `name_query`. With `name_query_partial: true`, the query uses a regex prefix match.

Check record count:

```bash
wc -l /srv/foundry/deployments/cluster-totebox-personnel-1/service-fs/service-business/<chain-id>.jsonl
```

If 0 records: check the YAML for the boolean country_code bug, and try broadening the name query. If still 0, the chain may not be tagged in OSM for that country.

**ALPHA vs GENERIC criteria:**

| Classification | Condition | Effect |
|---|---|---|
| `ALPHA_HARDWARE` / `ALPHA_WAREHOUSE` | ≥ 20 ingested records; chain is a primary large-format anchor for its market | Counts toward T3/T2/T1 scoring; cluster rank depends on co-presence with ALPHA chains |
| `GENERIC_HARDWARE` / `GENERIC_WAREHOUSE` | Present in OSM but fewer than 20 records, or a secondary brand format not representative of a market anchor | Visible on the All Locations layer; does not affect cluster quality score |
| Not listed in config.py | Chain ingested but not yet classified | Included in layer 1 tiles only if chain YAML exists; invisible to cluster algorithm |

Promote to ALPHA only after confirming store count represents genuine national-scale presence. Regional chains with 6–19 locations stay GENERIC until coverage improves.

---

## Step 3 — Classify the chain in config.py

**File:** `pointsav-monorepo/app-orchestration-gis/config.py`

Add the chain to the appropriate set:

- `ALPHA_HARDWARE["EU"]` / `ALPHA_HARDWARE["NA"]` — primary large-format hardware anchor for a market
- `GENERIC_HARDWARE["EU"]` — present but not a primary market anchor
- `ALPHA_WAREHOUSE["EU"]` etc. — cash-and-carry / warehouse club
- `ALPHA_ANCHORS["EU"]` — large-format hypermarket or destination anchor

Add the chain to `REGION_CONFIG` under the appropriate country key, in the correct role list (`anchor`, `hardware`, or `warehouse`).

---

## Step 4 — Rebuild cleansed-clusters.jsonl

The build pipeline reads from a merged file, not directly from individual JSONLs. After any new ingest, run:

```bash
python3 /srv/foundry/clones/project-gis/pointsav-monorepo/service-business/cluster-entities.py
```

This reads all `*.jsonl` files in `service-fs/service-business/`, deduplicates records within 100 m of the same chain, and writes `service-business/cleansed-clusters.jsonl`. Skipping this step causes the new chain's records to be invisible to build-clusters.py.

---

## Step 5 — Rebuild the pipeline

Run in order from `pointsav-monorepo/app-orchestration-gis/`:

```bash
python3 build-clusters.py
python3 generate-rankings.py
python3 build-tiles.py
```

`build-radius.py` is optional unless cluster centroids shifted significantly (adds ~5 min; rebuilds 75 km catchment polygons).

---

## Step 6 — Update REGION_SUMMARY in index.html

After rebuild, compute new totals:

```bash
python3 -c "
import json
from collections import Counter
with open('work/clusters.geojson') as f:
    d = json.load(f)
na_isos = {'US','CA','MX'}
c1, c3 = Counter(), Counter()
for feat in d['features']:
    p = feat['properties']
    iso = p.get('iso','?')
    if p.get('rank_1km',0) > 0: c1['na' if iso in na_isos else 'eu'] += 1
    if p.get('rank_3km',0) > 0: c3['na' if iso in na_isos else 'eu'] += 1
print(f'NA 1km={c1[\"na\"]} 3km={c3[\"na\"]}')
print(f'EU 1km={c1[\"eu\"]} 3km={c3[\"eu\"]}')
"
```

Update the `REGION_SUMMARY` const in `pointsav-monorepo/app-orchestration-gis/www/index.html` to match. Deploy:

```bash
cp pointsav-monorepo/app-orchestration-gis/www/index.html \
   /srv/foundry/deployments/gateway-orchestration-gis-1/www/index.html
```

---

## Step 7 — Commit

```bash
git add pointsav-monorepo/app-orchestration-gis/config.py \
        pointsav-monorepo/app-orchestration-gis/www/index.html
~/Foundry/bin/commit-as-next.sh "GIS: add <chain-id> — <N> records, <outcome>"
```

Stage the YAML separately if it is tracked in the cluster repo. The JSONL and cleansed-clusters.jsonl are in the Totebox deployment (not tracked in Git).

---

## Appendix: Overture taxonomy field migration

The Overture Maps Foundation changed the category field schema in the 2025-11 release and removed the old `categories` field entirely in the 2026-06 release. If running an Overture ingest against a release dated 2025-11 or later, the DuckDB query in `ingest-overture.py` must use `taxonomy.primary` instead of `categories.primary`. The script in this repo was updated to `taxonomy.primary` on 2026-05-06; no further action needed unless the script is cloned from an older branch.

This change affects only the civic-places ingest (hospital, university, airport). Hardware and warehouse chain ingest uses the OSM Overpass API and is unaffected.
