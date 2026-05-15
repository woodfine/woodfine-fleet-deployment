---
schema: foundry-doc-v1
title: "Publishing a Regulatory Overlay"
slug: guide-regulation-overlay-publishing
type: guide
status: active
bcsc_class: customer-internal
last_edited: 2026-05-07
editor: pointsav-engineering
---

## Prerequisites

- Write access to the `woodfine-design-bim` token vault repository.
- Git configured with your commit identity.
- `ifctester` installed for IDS validation:
  ```bash
  pip install ifctester
  ```
- A BIM-authoring tool capable of IFC 4.3 export (FreeCAD + BIM workbench, Archicad,
  or equivalent) — required only if the overlay includes a geometric exclusion fragment.

## Purpose

A Regulatory Overlay adds jurisdiction-specific requirements to one or more BIM Token
types. Each overlay is an independently versioned bundle of three files: an IDS 1.0
constraint file, an optional IFC geometric exclusion fragment, and a YAML metadata
file. This guide covers authoring, validating, and committing a complete overlay.

All paths are relative to the `woodfine-design-bim` repository root.

## Procedure

### Step 1 — Name the Overlay

Overlay IDs follow this convention:

```text
<jurisdiction-code>-<standard-slug>-<element-slug>
```

Examples:

- `ca-bc-bcbc2024-exterior-wall` — BC Building Code 2024, exterior walls
- `us-va-ashrae9012022-glazing` — ASHRAE 90.1-2022, windows and glazing
- `de-enev2020-roof-slab` — German EnEV 2020, roof slabs

The jurisdiction code is ISO 3166-2 (e.g., `CA-BC`, `US-VA`, `DE`, `SG`).

### Step 2 — Author the IDS File

Create `regulation/<jurisdiction>/<overlay-id>.ids` using the IDS 1.0 XML schema:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ids:ids xmlns:ids="http://standards.buildingsmart.org/IDS"
         xmlns:xs="http://www.w3.org/2001/XMLSchema"
         xsi:schemaLocation="http://standards.buildingsmart.org/IDS ids.xsd"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <ids:info>
    <ids:title>BC Building Code 2024 — Exterior Wall Thermal Requirements</ids:title>
    <ids:copyright>Province of British Columbia</ids:copyright>
    <ids:version>1.0.0</ids:version>
    <ids:description>
      Thermal transmittance requirements for above-grade exterior walls
      per BCBC 2024 Part 11 Table 11.2.2.1.
    </ids:description>
    <ids:author>task@project-bim</ids:author>
    <ids:date>2026-05-06</ids:date>
    <ids:purpose>Regulation overlay for woodfine-design-bim vault</ids:purpose>
  </ids:info>

  <ids:specifications>
    <ids:specification name="ExteriorWall-ThermalTransmittance-BCBC2024"
                       ifcVersion="IFC4X3"
                       description="Max thermal transmittance for above-grade exterior walls"
                       minOccurs="1">
      <ids:applicability>
        <ids:entity>
          <ids:name><ids:simpleValue>IFCWALL</ids:simpleValue></ids:name>
        </ids:entity>
        <ids:property dataType="IfcLabel">
          <ids:propertySet><ids:simpleValue>Pset_WallCommon</ids:simpleValue></ids:propertySet>
          <ids:baseName><ids:simpleValue>IsExternal</ids:simpleValue></ids:baseName>
          <ids:value><ids:simpleValue>TRUE</ids:simpleValue></ids:value>
        </ids:property>
      </ids:applicability>
      <ids:requirements>
        <ids:property dataType="IfcThermalTransmittanceMeasure">
          <ids:propertySet><ids:simpleValue>Pset_WallCommon</ids:simpleValue></ids:propertySet>
          <ids:baseName><ids:simpleValue>ThermalTransmittance</ids:simpleValue></ids:baseName>
          <ids:value>
            <xs:restriction base="xs:double">
              <xs:maxInclusive value="0.210"/>
            </xs:restriction>
          </ids:value>
        </ids:property>
      </ids:requirements>
    </ids:specification>
  </ids:specifications>
