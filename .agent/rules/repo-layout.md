# Repo layout — woodfine-fleet-deployment

Authoritative list of allowed top-level paths in this repository.
Files outside this allowlist must move; the rule is never loosened
to accommodate misplaced files. See
`~/Foundry/conventions/root-files-discipline.md` for the canonical
companion-file tier.

## Allowed root files

| File | Purpose | Required? |
|---|---|---|
| `README.md` | Public-facing English entry point | required |
| `README.es.md` | Spanish bilingual pair (per CLAUDE.md §6) | required if README.md present |
| `README-TOTEBOX-EGRESS.md` | Totebox Egress supplementary reference | optional |
| `INVENTORY.yaml` | Deployment inventory manifest | required |
| `Cargo.toml` | Rust workspace manifest (if Rust crates present) | conditional |
| `LICENSE` | Repository license; canonical text from `factory-release-engineering/licenses/` | required |
| `SECURITY.md` | Security disclosure policy | required for public repos |
| `TRADEMARK.md` | Trademark policy (when distinct from LICENSE) | required for branded repos |
| `CLAUDE.md` | Repo-specific Claude Code guidance; ≤150 lines per CLAUDE.md size discipline | required |
| `NEXT.md` | Repo-scope hot items; ≤200 lines | optional |
| `CHANGELOG.md` | Version history per CLAUDE.md §7 | required for versioned repos |

## Allowed root directories

| Directory | Purpose |
|---|---|
| `.git/` | Git internal |
| `.agent/` | Engine-agnostic agent state (canonical; `.claude/` is a backward-compat symlink per AGENT.md) |
| `.github/` | GitHub CI / templates |

*Add per-repo content directories below this line.*

| Directory | Purpose |
|---|---|
| `cluster-totebox-corporate/` | CorporateArchive — financial records, minute books, statutory ledgers |
| `cluster-totebox-personnel/` | PersonnelArchive — identity records, contact history |
| `cluster-totebox-property/` | PropertyArchive — real estate and property records |
| `fleet-infrastructure-cloud/` | GCP cloud relay node |
| `fleet-infrastructure-leased/` | Dedicated leased server nodes |
| `fleet-infrastructure-onprem/` | On-premises hardware nodes |
| `gateway-interface-command/` | Command-surface gateway |
| `gateway-knowledge-documentation-1/` | Knowledge documentation gateway instance |
| `gateway-orchestration-bim/` | BIM orchestration gateway |
| `gateway-orchestration-gis/` | GIS orchestration gateway |
| `gateway-orchestration-gis-1/` | GIS orchestration gateway instance 1 |
| `media-knowledge-corporate/` | Corporate wiki media node |
| `media-knowledge-documentation/` | Documentation wiki media node |
| `media-knowledge-projects/` | Projects wiki media node |
| `media-marketing-landing/` | Marketing landing page media node |
| `node-console-operator/` | Console operator node |
| `route-network-admin/` | Private network routing node |
| `vault-privategit-source/` | Source control vault node |

## Misplacement procedure

Files found outside this allowlist:
1. Surface in `cleanup-log.md` (`.agent/rules/cleanup-log.md`)
2. Move via `git mv` to the correct location (or to `~/Foundry/`
   workspace root if cross-repo)
3. Reference the move in commit message
4. Do NOT loosen this allowlist to accommodate

## Schema

This file follows `foundry-repo-layout-v1` (informal). The cluster
manifest at `<cluster>/.agent/manifest.md` may impose tighter
constraints; this file's allowlist is the floor.
