# 🧭 guide-01: TELEMETRY OPERATIONS & COMPLIANCE
**Operational Tier:** 3 (Fleet Deployment)
**Standard:** DS-ADR-06 (Zero-Cookie Architecture)
**Software Engine:** PointSav Omni-Matrix (v1.2.0 - Compiled Rust Core)

---

## I. OPERATIONAL POSTURE
Woodfine Management Corp. utilizes PointSav Digital Systems' Sovereign Telemetry architecture. This system provides executive intelligence regarding audience engagement and hardware demographics without deploying third-party tracking cookies or harvesting Personally Identifiable Information (PII).

This posture ensures absolute compliance with multi-jurisdictional privacy frameworks (GDPR, CCPA, PIPEDA, BCSC) while maintaining the structural integrity of our digital infrastructure.

## II. DUAL-BINARY EXECUTION PROTOCOL
The telemetry architecture is deployed using a strict "Totebox" methodology. The underlying engineering is completely abstracted away from the Customer's daily operations via two distinct Rust binaries:

1. **The Edge Shield (`telemetry-daemon`):** An asynchronous daemon locked into continuous execution via a Linux `systemd` service. It listens on an internal proxy port, intercepting valid JSON payloads and writing them to the immutable `/assets/ledger_telemetry.csv` file.
2. **The Intelligence Core (`omni-matrix-engine`):** A fault-tolerant engine that fires daily via a system `cron` job. It cross-references the ledger against a localized, offline `GeoLite2-City.mmdb` database, synthesizing the raw data into human-readable Markdown reports without querying the public internet.

## III. THE 8 INSTITUTIONAL MATRICES
By enforcing strict data hygiene, the engine captures only the metrics required for macro-level institutional auditing. The synthesized report aggregates data into standard financial timeframes (Yesterday, 7 Days, 30 Days, 60 Days, 90 Days, YTD, and Inception).

The system generates 8 distinct matrices for financial review:
1. **Time Matrix:** Transposed chronological volume of network events.
2. **Global Routing Matrix:** Granular Country and Region/State density.
3. **Metro Region Matrix:** Exact City-level terminal density.
4. **Timezone Alignment Matrix:** Temporal alignment of network events.
5. **Content Matrix (Target URI):** Page-level interest, mathematically routing staging traffic to an offline Localhost bucket.
6. **Device Form Factor Matrix:** Desktop/Server vs. Mobile/Tablet categorization.
7. **Operating System Matrix:** Platform distribution (macOS, Windows, Linux, iOS, Android).
8. **Raw Architecture Signatures:** The top 5 exact User-Agent hardware strings.

## IV. DISASTER RECOVERY & EXTRACTION
The Tier-2 Cloud Node does not utilize fragile database clusters. All data is appended to flat `.csv` ledgers. 

Operations utilize a strict "Pull Diode" (`pull-telemetry-ledgers.sh`) to securely download the synthesized `.md` matrices and the raw `.csv` ledgers back to the local terminal. This script enforces a **10-Day Rolling Retention Policy**, mathematically purging any local `.csv` backups older than 10 days to guarantee flawless data hygiene and rapid recovery capabilities.

---

*Copyright © 2026 Woodfine Management Corp. All rights reserved.*

*Woodfine Capital Projects™, Woodfine Management Corp™, PointSav Digital Systems™, Totebox Orchestration™, and Totebox Archive™ are trademarks of Woodfine Capital Projects Inc., used in Canada, the United States, Latin America, and Europe. All other trademarks are the property of their respective owners.*
