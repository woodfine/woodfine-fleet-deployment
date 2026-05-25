---
schema: foundry-doc-v1
title: "Telemetry Operations and Compliance — media-marketing-landing"
slug: guide-telemetry-operations
type: guide
section: content-and-media
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Telemetry Operations — media-marketing-landing

This guide covers day-to-day operation of the visitor telemetry pipeline on the
Woodfine marketing landing deployment. The pipeline collects no cookies and no
personally identifiable information. Reports are generated locally and pulled to
the operator's machine via the `pull-telemetry-ledgers.sh` script.

## Prerequisites

- SSH access to the cloud relay node hosting the `telemetry-daemon` and
  `omni-matrix-engine` services.
- `pull-telemetry-ledgers.sh` present on the operator's local machine (from the
  monorepo `infrastructure/` directory).
- Familiarity with the two output directories: synthesized Markdown reports and
  raw CSV ledgers.

## Architecture

The telemetry stack runs two components:

| Component | Role |
|---|---|
| `telemetry-daemon` | systemd service; listens on an internal port; writes raw visit records to `assets/ledger_telemetry.csv` |
| `omni-matrix-engine` | Daily cron job; cross-references the ledger against an offline `GeoLite2-City.mmdb` database; outputs Markdown report files |

Neither component queries the public internet or stores PII. Data is stored in
flat CSV files on the deployment host.

## Report structure

The daily report aggregates visitor data across standard time windows (yesterday,
7 days, 30 days, 60 days, 90 days, year-to-date, inception) and produces eight
sections:

1. Time volume — chronological event counts
2. Country and region routing
3. City-level density
4. Timezone distribution
5. Page-level interest (target URI)
6. Device form factor (desktop/server vs. mobile/tablet)
7. Operating system distribution
8. Top user-agent strings (raw hardware signatures)

## Procedure

### Step 1 — Generate reports

The `omni-matrix-engine` runs automatically via cron at the configured schedule.
To trigger a manual run:

```bash
ssh <relay-node> sudo systemctl start omni-matrix-engine.service
```

Check completion:

```bash
ssh <relay-node> journalctl -u omni-matrix-engine --since today --no-pager
```

### Step 2 — Pull reports to local machine

Run the pull diode script from the operator's local machine:

```bash
./pull-telemetry-ledgers.sh
```

The script:
- Downloads synthesized Markdown reports and raw CSV ledgers from the relay node.
- Applies a 10-day rolling retention policy, removing local CSV backups older than
  10 days.

Downloaded files land in the directory configured in the script (see script header
for the local destination path).

## Verification

After pulling:

1. Confirm the Markdown report file is present and dated today.
2. Open the report and confirm the eight sections are populated.
3. Confirm `assets/ledger_telemetry.csv` on the relay node is growing as expected:
   ```bash
   ssh <relay-node> wc -l assets/ledger_telemetry.csv
   ```

## Service health

Check both services on the relay node:

```bash
ssh <relay-node> systemctl status telemetry-daemon
ssh <relay-node> systemctl status omni-matrix-engine
```

Both should show `active` or `inactive` (for the one-shot engine). If
`telemetry-daemon` is not running, restart it:

```bash
ssh <relay-node> sudo systemctl restart telemetry-daemon
```

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
