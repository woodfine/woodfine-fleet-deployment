---
schema: foundry-doc-v1
title: "Console Operations and the Derivative HUD"
slug: guide-console-operations
type: guide
section: console-and-operations
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Console Operations and the Derivative HUD

The Woodfine Console (`console.woodfinegroup.com`) operates as a Heads-Up Display
exposing three layers of the archive: base assets (raw files), the first-derivative
index (structured entities), and third-derivative outputs (drafted documents). This
guide describes how to use the F12, F3/F2, and F4 cartridges to move files into the
archive and extract processed outputs.

## Prerequisites

- Paired device and active `MBA LINK ACTIVE` session (see `guide-command-ledger.md`).
- Local files to be injected are on the operator's desktop or a local directory.
- Browser access to `https://console.woodfinegroup.com`.

## F12 — Input Machine (Base Asset injection)

F12 is the primary human-in-the-loop gateway for moving local files into the archive.

1. Press F12 to open the Input Machine.
2. Select the destination Totebox from the dropdown.
3. Select the service and chart of accounts that apply to the file.
4. Drag the local file (`.CSV`, `.MD`, or other supported format) into the drop zone.
5. Confirm the injection. The system strips execution permissions and writes the file
   to cold storage as a base asset.

## F3 / F2 — Email and People (Querying the index)

F3 and F2 expose the first-derivative index — structured entities extracted from the
base assets.

### Reading email (F3)

1. Press F3 to open the email feed.
2. Navigate by thread or sender. The feed shows cold base assets (`.eml` files) in
   text-only form.

### Querying contacts (F2)

1. Press F2 to open the People index.
2. Enter a natural-language query (e.g., "Find the contact from the plumbing company").
   The interface translates the query against the first-derivative entity index.
3. Review the results. To export a contact record to your desktop, select the entry
   and click Export — the output is a `.CSV` file.

## F4 — Content (Third-derivative drafting)

F4 is the generative drafting terminal for producing third-derivative outputs from
indexed data.

1. Press F4 to open the Content terminal.
2. Draft communications using the editor. The first-derivative index (themes and
   domains) is available in the sidebar to inform the draft.
3. To finalize and export: click Export — the output is a `.MD` file written to
   your desktop.
4. To export the full current state of the first-derivative index (all archetypes,
   domains, and themes), click Global Export — the output is a `.CSV` file.

## Expected outcome

- Files injected via F12 appear in the Totebox Archive ledger.
- Contact queries via F2 return matching entity records.
- Drafts exported via F4 are present on the operator's desktop as `.MD` files.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
