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
  cross_checks: [AGENT.md §Mailbox protocol, bin/mailbox-send.sh, bin/mailbox-relay.sh, bin/mailbox-fsck.sh, conventions/mailbox-message-lifecycle.md]
  forbidden_terms_cleared: false
---

# GUIDE: Cross-Archive Messaging

Each archive in the workspace communicates via a file-based mailbox system. Every archive has an `inbox.md` and an `outbox.md` in its `.agent/` directory. Command has equivalent files at `~/Foundry/.agent/`. Messages are YAML-frontmatter blocks, prepended to the top of these files (newest-on-top).

This guide covers how to write, relay, and maintain messages. The full lifecycle specification is at `conventions/mailbox-message-lifecycle.md`.

---

## Sending a Message

### Canonical Path — `mailbox-send.sh`

```bash
echo "Body text here." | ~/Foundry/bin/mailbox-send.sh \
  --to totebox@project-bim \
  --re "BIM schema update ready for review" \
  --priority normal \
  --body-stdin
```

`mailbox-send.sh` (the M-1 canonical write path):
- Auto-detects sender from CWD (`totebox@<archive>` or `command@claude-code`)
- Validates the destination archive exists
- Generates a unique `msg-id`
- Writes an audit-ledger entry to `data/mailbox-ledger.jsonl`
- Delegates atomic prepend to `mailbox-prepend.sh`

**Override sender identity** (when calling from a sub-clone or unusual CWD):
```bash
--from totebox@project-software
```

**Reply to an existing message:**
```bash
--in-reply-to <original-msg-id>
```

**Broadcast to multiple archives:**
```bash
~/Foundry/bin/mailbox-send.sh \
  --broadcast --targets project-bim,project-documents,project-gis \
  --re "Rollout notice: pairings.yaml updated" \
  --body-file /tmp/announcement.md
```

### MCP Shortcut (Totebox Sessions)

From any Totebox session where the `foundry` MCP server is active:

```
send_mailbox_message(to="command@claude-code", re="Stage 6 ready", body="...")
```

This calls the same underlying logic as `mailbox-send.sh` and writes to the audit ledger.

**Command Session:** use `bin/mailbox-send.sh` directly — MCP `send_mailbox_message()` is also available but `mailbox-send.sh` is the reference implementation.

### Message Schema

```
---
from: totebox@project-bim
to:   command@claude-code
re:   schema update — BIM IFC layer mapping v2
created: 2026-06-20T19:00:00Z
priority: normal
status: pending
msg-id: project-bim-20260620-schema-update
---
Body text. Markdown supported.
```

Required fields: `from`, `to`, `re`, `created`, `priority`, `status`.  
Optional but recommended: `msg-id` (enables reply threading and audit tracing).

Valid `priority` values: `high`, `normal`, `low`.  
Valid `status` values: `pending`, `in-progress`, `actioned`, `operator-pending`, `stale`, `dispatched`, `broadcast`.

---

## Message Lifecycle

```
pending → dispatched (relay delivers it) → actioned (receiver processes it)
                                         → stale (auto-aged after 14d if no action)
```

A message in your **outbox** is waiting to be relayed to its destination inbox. A message in your **inbox** is waiting for you to action.

Do not hand-edit status fields after the fact. Use `mailbox-send.sh` for outgoing messages and mark inbox messages `actioned` when processed.

---

## Automatic Relay — `mailbox-relay.sh`

`bin/mailbox-relay.sh` scans every archive's outbox, reads the `to:` field of each `status: pending` message, and delivers it to the destination inbox using `mailbox-send.sh`. It marks the source entry `status: dispatched` on success.

The relay runs automatically via `foundry-mailbox-relay.timer` every 15 minutes (after operator enables it: `sudo systemctl enable --now foundry-mailbox-relay.timer`).

### Manual Relay

```bash
# Dry-run: see what would be relayed without writing
~/Foundry/bin/mailbox-relay.sh --dry-run

# Relay a single archive's outbox
~/Foundry/bin/mailbox-relay.sh --archive=project-proforma

# Relay all archives (live)
~/Foundry/bin/mailbox-relay.sh

# Verbose: show each message being considered
~/Foundry/bin/mailbox-relay.sh --verbose
```

### Why Not NATS or inotify

NATS was evaluated and rejected. The message rate in this workspace is days-per-message, not sub-second. NATS would create a duplicate source of truth alongside `.agent/` (violating SYS-ADR-07) and require a persistent broker that would itself need monitoring. The systemd timer approach delivers latency under 15 minutes with zero new service dependencies.

inotify-based relay was also considered and deferred. Sessions are episodic, not long-lived daemons; an inotify watcher would need to survive across session starts and stops, adding complexity for no measurable gain over a 15-minute poll.

---

## Draining a Backlog

If an archive's outbox has accumulated many pending messages (e.g., after a session where commits were blocked), drain it in order:

```bash
# Step 1: check what's pending
grep -c "^status: pending" ~/Foundry/clones/<archive>/.agent/outbox.md

# Step 2: dry-run the relay to inspect routing
~/Foundry/bin/mailbox-relay.sh --dry-run --archive=<archive>

# Step 3: relay live
~/Foundry/bin/mailbox-relay.sh --archive=<archive>
```

Messages with no `to:` field, an unrecognised destination, or a `to:` pointing to the same archive (self-relay) are skipped and logged to stderr.

---

## Mailbox Hygiene

Run these from `~/Foundry/` (Command Session scope):

```bash
# Age out stale pending messages older than 14 days (excludes priority:high)
bin/mailbox-fsck.sh --age-out

# Boost overdue normal/low priority messages to the next tier (M-14)
bin/mailbox-fsck.sh --priority-boost

# Check for stagnant outbox messages (attempts counter; alerts at 3+)
bin/mailbox-fsck.sh --stagnation-check

# Verify all inbox/outbox owner: header fields match archive paths
bin/mailbox-fsck.sh --owner-check

# Fix wrong owner: headers (idempotent)
bin/mailbox-fsck.sh --repair-headers

# Collapse duplicate frontmatter keys within a block (M-18)
bin/mailbox-fsck.sh --dedupe-status

# Full schema check (dry-run, no writes)
bin/mailbox-fsck.sh
```

**Shutdown sweep (Command Session):** run `--priority-boost`, `--age-out`, `--stagnation-check`, `--operator-pending-audit`, `--scope-check` in that order. See `AGENT.md §shutdown` step 5c for the full sequence.

---

## Reading and Actioning Inbox Messages

1. Open `clones/<archive>/.agent/inbox.md` (Totebox) or `.agent/inbox.md` (Command).
2. Read messages from top to bottom (newest first).
3. For each message you process, change `status: pending` → `status: actioned` in the frontmatter.
4. At shutdown, archive old actioned/stale messages to `inbox-archive.md` via `bin/mailbox-fsck.sh --archive-old`.

Do not delete messages — move them to `*-archive.md` instead. Git history is the audit trail.

---

## Checking Pending Count

```bash
# Block-count (accurate; counts frontmatter blocks, not raw string occurrences)
python3 -c "
import re, sys
content = open(sys.argv[1]).read()
parts = re.split(r'(?m)^---\$', content)
count = sum(1 for i in range(1, len(parts)-1, 2)
            if re.search(r'^status:\s*pending', parts[i], re.M))
print(count)
" clones/<archive>/.agent/outbox.md

# Quick grep estimate (may be inflated by body-text occurrences)
grep -c "^status: pending" clones/<archive>/.agent/outbox.md
```

Use the block-count method when you need an accurate number.
