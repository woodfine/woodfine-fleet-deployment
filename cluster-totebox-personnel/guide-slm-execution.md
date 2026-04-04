
## 4. Sovereign Data Extraction (DARP Compliance)
To review both the raw AI extractions and the finalized, human-approved institutional knowledge, operators can pull the full markdown graph locally.

1. Navigate to the local command terminal (e.g., `~/Foundry`).
2. Execute the extraction diode: `./tool-extract-content.sh`.
3. The diode will securely synchronize the `knowledge-graph/` (drafts) and `verified-ledger/` (finalized entities) to the local machine without modifying the cloud state.
4. Review your Markdown files in `./Sovereign-Exports/Content/`.
