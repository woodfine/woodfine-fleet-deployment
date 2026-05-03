# Project Registry — woodfine-fleet-deployment

Living inventory of every top-level project directory with its current
state. Read at session start. Update when activating, retiring, or
reclassifying a project. Registry drift (a directory not in the
table, or a table row without a matching directory) is visible and
must be closed.

State vocabulary — see `~/Foundry/CLAUDE.md` §8 for definitions.

Deployment prefix taxonomy — see `IT_SUPPORT_Nomenclature_Matrix_V8.md`
§4 ("fleet-", "route-", "gateway-", "cluster-", "node-", "media-",
"vault-").

Last updated: 2026-04-22.

---

## Cluster deployments (`cluster-*`)

| Project | State | Type | Notes |
|---|---|---|---|
| cluster-totebox-corporate | Scaffold-coded | cluster | 4 files |
| cluster-totebox-personnel | Scaffold-coded | cluster | 18 files; contains 701 MB `os-totebox.img` — tracking status TBD, candidate for build-time fetch |
| cluster-totebox-property | Scaffold-coded | cluster | 4 files; canonical per monorepo rename (was `cluster-totebox-real-property`) |

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

## Media deployments (`media-*`)

| Project | State | Type | Notes |
|---|---|---|---|
| media-knowledge-corporate | Scaffold-coded | media | 4 files |
| media-knowledge-distribution | Scaffold-coded | media | 4 files |
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

## Summary (2026-04-22 baseline)

- **Active:** 0
- **Scaffold-coded:** 12
- **Reserved-folder:** 2
- **Defect:** 0
- **Not-a-project:** 0
- **Dormant:** 0
- **Archived:** 0

**Total rows:** 14.
