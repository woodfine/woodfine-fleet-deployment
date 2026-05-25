---
schema: foundry-doc-v1
title: "Guide: GIS Pipeline Rebuild"
slug: guide-gis-pipeline-rebuild
category: gateway-orchestration-gis
type: guide
section: gis-and-geospatial
quality: complete
status: active
audience: customer-operator
bcsc_class: current-fact
language_protocol: PROSE-GUIDE
last_edited: 2026-05-25
editor: pointsav-engineering
cites: []
---

This guide documents the end-to-end procedure for rebuilding the GIS pipeline from raw ingested data to the live deployment artefacts that serve `gis.woodfinegroup.com`. A full rebuild takes approximately ten minutes on the May 2026 deployment footprint.

## When to Rebuild

A full rebuild is required after any of:

- A new chain is ingested (new YAML + new JSONL data).
- An existing chain's ingest is refreshed (e.g., after an OpenStreetMap improvement campaign).
- A change to the cluster-formation algorithm in `build-clusters.py`.
- A change to the scoring algorithm in `generate-rankings.py`.
- A change to the brand-family taxonomy in `build-tiles.py`.
- A change to the region engine in `utils/region_engine.py` — a build-clusters re-run is required; tile rebuild alone is insufficient.

A partial rebuild — running only `build-tiles.py --layer 2` to refresh the cluster meta JSON — suffices when the only change is to the meta-JSON schema or the inspector panel renders, with no underlying data change.

## The Five Stages

The pipeline is five sequential stages. Each stage has one primary input and one primary output; later stages depend on earlier stages.

### Stage 1 — Ingest

Pull retail and civic data from OpenStreetMap via the Overpass API.

```bash
cd pointsav-monorepo/app-orchestration-gis
python3 ingest-osm.py --chain <chain_id_1> <chain_id_2> ...
```

Per chain: 30–90 seconds for a country-scale bounding box. The ingest applies a polygon-containment filter to drop cross-border records.

Failure modes:

- **Overpass timeout.** Three Overpass instances are tried in order; if all three fail the chain is skipped. Re-run later.
- **Wikidata returns zero.** The ingest falls back to the `name_query` field if set. If neither query returns records, the chain produces an empty JSONL and a console warning.
- **Country bbox missing.** New countries require an entry in `COUNTRY_BBOX` (see `guide-gis-adding-a-country.md`).

### Stage 2 — Cluster Entities

Deduplicate raw OpenStreetMap records across chain boundaries and within-chain sub-locations.

```bash
python3 ../../service-business/cluster-entities.py
```

About 30 seconds. Two passes: same-chain spatial clustering at 200 m, then cross-brand QID dedup at 50 m. Output is `cleansed-clusters.jsonl` — the input to all subsequent stages.

This stage must run after any Stage 1 ingest. Skipping it means subsequent stages operate on a stale cleansed file.

### Stage 3 — Build Clusters

Form co-location clusters from the cleansed data, applying the anchor-secondary-tertiary methodology.

```bash
python3 build-clusters.py
```

About 60 seconds. Reads `cleansed-clusters.jsonl`. For each anchor-class store, evaluates secondary stores within 1 km and tertiary stores within 3 km. Assigns categorical tier composition and tier descriptor. Writes `work/clusters.geojson`.

Console lines to watch:

- `business: N records, places: M records` — input record counts after cleansing.
- `Tier-1 rate at 3km: NN.N%` — calibration gauge. Above 12% consider tightening the secondary radius; below 8% the methodology may be too restrictive.

### Stage 4 — Generate Rankings

Apply the scoring algorithm, deduplication threshold, and ranking pass.

```bash
python3 generate-rankings.py
```

About 20 seconds. Reads `work/clusters.geojson`, applies dedup at 0.15 km, computes scores, assigns tiers (with country-saturation guard), assigns rankings within country, within continent, within tier. Writes back to `work/clusters.geojson`.

Console lines to watch:

- `1172 duplicates removed → 6422 clusters` — dedup count (numbers vary by run).
- `Score range: 0–730` — sanity check that scoring is well-formed.

### Stage 5 — Build Tiles

Generate the PMTiles and the clusters-meta.json that the live deployment serves.

