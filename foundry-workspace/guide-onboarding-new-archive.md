---
schema: foundry-doc-v1
title: "Provisioning a New Totebox Archive"
slug: guide-onboarding-new-archive
type: guide
status: active
bcsc_class: customer-internal
last_edited: 2026-05-18
editor: pointsav-engineering
---

A Totebox Archive is the working directory for one cluster's AI session — a single `.git`
repo (or a working-tree wrapper around a monorepo clone) under `clones/<archive-name>/`.
Provisioning is a Command-Session task.

## Prerequisites

- The cluster's monorepo or guide source exists on GitHub.
- Cluster branch `cluster/<archive-name>` exists or will be created.
- You are in a Command Session at `/srv/foundry/`.

## Step 1 — Clone or initialise

For an existing cluster monorepo:

```bash
cd /srv/foundry/clones/
git clone --branch cluster/<archive-name> \
    git@github.com:pointsav/pointsav-monorepo.git <archive-name>
```

For a new archive without an upstream repo yet:

```bash
mkdir -p /srv/foundry/clones/<archive-name>
cd /srv/foundry/clones/<archive-name>
git init
git checkout -b cluster/<archive-name>
```

## Step 2 — Scaffold .agent/

```bash
~/Foundry/bin/onboarding/new-archive.sh <archive-name>
```

This creates `.agent/manifest.md` (with tetrad placeholders), inbox/outbox,
`session-start.md`, `plans/README.md`, `rules/` (copied from templates/), and the
archive-level `CLAUDE.md` (which imports the workspace `AGENT.md`). It also symlinks
`.git/hooks/pre-commit` to the workspace pre-commit gate so secret-pattern, size, and
helper-only checks apply from the first commit.

## Step 3 — Fill in the manifest

The scaffold leaves the four tetrad legs as `leg-pending`. Open `.agent/manifest.md` and:

1. Write the one-paragraph mission.
2. Update `vendor.focus` with the actual crates this cluster owns.
3. Identify the `customer.repo` catalog folders.
4. List planned deployment instances under `deployment.instances`.
5. Name the wiki TOPICs this cluster will contribute under `wiki.planned_topics`.

If any leg is genuinely deferred, keep `status: leg-pending` with a note explaining
what gates it.

## Step 4 — Register in PROJECT-CLONES.md

Add a row to `/srv/foundry/PROJECT-CLONES.md` with:
- archive name
- cluster branch
- vendor repo path
- one-line mission

## Step 5 — Commit

From the Command Session workspace root:

```bash
git add PROJECT-CLONES.md
~/Foundry/bin/commit-as-next.sh "ops(<archive-name>): provision archive — scaffold + manifest + register"
```

If the archive has its own `.git/` (engineering repo, not just a working directory),
commit inside the archive separately:

```bash
cd /srv/foundry/clones/<archive-name>/
git add .agent/ CLAUDE.md
~/Foundry/bin/commit-as-next.sh "scaffold .agent/ + archive CLAUDE.md"
```

## What gets installed

After `new-archive.sh`:

- `.agent/manifest.md` with tetrad placeholders
- `.agent/inbox.md` and `.agent/outbox.md` (empty mailboxes)
- `.agent/session-start.md` (orientation checklist)
- `.agent/plans/README.md` (artifact routing rules for this archive)
- `.agent/rules/{repo-layout,project-registry,cleanup-log,handoffs-outbound}.md`
- `.agent/engines/{claude-code,gemini-cli}/.gitkeep`
- `.agent/drafts-outbound/` (empty staging directory)
- `.agent/locks/` (for flock-wrapped operations)
- `CLAUDE.md` at archive root (imports workspace `AGENT.md`)
- `.git/hooks/pre-commit` symlink to workspace gate (if archive is a git repo)

## What you still need to do manually

- Fill the mission paragraph in `.agent/manifest.md`.
- Populate tetrad legs with real focus areas.
- Update the `PROJECT-CLONES.md` row.
- Create the cluster branch on GitHub if it does not already exist.
- Add staging-tier remotes (`origin-staging-j`, `origin-staging-p`) if this is a
  staging-tier engineering repo.
