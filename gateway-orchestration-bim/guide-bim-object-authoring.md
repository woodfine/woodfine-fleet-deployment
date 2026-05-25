---
schema: foundry-doc-v1
title: "Authoring BIM Objects"
slug: guide-bim-object-authoring
type: guide
status: active
bcsc_class: customer-internal
last_edited: 2026-05-25
editor: pointsav-engineering
---

## Prerequisites

- Write access to the BIM Object vault repository (`woodfine-bim-library` or equivalent).
- Git configured with your commit identity.
- A text editor with JSON schema validation (optional but recommended).
- `ifctester` installed for IDS file validation:
  ```bash
  pip install ifctester
  ```

## Purpose

This guide explains how to add a new BIM Object to a sovereign BIM Object vault. At v0.0.1,
BIM Objects are authored as DTCG JSON files committed directly to git. The four-zone CMS
authoring interface is intended for v0.1.x and will wrap the same file operations.

## Procedure

### Zone 1 — Specification

The Specification zone defines the token's permanent identity: what kind of built-
environment element it is, where it fits in the IFC hierarchy, and how it is classified.

**Required fields:**

```json
"<category>.<token-name>": {
  "$type": "bim-element",
  "$description": "Plain-language description (max 280 characters)",
  "ifc_class": "IfcWall",
  "ifc_predefined_type": "SOLIDWALL",
  "uniclass_ref": "Ss_20_05_30_75",
  "uniclass_title": "Masonry walls",
  "bsdd_uri": "https://identifier.buildingsmart.org/uri/...",
  "applicable_psets": ["Pset_WallCommon", "Pset_WallCommonCanada"]
}
```

**Steps:**

1. Identify the correct IFC 4.3 entity class. The IFC entity browser at
   `standards.buildingsmart.org/IFC/RELEASE/IFC4_3/` lists all entity types with their
   inheritance paths. Use the most specific class that matches — `IfcWall` not
   `IfcBuiltElement`.

2. Look up the Uniclass 2015 code at `toolkit.thenbs.com/toolPages/uniclass2015`. Copy
   the reference code and title for the element type.

3. Find the bSDD URI at `search.bsdd.buildingsmart.org`. Copy the "Identifier" URI for
   the most relevant match. If no match exists, leave the field empty and add an open
   question in a `$comment` field.

4. Add the `applicable_psets` array using the IFC 4.3 entity specification page, which
   lists applicable property sets for each entity type.

**File location:** Add the BIM Object to the correct category file in
`woodfine-bim-library/tokens/bim/`:

| Element type | File |
|---|---|
| Spatial elements (`IfcSpace`, `IfcBuildingStorey`) | `spatial.dtcg.json` |
| Structural + envelope elements (`IfcWall`, `IfcSlab`) | `elements.dtcg.json` |
| MEP elements (`IfcPipe`, `IfcDuct`) | `systems.dtcg.json` |
| Materials (`IfcMaterial`) | `materials.dtcg.json` |
| Composed assemblies | `assemblies.dtcg.json` |
| Cross-cutting performance specs | `performance.dtcg.json` |
| Classification cross-references | `identity-codes.dtcg.json` |
| Climate zone performance tables | `climate-zones.dtcg.json` |

### Zone 2 — Regulation

The Regulation zone adds jurisdiction-specific requirements to the BIM Object. Each entry is
one constraint from one jurisdiction.

**Overlay file location:**
```text
woodfine-design-bim/regulation/<jurisdiction-code>/
├── overlay-<element-type>.ids     ← IDS 1.0 constraint file
└── exclusion-<element-type>.ifc   ← IFC geometric fragment (if applicable)
```

**Steps:**

1. Identify the jurisdiction code (ISO 3166-2, e.g., `CA-BC` for British Columbia,
   `DE` for Germany).