```bash
python3 build-tiles.py --layer all
```

About four minutes for a full rebuild. Three layers:

- **Layer 1** (locations): individual store dots, Tippecanoe-built. ~500 MB output. Layer 1 merges three sources: service-business JSONL (retail chains), Overture service-places (hospital, university, airport), and OpenStreetMap civic data (hospital + university). All three must be present; a missing civic OpenStreetMap file produces no error but silently omits hospital and university records from the map.
- **Layer 2** (clusters): cluster bubbles + clusters-meta.json. ~43 MB tile + ~3 MB JSON.
- **Layer 3** (radius): proximity ring shapes. ~100 MB output.

For incremental work, restrict to one or two layers:

```bash
python3 build-tiles.py --layer 2  # cluster meta refresh, ~30s
python3 build-tiles.py --layer 1  # locations refresh, ~3 minutes
```

Output is written directly to the deployment www directory; no separate sync step is needed.

## Verification

After the full rebuild:

```bash
python3 check-chain-counts.py
```

Output shows raw / cleansed counts per chain against the YAML `store_count_approx`. Status flags: OK (within ±20%), OVER (raw above 120%), UNDER (raw below 80%), EMPTY (zero records).

For live verification:

```bash
curl -s https://gis.woodfinegroup.com/data/clusters-meta.json | wc -c
```

This should return roughly the byte count of the most recent `clusters-meta.json` build (printed at the end of Stage 5). If the live size diverges from the local size, the deployment www directory was not updated — investigate.

## Common Failure Modes

**Stage 4 reports zero clusters.** Stage 2 was skipped or failed. The cleansed JSONL is missing or stale. Re-run Stage 2.

**Stage 5 layer 1 takes 20 minutes instead of 3.** Tippecanoe is processing a corrupted GeoJSON. Inspect `work/layer1-locations.geojson` for empty geometries or NaN coordinates.

**Live URL shows yesterday's data.** The deployment www directory was not refreshed — check write permissions or re-run Stage 5 with verbose flags.

**`check-chain-counts.py` shows new OVER for a chain that was OK previously.** OpenStreetMap may have added cross-border records the polygon filter does not catch. Inspect the JSONL for outlier latitudes and longitudes; tighten the country bbox in `ingest-osm.py` if the bounding box is too loose.

## Stage 6 — O-D Study and Catchment Layers

This stage is required when census or spend data has been updated, or when catchment radius parameters change. It is independent of Stages 1–5 and can be run separately.

### Step A — Synthesize O-D Catchment Data

Computes primary (≤35 km) and secondary (35–150 km) catchment populations and spend for all clusters. Also ranks clusters and updates `clusters-meta.json`.

```bash
python3 synthesize-od-study.py
```

About 15–25 minutes. Reads `census-h3-res7.jsonl` and `cleansed-spend-h3-res7.jsonl` from `service-fs/`. Iterates all clusters, computing H3 grid disks at resolution 7.

Failure modes:
- **h3 not installed**: `pip install h3` in the project Python environment.
- **clusters-meta.json missing catchment fields after run**: Check that the merge loop matched cluster IDs correctly.

### Step B — Build Catchment Polygon Layer

Generates two circular polygons per cluster (primary 35 km, secondary 150 km) for the map catchment layer.

```bash
python3 build-catchment-polygons.py
tippecanoe -o /srv/foundry/deployments/gateway-orchestration-gis-1/www/tiles/layer3-catchment.pmtiles \
  --force --layer catchment --minimum-zoom 3 --maximum-zoom 10 \
  --drop-densest-as-needed \
  pointsav-monorepo/app-orchestration-gis/work/catchment-polygons.geojson
```

About 1 minute.

### Step C — Build Census and Spend Data Tile Layers

Generates H3 hexagon polygon layers for census and spend, masked to catchment areas.

```bash
python3 build-data-tiles.py
```

About 20–30 minutes. Outputs `layer4-census.pmtiles` and `layer5-spend.pmtiles` directly to the deployment tiles directory.

## See Also

- [Adding a New Chain to the GIS Pipeline](guide-gis-adding-a-chain.md)
- [Adding a Country to the GIS Pipeline](guide-gis-adding-a-country.md)
