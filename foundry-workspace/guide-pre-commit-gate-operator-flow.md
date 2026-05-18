---
schema: foundry-doc-v1
title: "Working with the Workspace Pre-Commit Gate"
slug: guide-pre-commit-gate-operator-flow
type: guide
status: active
bcsc_class: customer-internal
last_edited: 2026-05-18
editor: pointsav-engineering
---

Every workspace and archive repo carries a pre-commit hook that runs three checks before
any commit lands. This guide covers what each check rejects, how to bypass legitimately,
and what to log when you do.

## What gets blocked

**Direct `git commit`** — the gate refuses unless `FOUNDRY_COMMIT_HELPER=1` is set in
your environment. `bin/commit-as-next.sh` sets this automatically. If you typed
`git commit -m "..."` directly, the gate rejects with instructions to use the helper
instead.

**Secret patterns** — staged content is scanned against 17 regex patterns covering
SSH/PGP private keys, AWS/GCP/GitHub credentials, Anthropic/OpenAI/Slack API keys, and
generic password assignments. Critical-severity matches block; lower-severity matches
print a warning and proceed.

**Large blobs** — anything over 2 MiB at the blob level is rejected unless the path is
allowlisted (`data/binary-ledger/`, media-asset repos, fleet-deployment `www/dist`).

## How to bypass — when justified

Every bypass should be logged. Use one of:

```bash
# Skip the helper-only check (rare — merge commits, rebases)
git commit --no-verify -m "merge: resolve <branch> into main"

# Skip just the secret scan (your file legitimately contains a private-key
# pattern that is a false positive — e.g. a test fixture or doc example)
FOUNDRY_GATE_BYPASS_SECRETS=1 ~/Foundry/bin/commit-as-next.sh "<message>"

# Skip just the size check (a binary that does not fit the allowlist pattern
# yet — add the path to conventions/secret-patterns.yaml in a follow-up)
FOUNDRY_GATE_BYPASS_SIZE=1 ~/Foundry/bin/commit-as-next.sh "<message>"
```

After bypass, log to `.agent/inbox.md`:

```
---
from: <your role>
to: command
re: pre-commit gate bypass — <reason>
created: <iso-8601>
priority: normal
status: pending
---
Bypassed [SECRETS|SIZE|HELPER] on commit <sha>. Reason: <one-line>.
Follow-up: <add allowlist entry / file ticket / etc.>
```

## False positives — how to fix permanently

If a path consistently triggers a false positive, edit `conventions/secret-patterns.yaml`:

- Add a path glob to `path_allowlist` to skip the file entirely.
- Add to `size_allowlist_paths` if the file is intentionally large.
- Add a new pattern entry if the false positive is widespread enough to warrant filtering.

Commit the change via the helper. The gate reads the YAML fresh on every commit; no
restart is required.

## Emergency override

If everything is broken and you must commit immediately:

```bash
git commit --no-verify -m "EMERGENCY: <reason>"
```

This skips every workspace check and every standard git hook. Log immediately to inbox and
NOTAM. Expect a Command-Session-led audit afterwards.

## What the gate does NOT cover

- Force-push to canonical (still possible via `git push --force`; addressed by branch
  protection on the GitHub side).
- `--amend` on pushed commits (still possible; the workspace rule forbids it).
- History rewrites (`git filter-repo`, `git rebase -i`) — these do not trigger pre-commit.
- Server-side scanning on push — pre-commit is local only.
