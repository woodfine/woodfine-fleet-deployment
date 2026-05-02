# GUIDE: Physical Egress (Regulatory Printing)
**Status:** Operational Mandate | **Taxonomy:** Tier-5-Service

## 📜 Standard Operating Procedure (SOP)
To achieve 1:1 parity with the official offline PDF distribution, the human operator must enforce the following browser print settings prior to physical output.

### Configuration Checklist
* [ ] **Orientation**: Portrait.
* [ ] **Headers/Footers**: OFF. (This prevents the browser from injecting the host URL timestamp at the document margins).
* [ ] **Margins**: Set to "Default" or exactly "0.5in".
* [ ] **CSS State Verification**: Ensure the "Digital Infrastructure & Privacy Posture" block is successfully hidden by the `@media print` engine.
* [ ] **Contact Block Validation**: Verify the physical `.print-contact` block renders seamlessly directly before the legal disclosures.


---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
