---
schema: foundry-doc-v1
title: "Physical Egress — Regulatory Printing"
slug: guide-physical-egress
type: guide
section: network-and-infrastructure
status: active
audience: operators
bcsc_class: current-fact
last_edited: 2026-05-25
editor: pointsav-engineering
---

# Guide — Regulatory Printing (Physical Egress)

This guide covers the browser print settings required to produce compliant printed output from Woodfine web documents. The correct settings ensure output matches the official offline PDF distribution exactly.

## Prerequisites

- A browser-accessible Woodfine document ready for printing.
- A connected printer.

## Print configuration checklist

To achieve 1:1 parity with the official offline PDF distribution, apply the following browser print settings before printing:

### Settings
* [ ] **Orientation**: Portrait.
* [ ] **Headers/Footers**: OFF. (This prevents the browser from injecting the host URL timestamp at the document margins).
* [ ] **Margins**: Set to "Default" or exactly "0.5in".
* [ ] **CSS State Verification**: Ensure the "Digital Infrastructure & Privacy Posture" block is successfully hidden by the `@media print` engine.
* [ ] **Contact Block Validation**: Verify the physical `.print-contact` block renders seamlessly directly before the legal disclosures.

---

*Copyright © 2026 Woodfine Capital Projects Inc. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
