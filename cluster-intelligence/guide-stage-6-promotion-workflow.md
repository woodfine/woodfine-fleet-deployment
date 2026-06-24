---
artifact: guide
schema: foundry-draft-v1
status: draft
language_protocol: GUIDE
route: project-editorial
created: 2026-06-20
session: Session 111 (Command@claude-code)
research_trail:
  source_briefs: [command-10x-dev-environment]
  cross_checks: [AGENT.md §Mailbox protocol, bin/promote.sh, bin/mailbox-relay.sh, pairings.yaml]
  forbidden_terms_cleared: false
---

# GUIDE: Stage 6 — Promoting Code to Canonical

Stage 6 is the step that moves committed code from a Totebox Archive's staging branch to the canonical vendor repository. It is a one-way, fast-forward push. It does not move session-state files.

---

## What Stage 6 Moves (and What It Does Not)

**Moves:**
- Code: crates, services, `src/`, `Cargo.toml`, `Cargo.lock`
- Governance files committed to the archive's cluster branch (e.g., `conventions/`, `bin/`)

**Never moves:**
- `.agent/` directory contents — inbox, outbox, session context, briefs, session locks
- `NEXT.md`, `CHANGELOG.md` — these are cluster-branch operational files
- `.mcp.json`, engine settings

`promote.sh` filters these automatically via cherry-pick. Archives on `cluster/<name>` branches carry two classes of commits: code commits and `.agent/`-only commits. Only code commits are cherry-picked to `origin/main`.

---

## Eligibility — Who Can Promote

Eligibility is determined by the archive's `self_service` field in `pairings.yaml`.

| `self_service` value | Who can run Stage 6 | How |
|---|---|---|
| `none` | Command Session only | Request via Command inbox; include commit SHA range |
| `build-deploy` | Command Session only | Request via Command inbox |
| `build-deploy-stage6lite` | Archive itself (self-promote) | Run `promote.sh` directly; see conditions below |

To check your archive's current tier:

```bash
grep -A2 "cluster_name: $(basename $PWD)" ~/Foundry/pairings.yaml | grep self_service
```

**Archives at `build-deploy-stage6lite` as of 2026-06-20:** project-editorial, project-gis, project-infrastructure, project-knowledge, project-development, project-design, project-orchestration, project-console, project-system, project-software.

---

## Self-Promote Path (`build-deploy-stage6lite`)

`promote.sh` reads `pairings.yaml` at runtime. For a `stage6lite` archive it verifies:
1. `origin` is configured with an administrator SSH alias (URL must contain `-administrator:`)
2. The administrator SSH key is reachable (`git ls-remote origin HEAD` succeeds in `BatchMode`)

If either check fails, the script exits with a clear error and instructs you to fall back to `self-service-promote.sh` (which writes a queue entry instead).

### Readiness Checklist

Before running `promote.sh` from a stage6lite archive:

- [ ] Working tree is clean (`git status` shows no uncommitted changes)
- [ ] All `cargo test` and `cargo clippy` pass (pre-promote gate runs these automatically unless `--no-pre-promote-check` is passed)
- [ ] Cluster branch is rebased on `origin/main`: `git fetch origin && git rebase origin/main`
- [ ] No pending merge conflicts in staged files
- [ ] Commit range reviewed: `git log origin/main..HEAD --oneline` — confirm only intended commits are listed
- [ ] No `.agent/` commits in the range (they will be filtered, but verify to avoid surprises)

### Running the Promotion

```bash
# From inside the archive clone directory
cd ~/Foundry/clones/<archive-name>

# Preview what would promote (dry-run is not a built-in flag; use git log instead)
git log origin/main..HEAD --oneline

# Run promotion
~/Foundry/bin/promote.sh

# Interactive confirmation is required unless FOUNDRY_PROMOTE_YES=1 is set.
# The script will show a commit preview and ask for confirmation.
```

After a successful promote, `promote.sh` also pushes the cluster branch to `origin-staging-j` for durability of `.agent/` commit history.

---

## Command Session Path (Requesting Stage 6)

For archives at `self_service: none` or `build-deploy`, open the Command Session inbox or outbox and send a message:

```
---
from: totebox@<archive-name>
to: command@claude-code
re: Stage 6 ready — <archive-name> — <crate or feature name>
priority: normal
status: pending
---
Commits ready for canonical: <start-SHA>..<end-SHA>

All tests pass on cluster/<archive-name>. Working tree clean. Rebased on origin/main as of <date>.
```

The Command Session will: fetch, review the commit range, run `promote.sh` with `FOUNDRY_COMMAND_SESSION=1`, then run `bin/sync-local.sh --all` if live-service paths are affected.

---

## Fallback: promote-queue.jsonl

If the administrator SSH key is temporarily unreachable (Tier A down, key expired, etc.), use `self-service-promote.sh` to queue the request:

```bash
~/Foundry/bin/self-service-promote.sh
```

This writes a pending entry to `/srv/foundry/.agent/promote-queue.jsonl`. The Command Session drains this queue at startup or when manually run with `bin/promote-queue-drain.sh`.

---

## Common Errors

| Error message | Cause | Fix |
|---|---|---|
| `origin is not an administrator SSH alias` | `origin` URL missing `-administrator:` | Reconfigure remote: `git remote set-url origin github.com-woodfine-administrator:<org>/<repo>.git` |
| `admin SSH key unreachable` | Key not loaded or provisioned | Verify `/home/<user>/.ssh/foundry-keys/` exists with correct key; check `ssh -T github.com-woodfine-administrator` |
| `promote.sh already running in this repo` | Concurrent promote.sh | Wait for other instance; remove stale `.git/promote.lock` only if certain the other process is dead |
| `working tree is not clean` | Uncommitted changes | `git status`; commit or discard |
| `No code commits to promote` | All commits are `.agent/`-only | Nothing to do; cluster branch state is current |
| `pre-promote checks failed` | cargo fmt/clippy/test failure | Fix the issue; bypass only in emergencies with `--no-pre-promote-check` |

---

## After Promotion

1. Confirm canonical: `git log origin/main --oneline -5`
2. If live services consume this crate, the Command Session runs `bin/sync-local.sh --all` and reloads affected systemd services.
3. Update CHANGELOG.md and NEXT.md in the archive to mark the promotion complete.
