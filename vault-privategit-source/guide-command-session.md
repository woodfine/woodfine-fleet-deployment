# Guide — Running a Command Session

The Command Session is the hub of the Totebox Orchestration workspace. It owns the identity store, workspace documentation, and cross-archive coordination. This guide describes what a Command Session does and how to run one.

This guide describes the planned operational workflow. The `app-orchestration-command` aggregator and several `bin/` entry points are intended; the file-based session protocol is operationally live today.

> **P1 scope.** The Command Session requires a P1 (System Administrator) pairing set. Contributors at P2 or P3 should open an archive instead, using `bin/open-archive.sh` (see `guide-open-archive.md`).

---

## Starting a Command Session

Open an AI session at the workspace root:

```bash
cd <workspace-root>
claude .
```

The session role is detected from the working directory. At the workspace root, the session is a Command Session. At `clones/<archive>/`, it is a Totebox Session.

At session start:

1. Read the workspace inbox: `cat .agent/inbox.md`
2. Read the operational notice file: `cat NOTAM.md`
3. Run the workspace health check: `bin/foundry-health.sh`

---

## What only the Command Session can do

| Action | Why Command-only |
|---|---|
| Provision a Totebox Archive | Requires writing to workspace files and `pairings.yaml` |
| Write `CLAUDE.md`, `AGENT.md`, `MANIFEST.md` | Workspace-level files are Command scope |
| Update `bin/` scripts | Toolchain maintenance is Command scope |
| Manage `pairings.yaml` | The topology record; P1 operator action to add or remove pairings |
| Ratify tetrad milestones | Cross-archive judgement call; requires full topology visibility |
| Virtual-machine system administration | Requires access to both nodes |
| Stage 6 promotion | Pushing staging branches to canonical; requires identity store access |
| Sweep cluster outboxes | Reading every archive outbox; requires Command pairing to each archive |

---

## Sweeping cluster outboxes

Each Totebox Archive writes outbound messages to its `.agent/outbox.md`. The Command Session sweeps these outboxes to pick up requests and route them.

```bash
# Read newest first — messages prepend
head -40 clones/*/.agent/outbox.md
```

Messages from archive outboxes are actioned — fetched, routed, or responded to — and noted in the Command Session outbox. The receiving archive picks up the response at its next session start.

> **Read `head`, not `tail`.** Messages prepend (newest at top). `head` reads the latest; `tail` reads the oldest. Always use `head` when checking for new messages.

---

## Provisioning a new Totebox Archive

To add a new archive to the workspace:

1. Create the cluster directory: `mkdir -p clones/<archive-name>/`
2. Clone the relevant repositories into it (`origin` plus staging-tier remotes).
3. Create a feature branch: `cluster/<archive-name>`.
4. Write the archive manifest at `clones/<archive-name>/.agent/manifest.md` with `foundry-cluster-manifest-v1` frontmatter, including `slm_endpoint:` and `tetrad:`.
5. Create `clones/<archive-name>/.agent/inbox.md` and `.agent/outbox.md`.
6. Add the archive to `pairings.yaml` (endpoint, public key, module identifier, pairing date).
7. Update `PROJECT-CLONES.md` — add a row for the new archive.
8. Commit using the staging-tier helper:

```bash
bin/commit-as-next.sh "workspace: provision <archive-name> cluster"
```

---

## Managing pairings.yaml

`pairings.yaml` at the workspace root is the canonical topology record — the Command's list of active pairings. One entry per archive, `os-mediakit` node, and `os-privategit` node.

Format (planned full schema):

```yaml
pairings:
  - name: project-editorial
    type: totebox-archive
    endpoint: clones/project-editorial
    module_id: editorial
    paired_on: 2026-05-08
  - name: os-mediakit-local
    type: os-mediakit
    endpoint: http://localhost:9200
    paired_on: 2026-05-08
```

Adding a pairing is a P1 operator action. The pairing history is recorded as immutable ledger entries once committed; the pairing topology must be preserved for audit.

---

## The two-node architecture

The Command Session runs on the `os-orchestration` node — the development virtual machine. The node hosts every Totebox Archive, the `service-slm` access-control gateway, source code, and workspace tooling.

The `os-mediakit` node — the production virtual machine — hosts public websites only. Deployments flow from the `os-orchestration` node to the `os-mediakit` node through a deliberate human-gated rsync bridge — the gate between development and production. The Command Session does not push directly to the `os-mediakit` node.

To initiate a deployment to the `os-mediakit` node:

1. Snapshot binaries: `sudo bin/snapshot-binaries.sh`
2. Signal the operator who runs the rsync chain (pull from `os-orchestration` → push to `os-mediakit`).
3. The operator restarts services on the `os-mediakit` node where required.
4. Verify that live domains are healthy.

---

## CommandCentre

The planned `app-orchestration-command` (CommandCentre) is intended as a local HTTP service exposing archive health, message routing, and personnel permission checks as a live interface. When the application ships, the Command Session is intended to query it rather than reading files directly:

```bash
# Planned endpoints (not yet shipped)
curl http://localhost:8020/archives          # archives + tetrad status
curl http://localhost:8020/personnel/<user>  # permission tier + pairings
```

CommandCentre implementation is the next milestone in the Totebox Orchestration transition plan. The cluster (`project-command`) is provisioned.

---

## See also

- `guide-open-archive.md` — companion guide for P2 and P3 contributors opening a Totebox Archive
- `README.md` — vault-privategit-source overview

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
