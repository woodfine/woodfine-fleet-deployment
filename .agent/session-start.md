---
schema: foundry-session-start-v1
archive: project-woodfine
updated: 2026-05-14
---

# Session start — project-woodfine

> Step 8 of the session start ritual (AGENT.md §Session start).
> Engine-agnostic — Claude Code and Gemini CLI both read this.

## This archive at a glance

- **Mission:** Woodfine customer-tier development archive. Replaces Root sessions in `customer/`. Owns `woodfine-fleet-deployment` sub-clone (to be provisioned on first Task session). Work here promotes to `woodfine` canonical org via admin-tier commit procedure.
- **Active branch:** `cluster/project-woodfine`
- **Inbox:** read `.agent/inbox.md` (step 4 — already done before this file)
- **In-flight plans:** none (check `.agent/plans/` for any new files)

## Known gotchas

- **Sub-repo `woodfine-fleet-deployment/` is NOT yet cloned.** Must be provisioned (`git clone`) before any work on it. It is gitignored in this cluster.
- This is a **newly provisioned** archive (2026-05-14). First-use setup is required.
- Commits to `woodfine-fleet-deployment` require admin-tier procedure (see CLAUDE.md §8 — `mcorp-administrator` identity + woodfine-administrator key), not `commit-as-next.sh`.
- Never open a session directly in `customer/woodfine-fleet-deployment/` — use this archive instead.
- Commit cluster files via `~/Foundry/bin/commit-as-next.sh`; sub-repo commits use admin-tier procedure.

## Last session handoff

*Archive provisioned 2026-05-14. Sub-repo cloning pending first Task session use.*