2. Author the IDS 1.0 constraint file. See `guide-regulation-overlay-publishing.md` for
   the full IDS authoring procedure. Minimum structure:

   ```xml
   <ids:specification name="ExteriorWall-FireResistance-CA-BC"
                      ifcVersion="IFC4X3">
     <ids:applicability>
       <ids:entity>
         <ids:name><ids:simpleValue>IFCWALL</ids:simpleValue></ids:name>
       </ids:entity>
     </ids:applicability>
     <ids:requirements>
       <ids:property dataType="IfcLabel">
         <ids:propertySet><ids:simpleValue>Pset_WallCommon</ids:simpleValue></ids:propertySet>
         <ids:baseName><ids:simpleValue>FireRating</ids:simpleValue></ids:baseName>
         <ids:value><ids:simpleValue>REI 90</ids:simpleValue></ids:value>
       </ids:property>
     </ids:requirements>
   </ids:specification>
   ```

3. Validate the IDS file: `ifctester --ids <file>.ids --report json`

4. Add the overlay reference to the BIM Object entry:
   ```json
   "regulation_overlays": [
     {
       "jurisdiction": "CA-BC",
       "standard": "BC Building Code 2024 Part 3",
       "ids_path": "regulation/CA-BC/overlay-exterior-wall.ids",
       "effective_date": "2024-03-01"
     }
   ]
   ```

5. If the requirement has geometric expression (fire compartment boundary, setback), add
   the IFC fragment file and reference it in `ifc_fragment_path`.

### Zone 3 — Climate Zone

The Climate Zone zone adds climate-based performance requirements. Edit
`woodfine-bim-library/tokens/bim/climate-zones.dtcg.json` directly.

**Adding a new climate zone row:**

```json
"climate.ASHRAE-5C.IfcWall.max-u-value": {
  "$type": "bim-climate-zone",
  "$description": "ASHRAE 5C marine — max U-value for exterior walls",
  "zone_id": "ASHRAE-5C",
  "ifc_class": "IfcWall",
  "parameter": "max_u_value",
  "required_value": 0.104,
  "unit": "Btu/h·ft²·°F",
  "source_standard": "ASHRAE 90.1-2022 Table 5.5-5",
  "$value": "0.104 Btu/h·ft²·°F"
}
```

Use SI units unless the source standard is expressed in imperial. When both exist, add
two rows with the same `parameter` name and a `unit_system` discriminator field.

### Zone 4 — Publishing

**Validation checklist before commit:**

- [ ] JSON is valid: `jq . woodfine-design-bim/tokens/bim/<file>.dtcg.json > /dev/null`
- [ ] `ifc_class` exists in IFC 4.3 schema
- [ ] `uniclass_ref` matches a Uniclass 2015 code
- [ ] IDS files pass `ifctester` syntax check
- [ ] `$description` is ≤ 280 characters

**Commit:**

```bash
git add woodfine-bim-library/tokens/bim/ woodfine-bim-library/regulation/
git commit -m "feat(objects): add <object-name> — <one-line description>"
```

**Reload the BIM Object catalog:**

```bash
# On the deployment host
systemctl restart app-orchestration-bim
```

## Expected Outcome

- The new BIM Object appears at `https://bim.woodfinegroup.com/tokens`.
- The BIM Object detail page loads at `https://bim.woodfinegroup.com/tokens/<category-key>`.
- `https://bim.woodfinegroup.com/tokens.json` includes the new BIM Object key.

## Verification

```bash
# BIM Object visible in catalog
curl -s https://bim.woodfinegroup.com/tokens | grep "<object-name>"

# BIM Object detail page loads
curl -s https://bim.woodfinegroup.com/tokens/<category-key> | grep "ifc_class"

# Machine surface includes new BIM Object
curl -s https://bim.woodfinegroup.com/tokens.json | jq '.["<category>.<object-name>"] | .ifc_class'
# Expected: the ifc_class value you authored
```

## Rollback

To undo a BIM Object addition:

```bash
cd woodfine-bim-library
git revert HEAD --no-edit
systemctl restart app-orchestration-bim
```

Note: DESIGN-TOKEN changes — additions to the BIM Object primitives in
`pointsav-design-system` — require Master co-sign in frontmatter per the platform governance
process before the Root session commits to the design system. Customer vault additions to
`woodfine-bim-library` do not require Master co-sign.
