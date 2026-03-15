# GUIDE: SLM Point-in-Time Execution
**Customer:** Woodfine Management Corp.
**Target Environment:** cluster-totebox-personnel
**Operation:** Local AI Data Extraction

## 1. Operational Overview
This protocol governs the manual invocation of the local Small Language Model (SLM). Because the Totebox Archive prohibits omnipresent AI daemons to protect data integrity, operators must trigger the extraction filter manually on raw assets to populate the self-healing holding tank.

## 2. Execution Protocol
To extract structured intelligence from a raw ingestion file (e.g., a Maildir `.eml` file), execute the following pipeline from the Command Terminal:

1. Identify the target raw file in the immutable Maildir vault:
   `ls -la /opt/woodfine/cluster-totebox-personnel/service-email/personnel-maildir/new/`

2. Pipe the raw file into the `service-slm` extraction filter, targeting the knowledge graph:
   `cat /opt/woodfine/cluster-totebox-personnel/service-email/personnel-maildir/new/raw_input.eml | /opt/pointsav/bin/service-slm --protocol EXTRACT > /opt/woodfine/cluster-totebox-personnel/service-content/knowledge-graph/clean_output.md`

3. Verify the output draft before relying on it for institutional generation:
   `cat /opt/woodfine/cluster-totebox-personnel/service-content/knowledge-graph/clean_output.md`

## 3. Security Constraints
The SLM runs in a severed network container. It cannot access the internet to verify external facts. It will only extract and structure the exact physical data present in the source file.
