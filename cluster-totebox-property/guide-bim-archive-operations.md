---
schema: foundry-doc-v1
title: "BIM Archive Operations"
slug: guide-bim-archive-operations
type: guide
status: active
bcsc_class: customer-internal
last_edited: 2026-05-07
editor: pointsav-engineering
---

## Prerequisites

- `IfcOpenShell` ≥ 0.7.0 installed on the deployment host:
  ```bash
  python3 -m pip install ifcopenshell
  python3 -c "import ifcopenshell; print(ifcopenshell.version)"
  # Must return 0.7.0 or higher; earlier versions silently downgrade IFC4X3 schema
  ```
- `ifctester` installed:
  ```bash
  python3 -m pip install ifctester
  ```
- `bcfpython` installed (for BCF 3.0 issue operations):
  ```bash
  pip install bcfpython
  ```
- `ifccsv` installed (for COBie export):
  ```bash
  python3 -m pip install ifccsv
  ```
- Vault root accessible at `<vault>/` (e.g., `/opt/foundry/vaults/cluster-totebox-property-1/`).
- Git configured with write access to the vault repository.

## Purpose

This guide covers operating a Totebox Archive instance — the long-term IFC model and
documentation vault for a building asset. It covers the vault directory structure, model
ingestion, COBie and IDS export, BCF 3.0 issue management, and log rotation.

All commands use `<vault>/` as the vault root. All paths are relative to that root
unless stated otherwise.

## Procedure

### Vault Layout

A Totebox Archive vault has a fixed directory structure. Do not add or move top-level
directories; tooling reads from fixed paths.

```
<vault>/
├── MANIFEST.md                ← Vault identity, asset metadata
├── README.md                  ← English description
├── README.es.md               ← Spanish description
├── ifc/                       ← IFC model files by discipline
│   ├── architectural/
│   ├── structural/
│   ├── mechanical/
│   └── combined/
├── elements/                  ← Per-element JSON records (IfcGloballyUniqueId index)
├── bcf/                       ← BCF 3.0 issue files
├── ids/                       ← IDS constraint files for this asset
├── materials/                 ← Material specification sheets
├── codes/                     ← Regulatory documentation (PDFs, web archives)
├── geometry/                  ← Auxiliary geometry (DXF, DWG, survey)
├── drawings/                  ← 2D production drawings (PDF)
├── objects/                   ← BIM object specifications
├── refs/                      ← External references and permits
└── logs/                      ← Operation logs (auto-generated)
```

`MANIFEST.md` declares:

```yaml
asset_id: cluster-totebox-property-1
asset_name: "Woodfine Property Asset — Site 1"
ifc_schema: IFC4X3
created: <ISO date>
last_ingestion: <ISO date>
model_guids:
  architectural: <IfcProject GUID>
  structural: <IfcProject GUID>
```

### Model Ingestion

Ingestion adds a new IFC model or model update to the vault.

**1. Validate the incoming IFC file.**

Before ingesting, validate the file against the vault's registered IDS constraints:

```bash
ifctester --ids <vault>/ids/<overlay-id>.ids \
          --ifc <path-to-incoming.ifc> \
          --report json \
          --output <vault>/logs/validation-<YYYY-MM-DD>.json
```

A pass is required for ingestion. If failures exist, return the model to the design team
with the validation report.

**2. Extract per-element records.**

Parse the IFC file and write one JSON record per element to `elements/`:

```python
import ifcopenshell, json, os

model = ifcopenshell.open("incoming.ifc")
elements_dir = "<vault>/elements/"

for element in model.by_type("IfcElement"):
    record = {
        "guid": element.GlobalId,
        "type": element.is_a(),
        "name": element.Name,
        "psets": {}
    }
    for rel in element.IsDefinedBy:
        if rel.is_a("IfcRelDefinesByProperties"):
            pset = rel.RelatingPropertyDefinition
            if pset.is_a("IfcPropertySet"):
                props = {p.Name: str(p.NominalValue) for p in pset.HasProperties
                         if hasattr(p, "NominalValue")}
                record["psets"][pset.Name] = props

    with open(os.path.join(elements_dir, f"{element.GlobalId}.json"), "w") as f:
        json.dump(record, f, indent=2)
```

**3. Copy the IFC file to the vault.**

```bash
cp incoming.ifc <vault>/ifc/architectural/architectural-v<n>.ifc
```

Use sequential version numbers (`v1`, `v2`) — not dates. The git commit history
provides the date record.

