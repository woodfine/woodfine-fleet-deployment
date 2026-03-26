# Woodfine Management Corp. | Operational Telemetry Guide

## Overview
This guide details the operational execution for retrieving asset ledgers and telemetry reports from the cloud environment to local physical nodes. 

## Execution Sub-Routines
All execution scripts reside in `/media-marketing-landing/`.

1. **Synthesis Trigger (`tool-telemetry-synthesizer.sh`)**: Commands the cloud node to format raw data into human-readable Markdown reports.
2. **Strict Pull Diode (`tool-telemetry-pull.sh`)**: Secures a one-way transfer of generated reports and raw `.csv` ledger assets to the local machine, enforcing a localized 9-day retention cycle.
