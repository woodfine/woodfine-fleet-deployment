---
schema: foundry-doc-v1
title: "MBA Pairing Ceremony"
slug: guide-mba-pairing-ceremony
short_description: "Step-by-step operator procedure for establishing, verifying, rotating, and revoking machine-based authorization pairings between os-console and os-* services."
category: node-console-operator
type: guide
section: console-and-operations
status: active
bcsc_class: public-disclosure-safe
last_edited: 2026-05-25
editor: pointsav-engineering
---

# MBA Pairing Ceremony

**Audience:** Operators setting up a new `os-console` connection to an `os-*` service.
**Prerequisite:** `os-console` is installed; target `os-*` service is running.
**Authority:** P1 operator action — only the workspace operator may add pairings.

---

## Overview

Machine-based authorization (MBA) connects `os-console` to `os-*` services via direct peer-to-peer cryptographic pairing. A pairing is a permanent relationship unless explicitly revoked. Adding a pairing is an immutable ledger event — the history of pairings is preserved for audit even after revocation.

This guide covers establishing a new pairing, verifying the connection, rotating keys, and revoking access.

---

## Prerequisites

1. `os-console` is installed on the operator machine (Linux Mint or macOS).
2. The target `os-*` service is running and reachable on the network.
3. The target service has `system-gateway-mba` running.
4. The operator has the SSH public key for the connecting machine.
5. The operator has write access to `pairings.yaml` at the workspace root.

---

## Step 1 — Identify the connecting machine's SSH public key

The SSH public key is the identity credential for the MBA pairing. It is the public half of an Ed25519 SSH key pair on the operator's machine.

```bash
# View the public key (replace with your key file path)
cat ~/.ssh/id_ed25519.pub

# If you need to generate a key:
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "operator@woodfine-console"
```

Keep the public key (`.pub`) file accessible. The private key never leaves this machine.

---

## Step 2 — Register the key with the target service

Use `proofctl` on the target `os-*` service to register the public key. `proofctl` is the admin CLI for `system-gateway-mba`.

```bash
# On the target os-* service machine:
proofctl user add jennifer \
  --tenant woodfine \
  --key-file /path/to/jennifer_console.pub \
  --role editor
```

**Parameters:**
- `jennifer` — username for this operator on this service.
- `--tenant woodfine` — tenant scope.
- `--key-file` — path to the SSH public key file.
- `--role editor` — access role (`editor` is the standard role; admin roles are granted separately).

**Expected output:**
```
Added jennifer@woodfine  SHA256:abc123...xyz
```

Note the fingerprint shown — use it for verification in Step 4.

---

## Step 3 — Add the pairing entry to pairings.yaml

Add a new entry to `pairings.yaml` at the workspace root. This is the topology record that `os-console` reads to know which services it should attempt to connect to.

```yaml
- cluster_name: project-totebox
  module_id: totebox
  slm_endpoint: http://localhost:8011
  paired_on: 2026-05-25
  type: active
  branch: cluster/project-totebox
```

Commit `pairings.yaml` after adding the entry. Do not remove or modify existing entries; add new entries and set `type: revoked` when access is withdrawn.

---

## Step 4 — Verify: MBA LINK ACTIVE

Start or restart `os-console` on the operator machine. Observe the status bar.

**Expected status bar:**
```
jennifer@woodfine | MBA LINK ACTIVE | F4: Content | Tier A | 00:00:01
```

If `MBA LINK ACTIVE` does not appear:

| Status shown | Diagnosis | Action |
|---|---|---|
| `MBA LINK INACTIVE: key not registered` | The key was not registered on the target service | Repeat Step 2; confirm key file path |
| `MBA LINK INACTIVE: service unreachable` | Network issue or service not running | Check that the target service is running |
| `MBA LINK INACTIVE: fingerprint mismatch` | The registered key does not match the connecting key | `proofctl user rotate-key` (see Key rotation below) |
| `MBA LINK PENDING` | Connection attempt in progress | Wait 10 seconds; if unchanged, check logs |

---

## Listing active registrations

```bash
proofctl user list
```

**Expected output:**
```
ID  Username    Tenant    Role    Fingerprint           Active  Created
1   jennifer    woodfine  editor  SHA256:abc123...xyz   yes     2026-05-25
```

---

## Key rotation

When an operator's hardware changes or a key is rotated for security:

```bash
# On the target os-* service machine:
proofctl user rotate-key jennifer \
  --key-file /path/to/jennifer_new.pub
```

No service restart required. The new fingerprint takes effect immediately for the next connection attempt.

---

## Revoking access

```bash
proofctl user disable jennifer
```

The user record is preserved in the audit log. Set `type: revoked` in the corresponding `pairings.yaml` entry. Do not delete the entry — the pairing history is an immutable ledger record.

---

## Pairing multiple os-* services

`os-console` can maintain simultaneous MBA connections to multiple `os-*` services. Repeat Steps 2–4 for each target service:

| Target service | Module ID |
|---|---|
| `os-totebox` | totebox |
| `os-orchestration` | orchestration |
| `os-privategit` | privategit |
| `os-mediakit` | mediakit |
| `os-network-admin` | network-admin |

---

## See also

- `guide-command-ledger.md` — MBA definition and Zero-Form context
- `guide-console-operations.md` — os-console startup and F-key reference

---

*Copyright © 2026 PointSav Digital Systems. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe.*
