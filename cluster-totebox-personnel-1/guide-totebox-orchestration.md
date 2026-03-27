# 🧭 GUIDE: TOTEBOX ORCHESTRATION & TOTEBOX-PEDIA
**Operational Tier:** 3 (Fleet Deployment)
**Target Node:** cluster-totebox-personnel-1

---

## I. EXECUTIVE SUMMARY
This guide defines the operational intelligence pipeline utilized within the Personnel Totebox Archive. 

The Totebox Archive is an Active Intelligence Engine. All inbound corporate communications are automatically intercepted, translated into independent physical files, and staged as "Overlays" for human verification. We mathematically reject Vector Databases (RAG), utilizing a self-healing network of flat, hyperlinked Markdown files (The Totebox-pedia).

## II. THE LONG-TERM SUPPORT (LTS) KNOWLEDGE GRAPH
The `content-wiki-*` repositories (Corporate, Projects, Documentation) serve as the Long-Term Support (LTS) encyclopedic backbone for Woodfine personnel and Service Providers. 

The **Domains** (Corporate, Projects, Documentation) consist of two core elements:
1. **Glossaries:** The immutable definition ledgers.
2. **Topics:** The physical Markdown index cards explaining operational realities.

## III. THE OVERLAY PIPELINE (STAGING VS. PUBLISHING)
To prevent AI hallucination creep, the ingestion loop operates strictly as a staging procedure.

1. **Ingest & Splinter:** `service-email` drops data into the spool and shatters it.
2. **Cognitive Staging:** `service-slm` reads the raw text, evaluates it against the Domain Glossaries, and generates an **Overlay Payload** (Suggested New Topics & Facts). It places this in `/knowledge-graph/` (the Staging Ground). It **does not** automatically publish to the LTS Wiki.
3. **The Fiduciary Merge:** The operator mounts **[F4] CONTENT** on the Command Ledger. The UI displays the Suggested Overlay against the Current LTS State.
4. **Synthesis:** The operator manually edits and verifies the Overlay. `service-content` then compiles the final Markdown Index Cards, natively hyperlinking recognized Glossary terms, and formally commits the update to the LTS Wiki.
