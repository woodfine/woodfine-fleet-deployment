# Project Registry — woodfine-fleet-deployment

Living inventory of every top-level project directory with its current
state. Read at session start. Update when activating, retiring, or
reclassifying a project. Registry drift (a directory not in the
table, or a table row without a matching directory) is visible and
must be closed.

State vocabulary — see `~/Foundry/CLAUDE.md` §8 for definitions.

Deployment prefix taxonomy — see `~/Foundry/conventions/nomenclature-taxonomy.md`
("fleet-", "route-", "gateway-", "cluster-", "node-", "media-",
"vault-").

Last updated: 2026-05-07.

---

## Cluster deployments (`cluster-*`)

| Project | State | Type | Notes |
|---|---|---|---|
| cluster-totebox-corporate | Scaffold-coded | cluster | 4 files |
| cluster-totebox-personnel | Scaffold-coded | cluster | 17 files; os-totebox.img removed 2026-05-15 (binary, gitignored) |
| cluster-totebox-property | Scaffold-coded | cluster | 5 files; canonical per monorepo rename (was `cluster-totebox-real-property`); guide-bim-archive-operations.md added 2026-05-07 |

## Fleet deployments (`fleet-*`)

| Project | State | Type | Notes |
|---|---|---|---|
| fleet-infrastructure-cloud | Scaffold-coded | fleet | 5 files |
| fleet-infrastructure-leased | Scaffold-coded | fleet | 10 files |
| fleet-infrastructure-onprem | Scaffold-coded | fleet | 7 files |

## Gateway deployments (`gateway-*`)

| Project | State | Type | Notes |
|---|---|---|---|
| gateway-interface-command | Scaffold-coded | gateway | 4 files |
| gateway-knowledge-documentation-1 | Scaffold-coded | gateway | 1 file; guide-knowledge-wiki-sprint-roadmap.md; no scaffold skeleton yet |
| gateway-orchestration-bim | Active | gateway | 8 files; scaffold skeleton + 4 operational GUIDEs added 2026-05-07 |
| gateway-orchestration-gis | Scaffold-coded | gateway | 4 files; scaffold skeleton (README + README.es + guide-deployment + guide-provision-node) |
| gateway-orchestration-gis-1 | Scaffold-coded | gateway | 1 file; guide-gis-adding-a-chain.md; no scaffold skeleton yet |

## Media deployments (`media-*`)

| Project | State | Type | Notes |
|---|---|---|---|
| media-knowledge-corporate | Scaffold-coded | media | 4 files |
| media-knowledge-distribution | Archived | media | Renamed to media-knowledge-documentation (483bfbb) then removed by Master (6d5cda2, 2026-05-06) — "duplicate of vendor side" |
| media-knowledge-documentation | Scaffold-coded | media | 4 files; design-system integration GUIDEs only (dark-mode toggle, design tokens); not operational runbooks; re-ratified 2026-05-07 |
| media-knowledge-projects | Scaffold-coded | media | 4 files |
| media-marketing-landing | Scaffold-coded | media | 17 files |

## Node deployments (`node-*`)

| Project | State | Type | Notes |
|---|---|---|---|
| node-console-operator | Reserved-folder | node | 3 files |

## Route deployments (`route-*`)

| Project | State | Type | Notes |
|---|---|---|---|
| route-network-admin | Scaffold-coded | route | 5 files |

## Vault deployments (`vault-*`)

| Project | State | Type | Notes |
|---|---|---|---|
| vault-privategit-source | Scaffold-coded | vault | 4 files |

---

## Summary (2026-05-07)

- **Active:** 1
- **Scaffold-coded:** 17
- **Reserved-folder:** 1
- **Defect:** 0
- **Not-a-project:** 0
- **Dormant:** 0
- **Archived:** 1

**Total rows:** 20.
