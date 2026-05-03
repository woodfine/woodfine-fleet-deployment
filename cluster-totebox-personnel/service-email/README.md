# ⚙️ SERVICE-EMAIL: SOVEREIGN INGRESS DIODE
**Entity:** Woodfine Management Corp.
**Standard:** Leapfrog 2030 (Event-Driven Append-Only Pipeline)
**Tier:** 5 (Service Logic)

---

## I. ARCHITECTURAL MANDATE
This component operates as the primary ingestion diode for the `cluster-totebox-personnel-1` container. It penetrates the `info@woodfine.co` Microsoft 365 infrastructure, extracts inbound assets, mutates the server state (Hard Delete), and drives the continuous self-healing data loop.

## II. MICRO-BATCHING CONSTRAINTS
To guarantee operational stability on constrained Edge Nodes (1GB RAM), the `master-harvester-rs` engine is mathematically capped:
* **Target Folders:** `totebox-ingress`, `OpenStack`, `PostgresSQL`
* **Extraction Limit:** Exactly 3 items per folder, per cycle.

## III. THE SPLINTER TOPOLOGY
Once an asset hits the `/service-email/maildir/new/` spool, the daemon routes the payloads:
1. **Cold Storage:** Immutable `.eml` vaulted to `/maildir/cur/`.
2. **Cognitive Forge:** Text routed to `service-slm` for evaluation against the Domain Glossaries (Corporate, Projects, Documentation).
3. **Identity Ledger:** Headers routed to `service-people` to mint or heal Sovereign IDs.
