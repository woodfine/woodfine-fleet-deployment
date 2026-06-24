---
title: "GUIDE — app-orchestration-graph Deployment and Configuration"
description: "Deployment and configuration guide for the app-orchestration-graph DataGraph federation gateway. Aspirational — documents the intended pattern for when the project activates from Reserved-folder state."
target_deployment: gateway-orchestration-graph
last_edited: 2026-06-23
source: project-data drafts-outbound (2026-06-23)
---

# GUIDE — app-orchestration-graph Deployment and Configuration

> **Status note:** `app-orchestration-graph` is a Reserved-folder project. This guide
> is aspirational — it documents the intended deployment and configuration pattern so
> the architecture is preserved as the fleet grows incrementally. Update when the
> project activates (Scaffold-coded transition).

## Prerequisites

- `app-orchestration-slm` running and serving a registered Totebox fleet (port `:9180`)
- At least one condition met for extraction (see `app-orchestration-graph/README.md`)
- All Totebox Archives registered against the same os-orchestration instance
- AArch64 or x86_64 GCP Debian VM with Rust toolchain and access to all Totebox internal IPs

## Build

```bash
cd /srv/foundry/clones/project-data/app-orchestration-graph
cargo build --release -p app-orchestration-graph-server
```

Binary output: `$CARGO_TARGET_DIR/release/app-orchestration-graph-server`

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `GRAPH_BIND_ADDR` | `127.0.0.1:9181` | HTTP server bind address |
| `GRAPH_SLM_ENDPOINT` | — | `app-orchestration-slm` base URL (for fleet registry sync) |
| `GRAPH_SLM_BEARER` | — | Bearer token for registry query |
| `GRAPH_CACHE_TTL_SECS` | `30` | Federation result cache TTL per query type |
| `GRAPH_FANOUT_TIMEOUT_SECS` | `10` | Per-Totebox query timeout before partial-failure |
| `GRAPH_PARTIAL_OK` | `true` | Allow partial results when one or more Toteboxes are unreachable |
| `GRAPH_MAX_CONNECTIONS_PER_HOST` | `4` | Per-Totebox connection pool size |

## Endpoints

### `POST /v1/graph/federated`

Fans out a DataGraph query to all registered Toteboxes. Intended to be moved from
`app-orchestration-slm` on activation.

Request:
```json
{
  "query": "Woodfine Management Corp.",
  "limit": 20,
  "archives": ["project-gis", "project-editorial"]
}
```

Response:
```json
{
  "results": [
    { "archive": "project-gis", "entities": [...], "latency_ms": 42 },
    { "archive": "project-editorial", "entities": [...], "latency_ms": 67 }
  ],
  "partial": false,
  "unreachable_archives": []
}
```

If `GRAPH_PARTIAL_OK=true` and a Totebox is unreachable, it appears in
`unreachable_archives` and the response is returned rather than failing the entire request.

### `GET /healthz`

Returns `200 OK` when the service is up. Does not require Totebox connectivity.

### `GET /v1/fleet`

Returns the current fleet registry (synced from `app-orchestration-slm`). Use this to
verify which Totebox DataGraphs are reachable before issuing federated queries.

## Systemd unit

```ini
[Unit]
Description=PointSav app-orchestration-graph DataGraph Federation Gateway
After=network.target app-orchestration-slm.service

[Service]
Type=simple
User=pointsav
EnvironmentFile=/etc/foundry/graph.env
ExecStart=/usr/local/bin/app-orchestration-graph-server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

## Migration from app-orchestration-slm

When activating `app-orchestration-graph`:

1. Deploy and verify `app-orchestration-graph` alongside `app-orchestration-slm`.
2. Point all `POST /v1/graph/federated` callers at `:9181` instead of `:9180`.
3. Verify response parity (same results from both; run in parallel for one duty cycle).
4. Remove `POST /v1/graph/federated` from `app-orchestration-slm`.
5. Update `app-orchestration-slm/CLAUDE.md` endpoint table.

No Totebox Archive changes are required. Toteboxes expose `service-content` endpoints
that both services can query — the fanout target changes at the chassis layer only.

## Connection pool sizing

Each Totebox entry in the fleet registry maps to a persistent HTTP connection pool
of `GRAPH_MAX_CONNECTIONS_PER_HOST` connections to that Totebox's `service-content`
endpoint. Total connections ≈ fleet_size × `GRAPH_MAX_CONNECTIONS_PER_HOST`.

For a fleet of 20 Toteboxes with the default of 4 connections per host: 80 open
connections. Plan VM memory and file descriptor limits accordingly. For fleets
above 100 Toteboxes, add `LimitNOFILE=65536` to the systemd unit.
