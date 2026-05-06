# Deployment Guide — Marketing Landing Site (Woodfine tenant)

Covers the operation of the Woodfine marketing landing site at `home.woodfinegroup.com`. The active deployment instance is `media-marketing-landing-1` — Woodfine customer-tier tenant of `app-mediakit-marketing`.

## Stack composition

- `app-mediakit-marketing` binary (compiled from `pointsav-monorepo/app-mediakit-marketing/`)
- Flat-file content directory (Markdown + YAML frontmatter; no database)
- service-content DataGraph integration (entity references on landing pages, optional)
- nginx vhost terminating TLS via Let's Encrypt
- systemd unit serving on a dedicated 909x port (see deployment instance MANIFEST)

## WordPress muscle-memory at the UX layer

The landing site presents WordPress-familiar navigation: `/wp-admin`-style Dashboard, Pages, Media, Themes, Settings. Content authors who know WordPress should not need to relearn. The Rust + flat-file architecture sits underneath — invisible to authors, but eliminates the PHP/MySQL operational burden + plugin sprawl.

## Bring-up sequence

1. Install binary at `/usr/local/bin/app-mediakit-marketing` (Master scope; operator-presence sudo).
2. Create `local-marketing.service` systemd unit pointing at `~/Foundry/deployments/media-marketing-landing-1/`.
3. Configure environment:
   - `SERVICE_MARKETING_MODULE_ID=woodfine`
   - `SERVICE_MARKETING_CONTENT_DIR=/srv/marketing-woodfine/content/`
   - `SERVICE_MARKETING_BIND=127.0.0.1:910N` (allocate next free 910x port)
4. Configure nginx vhost for `home.woodfinegroup.com` reverse-proxying to local port.
5. Issue Let's Encrypt cert via certbot.
6. Smoke test: `curl https://home.woodfinegroup.com/healthz`.

## Tier 0 compatibility

Marketing landing runs on a $7/mo Tier 0 node:
- No PHP, no MySQL — Rust binary + flat-file content
- No GPU required (no inference for static pages)
- AI tier optional — if Doorman has Tier C key, content suggestions become available; without it, static editing only

## Content workflow

- Pages live as Markdown files in `content/pages/`
- Media uploads in `content/media/`
- Theme tokens in `themes/<theme-name>/tokens.css` (sourced from `pointsav-design-system` per `conventions/design-system-substrate.md`)
- Per-page entity references resolve via service-content DataGraph (`module_id=woodfine`)
- Page edits captured for training corpus via Doorman audit-log (`event_type: prose-edit`)

## Operational notes

- Authentication: dev-mode passthrough until operator seeds `MARKETING_PASSWORD_HASH`
- Monitoring: nginx access log + service-marketing journal
- WORM ledger: every page edit produces a versioned tuple at `~/Foundry/data/marketing-ledger/<tenant>/<YYYY-MM>.jsonl`

## When this site graduates to its own VM

Per `conventions/publishing-tier-architecture.md` per-site VM graduation: provision a dedicated VM, rsync the deployment instance folder, swap DNS. Path on the new VM stays `~/deployments/media-marketing-landing-1/` for clean lift.

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
