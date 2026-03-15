# GUIDE-03: Telemetry Operations & Compliance

## 1. Operational Posture
Woodfine Management Corp. utilizes PointSav Digital Systems' V4 Sovereign Telemetry architecture. This system provides executive intelligence regarding audience engagement and hardware demographics without deploying cookies or harvesting Personally Identifiable Information (PII).

This posture ensures absolute compliance with multi-jurisdictional privacy frameworks (GDPR, CCPA, PIPEDA, BCSC) while maintaining the structural integrity of our digital infrastructure.

## 2. Intelligence Report Generation
Telemetry is recorded continuously into an immutable CSV ledger on the Tier-2 Private Cloud node. To generate a human-readable intelligence report:

1. Access the deployment environment via SSH (`node-gcp-free`).
2. Navigate to the telemetry directory: `cd /opt/deployments/woodfine-fleet-deployment/media-marketing-landing/app-mediakit-telemetry/`
3. Execute the synthesizer: `cargo run --release --bin telemetry-synthesizer`
4. The system will output a timestamped Markdown report (`REPORT_TELEMETRY_[TIMESTAMP].md`) in the `./outbox/` directory.

## 3. Reading the Intelligence Report
The synthesized report aggregates data into standard institutional timeframes (24 Hours to Year-To-Date). Key metrics include:
- **Total Asset Renderings:** Gross volume of successful digital deliveries.
- **Average Dwell Time:** The mean duration users spend analyzing the Direct-Hold Solutions mandate.
- **Average Scroll Depth:** A percentage indicating how far users read into the structural governance and legal disclaimers.
- **High-Intent Actions:** A crucial metric tracking specific physical clicks on the "Fleet Manifest", "PDF Download", or "WhatsApp" communication endpoints.
