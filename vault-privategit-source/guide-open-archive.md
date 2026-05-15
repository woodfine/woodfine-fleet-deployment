# Guide — Opening a Totebox Archive

This guide explains how to open a Totebox Session inside a Totebox Archive. A Totebox Session is the standard way to perform development work in Totebox Orchestration — open an archive, work within its scope, and close the session when the task is complete. Work stays inside the archive until the Command Session ratifies and promotes it.

This guide describes the planned operational workflow. The `bin/open-archive.sh` and `bin/list-archives.sh` entry-point scripts are intended; the file-based protocol described in subsequent steps is operationally live today.

> **Audience.** Contributors with a P2 (Package Manager) or P3 (User) permission tier. P1 (System Administrator) operators run the Command Session instead — see `guide-command-session.md`.

---

## Prerequisites

- An `os-console` instance paired with the archive being opened. Run `bin/list-archives.sh` (planned) from the workspace root to confirm which archives are within the contributor's permission scope.
- A working directory at the workspace root, with the archive clone available at `clones/<archive-name>/`.

---

## Step 1 — Open the archive

From the workspace root, invoke the open-archive entry point with the target archive name:

```bash
bin/open-archive.sh <archive-name>
```

Example, for the editorial cluster:

```bash
bin/open-archive.sh project-editorial
```

The script is intended to print an archive summary before opening the session:

```text
Archive: project-editorial
Tetrad:  vendor ✓  customer ✓  deployment ✓  wiki ✓
SLM:     http://localhost:8011 (module: editorial)
Inbox:   2 pending messages
```

If the script reports "out of scope for your tier", the contributor's `os-console` is not paired with the archive. Run `bin/list-archives.sh` to find archives within scope.

---

## Step 2 — Read the inbox

The session opens at `clones/<archive-name>/`. Read the inbox at session start:

```bash
cat .agent/inbox.md
```

The inbox contains messages from the Command Session and from other Totebox Sessions that have routed requests through the Command. Once a message has been actioned, archive it to `.agent/inbox-archive.md`.

---

## Step 3 — Work within the archive

All work happens within the archive's declared repositories. The archive manifest at `.agent/manifest.md` lists every repository in scope. A session in `project-editorial`, for example, works within the clones of `content-wiki-documentation`, `content-wiki-projects`, and `woodfine-fleet-deployment` that are inside the cluster directory.

Write code, make commits, draft wiki content, and update deployments — all within the archive. The session does not write to other archives, the workspace root, or the canonical `vendor/` and `customer/` trees.

---

## Step 4 — Route cross-archive requests

If the work requires something from another archive — for example, `project-editorial` needing a component specification from `project-design` — do not access the other archive directly. Write an outbox message instead:

```markdown
---
from: totebox@project-editorial
to: command@master
re: Request — design token for footer spacing
created: 2026-05-08T17:00Z
priority: normal
---
Need footer spacing token from project-design for the new services/_index.md layout.
Archive: project-design. Token file: pointsav-design-system/tokens/spacing.json.
```

Prepend the message to `.agent/outbox.md` (newest on top). The Command Session picks it up during the next workspace sweep and either fetches the data or routes the request.

---

## Step 5 — Stage wiki drafts

TOPIC and GUIDE drafts produced in a Totebox Session are staged to `clones/<archive>/.agent/drafts-outbound/`. The draft pipeline (`cluster-wiki-draft-pipeline.md`) routes them through `project-editorial` for language refinement before commitment to the wiki repositories.

Draft frontmatter must include:

- `schema: foundry-draft-v1`
- `state: draft-pending-language-pass`
- `originating_cluster: <archive-name>`
- `target_repo:` and `target_path:` declaring where the draft belongs

---

## Step 6 — Close the session

Before closing, confirm that:

- The inbox is actioned — pending messages have been archived or responded to.
- The outbox is updated with any new requests.
- Staged work is committed to the archive's feature branch.
- The tetrad status in the archive manifest reflects any newly completed legs.

The session ends when the AI window is closed. The archive's state persists; the next session opens where this one left off.

---

## Listing all archives

To see every Totebox Archive available in the workspace:

```bash
bin/list-archives.sh
```

The script (planned) is intended to print every archive with its tetrad status and pending inbox count. Archives outside the contributor's permission scope are intended to be flagged but listed, so the contributor knows what exists in the workspace.

---

## See also

- `guide-command-session.md` — companion guide for P1 operators running the Command Session
- `README.md` — vault-privategit-source overview

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
