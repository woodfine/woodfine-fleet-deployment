---
schema: foundry-doc-v1
title: "Unified Command Ledger Operations"
slug: guide-command-ledger
type: guide
section: console-and-operations
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Unified Command Ledger Operations

The Woodfine Command Ledger (`console.woodfinegroup.com`) is the operator interface
for reviewing, verifying, and signing off on records managed by the Totebox Archive.
It exposes identity records, communications, corporate documents, and financial
ledgers through a hardware-key-driven interface. This guide covers how to navigate
and operate the ledger.

## Prerequisites

- A paired device (your MacBook or designated hardware) — access is granted via
  hardware cryptographic pairing, not a username/password.
- Browser access to `https://console.woodfinegroup.com`.
- `MBA LINK ACTIVE` status showing green before beginning any session.

## Session access

Open `https://console.woodfinegroup.com` in your browser. The console verifies
your hardware pairing automatically. If the `MBA LINK ACTIVE` indicator is green,
your device is verified and the session is active.

If the link is not active, the hardware pairing has lapsed or your device has changed.
Contact the Woodfine network administrator to re-establish the pairing.

## Navigation — F-key cartridges

Each F-key loads a distinct operational cartridge into the central viewport:

| Key | Cartridge | Purpose |
|---|---|---|
| F1 | Help | Immutable operating manual and compliance glossary |
| F2 | People | Identity Ledger — review and verify contacts extracted from communications |
| F3 | Email | Text-only feed of encrypted communications |
| F4 | Content | Draft review and approval — verify and seal corporate drafts and generated memos |
| F5 | Minutebook | Read-only access to corporate PDFs, minute books, and board resolutions |
| F6 | Bookkeeper | Financial ledgers and capital deployment metrics |
| F12 | Input Machine | Secure file gateway — drag local files here to strip execution permissions and inject into the network |

## Common tasks

### Reviewing new contacts (F2 — People)

1. Press F2 to open the Identity Ledger.
2. New contacts extracted from communications appear in the review queue.
3. Verify each contact's identity against supporting records.
4. Approve or reject the entry. Approved entries are written to the Totebox Archive.

### Reading communications (F3 — Email)

1. Press F3 to open the email feed.
2. The feed is text-only and noise-filtered. Attachments are not rendered inline.
3. Use the search field to locate specific threads or senders.

### Approving content drafts (F4 — Content)

1. Press F4 to open the content terminal.
2. Review the draft in the viewport.
3. Approve to seal the draft, or reject with a note.
4. Sealed drafts are committed to the Totebox Archive as immutable records.

### Injecting files (F12 — Input Machine)

1. Press F12 to open the Input Machine.
2. Select the destination Totebox, service, and chart of accounts.
3. Drag the local file into the drop zone.
4. The system strips execution permissions and routes the file into the Totebox Archive.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