</ids:ids>
```

Key points:

- `ifcVersion="IFC4X3"` — always use IFC4X3 for new overlays.
- Use `<ids:applicability>` to narrow the constraint to the correct element subtype.
- `<xs:maxInclusive>` for upper-bound requirements; `<xs:minInclusive>` for lower bounds.
- All property values must match the data type declared in `dataType`.

### Step 3 — Author the IFC Fragment (Conditional)

An IFC geometric exclusion fragment is required when the regulatory constraint has
spatial or topological expression — fire compartment boundaries, setbacks, accessibility
clearances. Skip this step for purely numeric constraints.

The fragment is a minimal valid IFC file containing:

1. An `IfcSpace` or `IfcZone` entity defining the constrained volume.
2. An `IfcRelAssociatesConstraint` linking the zone to an `IfcObjective`.
3. An `IfcShapeRepresentation` encoding the geometry of the exclusion volume.

Author the fragment geometry in a BIM-authoring tool, export as IFC 4.3, and save as
`regulation/<jurisdiction>/<overlay-id>-exclusion.ifc`. Note its absence in the YAML
when omitted.

### Step 4 — Author the Metadata YAML

Create `regulation/<jurisdiction>/<overlay-id>.yaml`:

```yaml
id: ca-bc-bcbc2024-exterior-wall
jurisdiction: CA-BC
jurisdiction_name: "British Columbia, Canada"
standard: "BC Building Code 2024"
standard_uri: "https://www.bccodes.ca/building-code.html"
authority: "Province of British Columbia"
effective_date: "2024-03-01"
ifc_classes_covered:
  - IfcWall
  - IfcSlab
constraint_summary: "Max thermal transmittance for above-grade exterior walls and exposed slabs"
ids_path: "ca-bc-bcbc2024-exterior-wall.ids"
ifc_fragment_path: null
version: "1.0.0"
bsdd_authority_uri: "https://identifier.buildingsmart.org/uri/buildingsmart/ifc/4.3"
```

### Step 5 — Validate

Run `ifctester` to validate the IDS file syntax:

```bash
ifctester --ids regulation/CA-BC/ca-bc-bcbc2024-exterior-wall.ids \
          --report json
```

A valid IDS file produces output with `"status": "pass"` and no schema errors. Correct
any schema errors before proceeding.

For validation against a live IFC model:

```bash
ifctester --ids regulation/CA-BC/ca-bc-bcbc2024-exterior-wall.ids \
          --ifc <path-to-model.ifc> \
          --report json \
          --output regulation/CA-BC/validation-report.json
```

### Step 6 — Register in the Token Vault

Add the overlay reference to the relevant DTCG token file. Open
`tokens/bim/elements.dtcg.json` and add the overlay to the element token:

```json
"elements.IfcWall": {
  "regulation_overlays": [
    {
      "id": "ca-bc-bcbc2024-exterior-wall",
      "jurisdiction": "CA-BC",
      "standard": "BC Building Code 2024",
      "ids_path": "regulation/CA-BC/ca-bc-bcbc2024-exterior-wall.ids",
      "effective_date": "2024-03-01"
    }
  ]
}
```

### Step 7 — Commit and Reload

```bash
git add regulation/CA-BC/ tokens/bim/elements.dtcg.json
git commit -m "feat(regulation): add CA-BC BCBC 2024 exterior wall thermal overlay"
```

Restart `app-orchestration-bim` on the deployment host to load the new overlay:

```bash
systemctl restart app-orchestration-bim
```

## Expected Outcome

- The overlay appears in the Regulation tab for the relevant token at
  `https://bim.woodfinegroup.com/tokens/elements.dtcg`.
- `ifctester` syntax validation returns `"status": "pass"` for the IDS file.
- The YAML metadata is committed to `regulation/<jurisdiction>/` alongside the IDS file.

## Verification

```bash
# IDS syntax validation passes
ifctester --ids regulation/<jurisdiction>/<overlay-id>.ids --report json \
    | python3 -c "import sys,json; r=json.load(sys.stdin); print(r.get('status'))"
# Expected: pass

# Overlay visible in token catalog API
curl -s https://bim.woodfinegroup.com/tokens.json \
    | jq '.["elements.IfcWall"].regulation_overlays[].id'
# Expected: "<overlay-id>" in the output list
```

## Rollback

To remove a published overlay:

```bash
cd woodfine-design-bim
git revert HEAD --no-edit
systemctl restart app-orchestration-bim
```

Note: The IDS 1.0 unit system convention (SI vs. imperial) for `xs:maxInclusive` values
is not yet standardised. Use SI (W/m²K) for consistency with international standards
and add imperial conversion documentation alongside SI values.
