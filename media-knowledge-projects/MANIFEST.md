---
schema: foundry-manifest-v1
tier: catalog
deployment_name: media-knowledge-projects
guide: woodfine-fleet-deployment/media-knowledge-projects
source_crate: app-mediakit-knowledge
source_repo: pointsav-monorepo
tenant_variations:
  - woodfine (WoodfineGroup projects instance — content-wiki-projects)
created: 2026-05-03
created_by: master-agent
state: active
doctrine_version: 0.0.10
source_version: 0.1.0
---

# media-knowledge-projects — catalog declaration

This is the catalog-tier manifest for the `media-knowledge-projects`
deployment shape. It declares what this deployment name means, what
source crate produces it, and what tenant variations are planned.

## Purpose

Each `media-knowledge-projects` instance serves the `content-wiki-projects`
Markdown content tree as a Wikipedia-shaped wiki via the `app-mediakit-knowledge` 
binary.

Target Domain: `projects.woodfinegroup.com`
Default bind: `127.0.0.1:9093`.

## Source crate

`app-mediakit-knowledge` in `pointsav-monorepo`.

## Subordinate components

Each instance runs:

- `app-mediakit-knowledge` binary
- systemd unit `local-projects.service`
- Content directory — `content-wiki-projects`

## Tenant variations

| Tenant | Content tree | Instance naming | State |
|---|---|---|---|
| woodfine | `content-wiki-projects` checkout | `media-knowledge-projects-1` | planned |

## Lifecycle

| Date | Event |
|---|---|
| 2026-05-03 | Catalog entry created |
