# foundry-workspace

Operational guides for the Foundry workspace platform node — the GCE VM that hosts
the PointSav AI-assisted development environment.

This directory holds guides for the operators and AI sessions that work within the
workspace: resource recovery, archive provisioning, the Claude Code hook inventory,
and the pre-commit gate workflow.

## Contents

| Guide | Purpose |
|---|---|
| `guide-foundry-vm-resource-recovery.md` | Recovering the VM from resource pressure (load, memory, swap) |
| `guide-onboarding-new-archive.md` | Provisioning a new Totebox Archive via `bin/onboarding/new-archive.sh` |
| `guide-claude-code-hooks-installed.md` | Inventory of the five Claude Code hooks wired in the workspace |
| `guide-pre-commit-gate-operator-flow.md` | Working with the pre-commit gate — bypasses, false positives, emergency override |

## Related TOPICs

The architecture articles behind these guides live in `content-wiki-documentation/architecture/`:
`foundry-services-slice-model`, `multi-engine-session-coordination`, `mailbox-atomicity`,
`cargo-target-per-user-discipline`, `pre-commit-defense-in-depth`.
