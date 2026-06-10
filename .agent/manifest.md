---
schema: foundry-cluster-manifest-v1
cluster: project-woodfine
cluster_name: project-woodfine
cluster_branch: cluster/project-woodfine
created: 2026-05-14
state: provisioned
slm_endpoint: http://localhost:8011
module_id: woodfine
---

# project-woodfine — Cluster Manifest

**Mission:** Woodfine customer-tier development archive. Replaces Root sessions
in `customer/` for Woodfine work. All GUIDE and catalog work flows through this
archive and promotes to canonical ledger via Stage 6 (admin-tier push to
woodfine/woodfine-fleet-deployment).

## Scope

- `woodfine-fleet-deployment` — Woodfine fleet deployment catalog (Layer 2 showcase)

## Sub-clone (provision at Task session start)

```bash
cd ~/Foundry/clones/project-woodfine/
git clone git@github.com-woodfine-administrator:woodfine/woodfine-fleet-deployment.git
```

## Tetrad

```yaml
tetrad:
  vendor:
    status: not-applicable — woodfine-fleet-deployment is Layer 2 (customer tier, not vendor)
  customer:
    - repo: woodfine-fleet-deployment
      path: ./woodfine-fleet-deployment/
      upstream: customer/woodfine-fleet-deployment
      focus: Layer 2 showcase — GUIDE-* files, cluster catalogs, fleet deployment runbooks
      status: leg-pending — sub-clone not yet provisioned
  deployment:
    status: not-applicable — deployment instances are Layer 3 (gitignored under deployments/)
  wiki:
    status: leg-pending — operational GUIDEs published as wiki content via project-editorial
```

## SLM routing

- Endpoint: `http://localhost:8011` (shared Doorman on foundry-workspace VM)
- Module ID: `woodfine`
- See `slm/` directory for routing configuration
