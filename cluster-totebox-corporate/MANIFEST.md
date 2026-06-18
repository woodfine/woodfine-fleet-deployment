---
schema: foundry-cluster-catalog-v1
cluster: project-orgcharts
deployment: cluster-totebox-corporate-1
tenant: woodfine
purpose: corporate-document-archive
catalog_path: cluster-totebox-corporate/
state: active
updated: 2026-06-05
---

# cluster-totebox-corporate — Woodfine Corporate Document Archive

This catalog entry records the `cluster-totebox-corporate-1` deployment
instance under the `project-orgcharts` Totebox cluster.

## Deployment

| Field | Value |
|---|---|
| Instance | `cluster-totebox-corporate-1` |
| Host | `foundry-workspace` (GCE, us-west1-a) |
| Location | `~/Foundry/deployments/cluster-totebox-corporate-1/` |
| Visibility | Private — gitignored; never pushed |
| Tenant | Woodfine Capital Projects Inc. |

## Purpose

Holds private Woodfine corporate documents: org charts, governance diagrams,
board materials, SPV arrangement charts, and related visualizations.
Jennifer Woodfine (operator) uploads source files; the project-orgcharts
Task Claude produces rendered HTML/SVG/PDF drafts and final outputs.

Design-system components extracted during authoring are backfilled to
`pointsav-design-system` via the `project-design` gateway.

## Authoring runbook

`GUIDE-orgchart-authoring.md` in this directory (pending editorial delivery
from project-editorial — staged 2026-06-05).

## Sub-clones (design-system scope)

| Repo | Role | Focus |
|---|---|---|
| `pointsav-design-system` | Primary | Org-chart components + brand themes |
| `pointsav-media-assets` | Sibling | PointSav brand marks |
| `woodfine-media-assets` | Sibling | Woodfine brand marks |

---
