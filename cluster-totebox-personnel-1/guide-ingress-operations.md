# 🧭 GUIDE: INGRESS OPERATIONS & SELF-HEALING LOOP
**Operational Tier:** 3 (Fleet Deployment)
**Target Node:** cluster-totebox-personnel-1 (Laptop-A LXC)

---

## I. THE EVENT-DRIVEN PIPELINE
The Totebox Archive operates an automated, continuous data ingestion loop targeting `info@woodfine.co`. 

1. **The Diode:** The Harvester pulls a maximum of 9 emails across 3 folders (`totebox-ingress`, `OpenStack`, `PostgresSQL`) and drops them into the `service-email/maildir/new/` spool.
2. **The Splinter:** The payload is shattered. The `.eml` is secured in cold storage.
3. **The Intelligence:** Qwen2-0.5B evaluates the text against the **Domain Glossaries** (Corporate, Projects, Documentation), extracting Archetypes and Themes.
4. **The Ledger:** The JSON ledgers for personnel and content are autonomously appended and healed.

## II. THE DOMAIN MATRIX (GLOSSARIES)
The active intelligence extracted by the SLM is strictly mapped 1:1:1 against the core encyclopedic backbone of the enterprise:
* `content-wiki-corporate` (Institutional Governance)
* `content-wiki-projects` (Real Estate Ledgers)
* `content-wiki-documentation` (PointSav Architecture)

## III. TROUBLESHOOTING INGESTION
If the F8 Terminal indicates a stalled pipeline:
1. Verify the MSFT Graph API tokens in `service-email/auth-credentials.env`.
2. Ensure the target folders (`totebox-ingress`, etc.) physically exist in the Outlook client.
3. Check the `spool-daemon` status via systemd to ensure the watchdog is actively monitoring `/maildir/new/`.
