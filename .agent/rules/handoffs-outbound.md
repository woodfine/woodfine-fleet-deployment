# Handoffs outbound — woodfine-fleet-deployment

Pending cross-repo moves originating from this repository's refined
output. Each entry follows the passive-outbox pattern per
`~/Foundry/CLAUDE.md` §11.

State values:
- `pending-destination-commit` — refined draft staged here, target
  repo not yet committed
- `destination-committed` — landed at target; entry stays here as
  audit trail until next cleanup
- `closed` — confirmed in canonical; can be archived

## Open handoffs

*(none)*

## Closed handoffs

*(audit-only; trim periodically per cleanup-log cadence)*

---

## Schema

Each handoff entry uses this structure:

```
### N. <human-friendly title>

| Field | Value |
|---|---|
| Source path | `path/inside/this/repo/file.draft.md` |
| Destination repo | `<vendor|customer>/<repo-name>` |
| Destination path | `path/in/destination/file.md` |
| Destination role | **Master Claude** \| **Root Claude** \| **Task Claude at <cluster>** |
| State | pending-destination-commit \| destination-committed \| closed |
| Notes | <optional, e.g. SHA, date, related cluster signal> |
```

## Cross-repo moves NOT handled here

- **Stage 6 staging→canonical promotion** uses
  `~/Foundry/bin/promote.sh` and is not a handoff (same repo, just
  a tier-promotion).
- **Master direct-edits** to admin-only repos
  (factory-release-engineering, *-media-assets, *.github.io, .github)
  use the admin-tier procedure in CLAUDE.md §8 and don't pass
  through this file.
- **Cluster→cluster mailbox messages** use `.agent/inbox.md` /
  `.agent/outbox.md` per CLAUDE.md §12, not this handoff file.

This file specifically tracks **content-derived artefacts** that
need to land in a different repo than the one that authored them.
