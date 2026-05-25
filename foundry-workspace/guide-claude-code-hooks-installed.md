---
schema: foundry-doc-v1
title: "Claude Code Hooks Installed in the Workspace"
slug: guide-claude-code-hooks-installed
type: guide
section: workspace-development
status: active
bcsc_class: customer-internal
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Claude Code Hooks Installed in the Workspace

This guide documents the five Claude Code hooks that fire automatically in workspace sessions. The hooks enforce identity-store safety, surface resource saturation early, and capture session telemetry. No configuration is needed to activate them — they are installed in `.agent/engines/claude-code/settings.json` and fire on matching tool calls.

## What fires when

The workspace ships five hooks via `.agent/engines/claude-code/settings.json`. They fire
automatically whenever a Claude Code session is opened under `/srv/foundry/`. Each is a
small bash script under `bin/hooks/`.

## What fires when

**Before every Bash call:**

- `pretool-chmod-identity-block.sh` — refuses Bash commands matching `chmod.*identity/`.
  Closes the chmod-revert class. If you genuinely need to chmod against the identity store,
  surface the issue via the workspace outbox for the P1 administrator.

- `pretool-cargo-load-guard.sh` — warns (does not block) on cargo invocations when 1-minute
  load average exceeds 8 on the 4-vCPU VM. Two developers running parallel builds saturate
  the box; this surfaces the problem before the build adds to it.

**After every Edit or Write:**

- `posttool-edit-size-warn.sh` — warns when `CLAUDE.md` / `AGENT.md` / `GEMINI.md` files
  exceed their size-discipline cap (400 lines workspace, 150 lines per-archive, 100 lines
  per-project).

- `posttool-write-bilingual-warn.sh` — warns when a `.md` file is written under
  `content-wiki-*/` without an `.es.md` sibling. Editorial work should produce bilingual
  pairs; this catches drift.

**At session end:**

- `stop-trajectory-capture.sh` — writes a JSONL entry per session-end to
  `data/audit-ledger/<archive>/<YYYY-MM>.jsonl`. Captures branch, head SHA,
  uncommitted-file count, and a Stage 6 pending flag if you exit with unpushed commits.
  Feeds the apprenticeship corpus and audit ledger.

## What is NOT a hook

A few things look like hooks but are not:

- **Workspace pre-commit gate** (`bin/pre-commit-foundry-gate.sh`) — that is a git hook,
  not a Claude Code hook. Fires on `git commit` regardless of which engine is running.

- **Nightly transcript harvest** (`bin/transcript-harvest.sh`) — systemd timer, runs at
  02:30 UTC daily, copies that day's Claude Code transcripts into the audit ledger.

- **Apprenticeship queue drainer** (`bin/drain-apprenticeship-queue.sh`) — systemd timer,
  every 15 minutes, calls local-slm for each queued brief.

## Tuning

The hooks read no per-session config; they fire on every matching tool call. To disable
temporarily for a single session, set the relevant environment variable:

- `FOUNDRY_GATE_BYPASS_CHMOD=1` — allows chmod against identity/ (not recommended)
- `FOUNDRY_GATE_BYPASS_SECRETS=1` — pre-commit gate skips secret scan
- `FOUNDRY_GATE_BYPASS_SIZE=1` — pre-commit gate skips size check

To disable permanently, edit `.agent/engines/claude-code/settings.json` and remove the
relevant `PreToolUse` or `PostToolUse` entry. The change takes effect on the next session
start.

## Adding new hooks

Drop a script in `bin/hooks/`, make it executable, then add an entry to
`.agent/engines/claude-code/settings.json` under the appropriate event type. Restart your
Claude Code session to pick up the change.

Hooks receive a JSON description of the proposed tool call on stdin. Exit 0 to allow
(PreToolUse) or to accept silently (PostToolUse). Exit non-zero to block (PreToolUse only —
PostToolUse hooks cannot block because the tool has already run). Stderr is shown to the
operator.