**4. Commit the ingestion.**

```bash
cd <vault>
git add ifc/ elements/ logs/
git commit -m "ingest: architectural model v<n> — <brief description>"
```

**5. Update MANIFEST.md.**

```bash
# Edit MANIFEST.md to update last_ingestion and model_guids
git add MANIFEST.md
git commit -m "manifest: update last_ingestion + model GUID for architectural v<n>"
```

### COBie Export

COBie (Construction Operations Building Information Exchange) is the facility handover
data format required by US and UK government clients.

```bash
python3 -m ifccsv \
    -i <vault>/ifc/combined/combined-v<n>.ifc \
    -s COBie \
    -o <vault>/refs/COBie-v<n>.xlsx
```

Verify the output spreadsheet contains: Facility, Floor, Space, Type, Component,
System, Connection, Attribute, Document, Coordinate sheets; no empty
`ExternalIdentifier` cells in the Component sheet.

```bash
git add refs/COBie-v<n>.xlsx
git commit -m "export: COBie v<n> from combined model"
```

### IDS Validation Export

Generate a full validation report for regulatory submission:

```bash
ifctester \
    --ids <vault>/ids/<jurisdiction>-<overlay-id>.ids \
    --ifc <vault>/ifc/combined/combined-v<n>.ifc \
    --report html \
    --output <vault>/refs/ids-validation-<jurisdiction>-<YYYY-MM-DD>.html
```

The HTML report is suitable for direct submission to building permit authorities in
jurisdictions that accept IDS-based compliance reports.

### BCF 3.0 Issue Export

BCF (BIM Collaboration Format) files record design issues referencing specific model
elements by GUID. To export all open issues as a single BCF 3.0 zip for exchange with
a consultant:

```bash
python3 - <<'EOF'
import bcf.v3.bcf_file as bcf_file
import glob

b = bcf_file.BcfFile()
for f in glob.glob("<vault>/bcf/*.bcf"):
    b.add_topic_from_file(f)
b.save("<vault>/refs/issues-export-<YYYY-MM-DD>.bcfzip")
EOF
```

### BCF 3.0 Issue Authoring

To record a new design issue referencing a model element:

```bash
python3 - <<'EOF'
import bcf.v3.bcf_file as bcf_file
import datetime

b = bcf_file.BcfFile.load("<vault>/bcf/issues.bcf")
topic = b.add_topic(
    title="Wall ThermalTransmittance below BCBC 2024 requirement",
    description="IfcWall GUID=<guid> has ThermalTransmittance=0.300, limit is 0.210",
    author="task@project-bim",
    date=datetime.datetime.now().isoformat()
)
topic.reference_object(guid="<ifcGloballyUniqueId>")
b.save("<vault>/bcf/issues.bcf")
EOF

git add bcf/
git commit -m "bcf: add wall thermal transmittance issue <short-id>"
```

### Log Rotation

Rotate validation logs older than 90 days to `logs/archive/`:

```bash
find <vault>/logs/ -maxdepth 1 -name "*.json" -mtime +90 \
    -exec mv {} <vault>/logs/archive/ \;
git add logs/
git commit -m "logs: rotate validation logs older than 90 days"
```

## Expected Outcome

After a successful ingestion cycle:

- `<vault>/ifc/<discipline>/` contains the new model file at the next sequential version.
- `<vault>/elements/` contains one JSON record per `IfcElement` in the ingested model.
- `<vault>/logs/` contains a validation report with `"status": "pass"`.
- `MANIFEST.md` reflects the updated `last_ingestion` date and `model_guids`.
- `git log` shows two commits: the ingestion commit and the manifest update commit.

## Verification

```bash
# Confirm validation passed
python3 -c "
import json
r = json.load(open('<vault>/logs/validation-<YYYY-MM-DD>.json'))
print('Status:', r.get('status'))
"
# Expected: Status: pass

# Confirm element records written
ls <vault>/elements/ | wc -l
# Expected: non-zero; count matches element count in the IFC model

# Confirm git history
cd <vault> && git log --oneline -3
# Expected: manifest update commit on top, ingestion commit below
```

## Rollback

To undo an ingestion (before any dependent exports are committed):

```bash
cd <vault>
git revert HEAD --no-edit   # reverts manifest update
git revert HEAD~1 --no-edit # reverts ingestion commit
```

If the ingestion has already been used to generate exports that were committed, revert
each export commit individually in reverse order before reverting the ingestion commit.
