
## 4. Sovereign Data Extraction (DARP Compliance)
To satisfy the Digital Asset Resolution Package (DARP) mandate, operators can extract the entire JSON personnel ledger into a flat, human-readable CSV at any time.

1. Navigate to the local command terminal (e.g., `~/Foundry`).
2. Execute the extraction diode: `./tool-extract-people.sh`.
3. The engine will temporarily flatten the nested JSONs on the cloud node, extract `personnel_export.csv` via SSH, and immediately destroy the temporary cloud file.
4. Review your data in `./Sovereign-Exports/People/`.
