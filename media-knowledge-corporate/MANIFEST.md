---
schema: foundry-manifest-v1
tier: catalog
deployment_name: media-knowledge-corporate
guide: woodfine-fleet-deployment/media-knowledge-corporate
source_crate: app-mediakit-knowledge
source_repo: pointsav-monorepo
tenant_variations:
  - woodfine (WoodfineGroup corporate instance — content-wiki-corporate)
created: 2026-05-03
created_by: master-agent
state: active
doctrine_version: 0.0.10
source_version: 0.1.0
---

# media-knowledge-corporate — catalog declaration

This is the catalog-tier manifest for the `media-knowledge-corporate`
deployment shape. It declares what this deployment name means, what
source crate produces it, and what tenant variations are planned.

## Purpose

Each `media-knowledge-corporate` instance serves the `content-wiki-corporate`
Markdown content tree as a Wikipedia-shaped wiki via the `app-mediakit-knowledge` 
binary.

Target Domain: `corporate.woodfinegroup.com`
Default bind: `127.0.0.1:9095`.

## Source crate

`app-mediakit-knowledge` in `pointsav-monorepo`.

## Subordinate components

Each instance runs:

- `app-mediakit-knowledge` binary
- systemd unit `local-corporate.service`
- Content directory — `content-wiki-corporate`

## Tenant variations

| Tenant | Content tree | Instance naming | State |
|---|---|---|---|
| woodfine | `content-wiki-corporate` checkout | `media-knowledge-corporate-1` | planned |

## Lifecycle

| Date | Event |
|---|---|
| 2026-05-03 | Catalog entry created |
