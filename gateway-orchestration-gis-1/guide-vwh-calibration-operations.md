# VWH Calibration Validation

This guide documents the validation criterion for each Vertical Warehouse (VWH)
production build and describes how to confirm the build met the calibration threshold.

## Validation threshold

A calibrated VWH build must place hardware anchors within **3 km** of at least
**73%** of T1 and T2 clusters in the output dataset.

This threshold was established through the June 2026 calibration run using
hardware store locations (Home Depot, Leroy Merlin, OBI, Bauhaus class) as proxy
anchors. The ratio reflects the empirically observed co-location rate between
confirmed VWH sites and hardware anchor presence in the reference dataset.

## How to verify a build

After running `build-vwh-clusters.py`, the calibration check is performed by
`sim-vwh-colocation.py`:

1. Run the simulation script against the output GeoJSON:
   ```
   python app-orchestration-gis/sim-vwh-colocation.py
   ```
2. Inspect the hardware validation line in the output:
   ```
   hardware validation: XX.X% PASS
   ```
3. Confirm the percentage is ≥ 73.0%.

If the result is below 73%, the build has drifted from the calibration baseline.
Common causes: new chain ingests that added non-VWH POIs to cluster membership,
EPS parameter change, or hardware chain JSONL data loss.

## June 2026 reference build

The reference calibration run (2026-06-11) produced:

| Metric | Value |
|---|---|
| Hardware validation rate | 73.4% |
| Result | PASS |
| Cluster count | 6,368 |
| T1 | 852 (13.4%) |
| T2 | 1,327 (20.8%) |
| T3 | 4,189 (65.8%) |
| `retail_contamination` flag rate | 47.9% |

## Related

- `app-orchestration-gis/sim-vwh-colocation.py` — calibration simulation script
- `work/hardware-colocation-profile.json` — hardware co-location profile (reference build)
- Archetype definition: [Vertical Warehouse (VWH)](https://documentation.pointsav.com/archetypes/vertical-warehouse)
