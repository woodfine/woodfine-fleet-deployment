---
schema: foundry-doc-v1
title: "Deploy app-console-slm — the SLM dashboard cartridge"
slug: guide-console-slm-deploy
type: guide
section: ai-and-intelligence
status: active
bcsc_class: no-disclosure-implication
last_edited: 2026-06-10
editor: pointsav-engineering
---

# Deploy app-console-slm — the SLM dashboard cartridge

app-console-slm (F9 cartridge) displays live Doorman health, entity
counts from the organizational knowledge graph, and inference routing
state inside the os-console chassis. This guide covers building and
installing the cartridge, configuring environment variables, and
verifying the F9 dashboard is live.

## Pre-flight

```bash
# Confirm os-console chassis is already running
systemctl status os-console.service

# Confirm the Doorman is reachable
curl -s http://127.0.0.1:9080/healthz
# Expect: {"status":"ok"}

# Confirm service-content is reachable (entity counts source)
curl -s http://127.0.0.1:9081/healthz
# Expect: {"status":"ok"}
```

## Step 1 — Build the cartridge

```bash
cd /srv/foundry/clones/project-intelligence/app-console-slm
cargo build --release
```

Binary lands at `target/release/app-console-slm`.

## Step 2 — Install as a systemd service

```bash
sudo cp infrastructure/systemd/app-console-slm.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now app-console-slm.service
```

## Step 3 — Configure environment variables

The cartridge reads from `/etc/app-console-slm/app-console-slm.env`. Create it:

```bash
sudo mkdir -p /etc/app-console-slm
sudo tee /etc/app-console-slm/app-console-slm.env << EOF
# Doorman endpoint (Tier A local, required)
DOORMAN_ENDPOINT=http://127.0.0.1:9080

# service-content endpoint (entity counts, optional)
SERVICE_CONTENT_ENDPOINT=http://127.0.0.1:9081

# Poll interval for dashboard refresh (seconds, default 10)
SLM_POLL_INTERVAL_SEC=10
EOF
sudo systemctl restart app-console-slm.service
```

## Step 4 — Verify F9 is live

Open the os-console chassis and press **F9**. The F9 dashboard layout:

```
┌─────────────────────────────────────────────────────────────┐
│ SLM Dashboard                                    F9         │
├────────────────────────┬────────────────────────────────────┤
│ Doorman Health         │ Entity Counts                      │
│  Tier A:  ● HEALTHY   │  People:      1,024                │
│  Tier B:  ○ unavail   │  Companies:     312                │
│  Circuit: CLOSED      │  Projects:      87                 │
├────────────────────────┴────────────────────────────────────┤
│ Recent Routing                                              │
│  [10:41] TOPIC generation → Tier A (local)   87 ms        │
│  [10:40] Graph extraction → Tier A (local)  124 ms        │
│  [10:38] Apprenticeship brief → Tier A       99 ms        │
└─────────────────────────────────────────────────────────────┘
```

## Keyboard controls

| Key | Action |
|---|---|
| R | Force dashboard refresh (re-polls Doorman + service-content) |
| K | Open kill switch dialog (pause/resume Doorman routing) |
| P | Open routing policy dialog |
| G | Jump to entity graph view |
| ? | Show help overlay |
| Q | Close F9 cartridge, return to chassis default |

## Kill switch dialog

Press **K** to pause all Doorman inference routing:

```
┌─────────────────────────────┐
│  Kill Switch                │
│                             │
│  ◉ Routing: ACTIVE          │
│  ○ Routing: PAUSED          │
│                             │
│  [P] Pause    [R] Resume    │
│  [Esc] Cancel               │
└─────────────────────────────┘
```

Pausing sets the Doorman circuit to OPEN — in-flight requests complete;
new requests queue until resumed. Resume with **R** in the dialog.

## Routing policy dialog

Press **P** to configure tier preference:

```
┌────────────────────────────────┐
│  Routing Policy                │
│                                │
│  Tier preference:              │
│  ◉ Tier A first (local)        │
│  ○ Tier B first (GPU)          │
│  ○ Tier C fallback only        │
│                                │
│  [Enter] Apply   [Esc] Cancel  │
└────────────────────────────────┘
```

## Chassis connection

The cartridge connects to the os-console chassis socket at
`/run/os-console/cartridge.sock`. If the chassis is restarted, the
cartridge reconnects automatically on next poll cycle.

## Troubleshooting

| Symptom | Check |
|---|---|
| F9 shows "Doorman unreachable" | Verify `local-doorman.service` is running: `systemctl status local-doorman.service` |
| Entity counts show 0 | Check `SERVICE_CONTENT_ENDPOINT` in env file; verify `local-content.service` is running |
| Dashboard not refreshing | Check `SLM_POLL_INTERVAL_SEC` — set lower (e.g., 5) for faster updates |
| Cartridge crash on F9 | Check logs: `journalctl -u app-console-slm.service --since=-5m` |
